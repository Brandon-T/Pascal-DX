unit SmartPlugin;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows, Direct3D9;

type
  SMARTGetMousePos = procedure(var X, Y: Integer); cdecl;
  SMARTSetCapture = procedure(Enabled: Boolean); cdecl;
  SMARTButtonPressed = procedure(ID: Integer; State: Boolean); cdecl;

  PSMARTButtonPressed = ^SMARTButtonPressed;
  PPChar = ^PChar;
  PPPChar = ^PPChar;
  PInt = ^Integer;
  PPInt = ^PInt;
  PBool = ^Boolean;

  SMARTInfo = packed record
    Version: Integer;
    Img, Dbg: Pointer;
    Width, Height: Integer;
    GetMousePos: SMARTGetMousePos;
    SetCapture: SMARTSetCapture;
  end;

  PSMARTInfo = ^SmartInfo;

  D3DVertex = packed record
    X, Y, Z, RHW: Single;
    Colour: UInt32;
    U, V: Single;
  end;

var
  SmartGlobal: ^SMARTInfo;
  SmartDebugEnabled: Boolean;
  SmartDirectXEnabled: Boolean;

Procedure BltSmartBuffer(Device: IDirect3DDevice9);
Function dxReadPixels(Device: IDirect3DDevice9; Buffer: Pointer; var Minimised: Boolean; var Width, Height: Integer; Format: D3DFormat = D3DFMT_UNKNOWN): HRESULT;
Procedure DrawCircle(Device: IDirect3DDevice9; MX, MY, R: Single; Colour: TD3DColor = $FFFF0000); {ARGB <OR> D3DCOLOR_RGBA($FF, $0, $0, $FF)}
Procedure SMARTPluginInit(ptr: PSMARTInfo; ReplaceButtons: PBool; ButtonCount: PInt; ButtonText: PPPChar; ButtonIDs: PPInt; ButtonCallback: PSMARTButtonPressed) cdecl;



implementation

const
  BtnIDs: array [0..1] of Integer = (100, 101);
  BtnTexts: array[0..1] of PChar = ('Disable Direct-X_Enable Direct-X', 'Enable Debug_Disable dxDebug');


procedure SMART_ButtonPressed(ID: Integer; State: Boolean); cdecl;
begin
  case ID of
    100:
         if (State) Then
         begin
           SmartGlobal^.SetCapture(False);
           SmartDirectXEnabled := True;
         end else
           begin
             SmartGlobal^.SetCapture(True);
             SmartDirectXEnabled := False;
           end;

    101:
         SmartDebugEnabled := Not State;
  end;
end;

Procedure SMARTPluginInit(ptr: PSMARTInfo; ReplaceButtons: PBool; ButtonCount: PInt; ButtonText: PPPChar; ButtonIDs: PPInt; ButtonCallback: PSMARTButtonPressed) cdecl;
begin
  SmartGlobal := ptr;
  if (ptr <> nil) then
  begin
    ReplaceButtons^ := True;
    ButtonCount^ := 2;
    ButtonText^ := @BtnTexts[0];
    ButtonIDs^ := @BtnIDs[0];
    ButtonCallback^ := @SMART_ButtonPressed;
  end;
end;



Function MakeD3DVertex(X, Y, Z, RHW: Single; Colour: UInt32; U, V: Single): D3DVertex;
begin
  Result.X := X;
  Result.Y := Y;
  Result.Z := Z;
  Result.RHW := RHW;
  Result.Colour := Colour;
  Result.U := U;
  Result.V := V;
end;

Procedure LoadTexture(Device: IDirect3DDevice9; Buffer: Pointer; Width, Height: Integer; out Tex: IDirect3DTexture9);
var
   Rect: TD3DLockedRect;
begin
  Device.CreateTexture(Width, Height, 1, 0, D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, Tex, nil);
  Tex.LockRect(0, Rect, nil, D3DLOCK_DISCARD);
  CopyMemory(Rect.pBits, Buffer, Width * Height * 4);
  Tex.UnlockRect(0);
end;

Procedure DrawTexture(Device: IDirect3DDevice9; Tex: IDirect3DTexture9; X1, Y1, X2, Y2: Single);
const
  VERTEX_FVF_TEX = (D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
var
  UOffset: Single;
  VOffset: Single;
  Vertices: Array [0..3] of D3DVertex;
Begin
  UOffset := 0.5 / (X2 - X1);
  VOffset := 0.5 / (Y2 - Y1);

  Vertices[0] := MakeD3DVertex(X1, Y1, 1.0, 1.0, D3DCOLOR_RGBA($FF, $FF, $FF, $FF), 0.0 + UOffset, 0.0 + VOffset);
  Vertices[1] := MakeD3DVertex(X2, Y1, 1.0, 1.0, D3DCOLOR_RGBA($FF, $FF, $FF, $FF), 1.0 + UOffset, 0.0 + VOffset);
  Vertices[2] := MakeD3DVertex(X1, Y2, 1.0, 1.0, D3DCOLOR_RGBA($FF, $FF, $FF, $FF), 0.0 + UOffset, 1.0 + VOffset);
  Vertices[3] := MakeD3DVertex(X2, Y2, 1.0, 1.0, D3DCOLOR_RGBA($FF, $FF, $FF, $FF), 1.0 + UOffset, 1.0 + VOffset);

  Device.SetFVF(VERTEX_FVF_TEX);
  Device.SetTexture(0, Tex);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLESTRIP, 2, Vertices, SizeOf(D3DVertex));
  Device.SetTexture(0, nil);
End;

Procedure BltSmartBuffer(Device: IDirect3DDevice9);
var
  Ptr: ^UInt8;
  R, G, B: UInt8;
  I, J, Width, Height: Integer;
  Tex: IDirect3DTexture9;
begin
  if (SmartGlobal <> nil) then
  begin
    Ptr := SmartGlobal^.Dbg;
    Width := SmartGlobal^.Width;
    Height := SmartGlobal^.Height;

    For I := 0 To Height - 1 do
    begin
      For J := 0 To Width - 1 do
      begin
        B := Ptr^;
        Inc(Ptr);

        G := Ptr^;
        Inc(Ptr);

        R := Ptr^;
        Inc(Ptr);

        if ((B = 0) and (G = 0) and (R = 0)) then
          Ptr^ := 0
        else
          Ptr^ := $FF;
        Inc(Ptr);
      end;
    end;

    LoadTexture(Device, SmartGlobal^.dbg, SmartGlobal^.width, SmartGlobal^.height, Tex);
    DrawTexture(Device, Tex, 0, 0, SmartGlobal^.Width, SmartGlobal^.Height);
    Tex._Release();  //would be WAY FASTER/BETTER to release only on device reset.
  end;
end;

Function dxReadPixels(Device: IDirect3DDevice9; Buffer: Pointer; var Minimised: Boolean; var Width, Height: Integer; Format: D3DFormat = D3DFMT_UNKNOWN): HRESULT;
var
  RenderTarget: IDirect3DSurface9;
  DestTarget: IDirect3DSurface9;
  Descriptor: D3DSURFACE_DESC;
  Rect: D3DLOCKED_RECT;
  DC: HDC;
begin
  Result := Device.GetRenderTarget(0, RenderTarget);

  if (Result = S_OK) then
  begin
    if ((Width = 0) or (Height = 0) or (Format = D3DFMT_UNKNOWN)) then
    begin
      RenderTarget.GetDesc(Descriptor);
      Width := Descriptor.Width;
      Height := Descriptor.Height;
      Format := Descriptor.Format;
    end;

    RenderTarget.GetDC(DC);
    Minimised := IsIconic(WindowFromDC(DC)); //optional optimisation. If the window is minimised, we don't draw debug!
    RenderTarget.ReleaseDC(DC);
    Result := Device.CreateOffscreenPlainSurface(Width, Height, Format, D3DPOOL_SYSTEMMEM, DestTarget, nil);
    Result := Device.GetRenderTargetData(RenderTarget, DestTarget);
    DestTarget.LockRect(Rect, nil, D3DLOCK_READONLY);
    CopyMemory(Buffer, Rect.pBits, Width * Height * 4);
    DestTarget.UnlockRect();
    DestTarget._Release();
    DestTarget := nil;
  end;
  RenderTarget._Release();
  RenderTarget := nil;
end;

Procedure DrawCircle(Device: IDirect3DDevice9; MX, MY, R: Single; Colour: TD3DColor);
const
  Resolution = 10;
  VERTEX_FVF_TEX = (D3DFVF_XYZRHW or D3DFVF_DIFFUSE or D3DFVF_TEX1);
var
  I: Integer;
  Vertices: Array[0 .. Resolution - 1] of D3DVertex;
begin
  For I := 0 To Resolution - 1 Do
  begin
    Vertices[I].X := MX + R * cos(3.141592654 * (I / (Resolution / 2.0)));
    Vertices[I].Y := MY + R * sin(3.141592654 * (I / (Resolution / 2.0)));
    Vertices[I].Z := 0.0;
    Vertices[I].RHW := 1.0;
    Vertices[I].Colour := Colour;
    Vertices[I].U := 0.0;
    Vertices[I].V := 0.0;
  end;

  Device.SetFVF(VERTEX_FVF_TEX);
  Device.DrawPrimitiveUP(D3DPT_TRIANGLEFAN, Resolution - 2, Vertices, sizeof(D3DVertex));
end;

end.

