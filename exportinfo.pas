unit ExportInfo;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, DynLibs, Windows, Direct3D9, D3DProxy;

type
  d3d9_dll = record
    dll: HMODULE;
    D3DPERF_BeginEvent: Pointer;
    D3DPERF_EndEvent: Pointer;
    D3DPERF_GetStatus: Pointer;
    D3DPERF_QueryRepeatFrame: Pointer;
    D3DPERF_SetMarker: Pointer;
    D3DPERF_SetOptions: Pointer;
    D3DPERF_SetRegion: Pointer;
    DebugSetLevel: Pointer;
    DebugSetMute: Pointer;
    Direct3DCreate9: Pointer;
    Direct3DCreate9Ex: Pointer;
    Direct3DShaderValidatorCreate9: Pointer;
    PSGPError: Pointer;
    PSGPSampleTexture: Pointer;
  end;

  var
     D3D9Proxy: Direct3D9Proxy;
     OriginalDX: HMODULE;
     d3d9: d3d9_dll;

  Function Initialize(): Boolean;
  Function DeInitialize(): Boolean;
  Procedure D3DPERF_BeginEvent; stdcall;
  Procedure D3DPERF_EndEvent; stdcall;
  Procedure D3DPERF_GetStatus; stdcall;
  Procedure D3DPERF_QueryRepeatFrame; stdcall;
  Procedure D3DPERF_SetMarker; stdcall;
  Procedure D3DPERF_SetOptions; stdcall;
  Procedure D3DPERF_SetRegion; stdcall;
  Procedure DebugSetLevel; stdcall;
  Procedure DebugSetMute; stdcall;
  Function  Direct3DCreate9(SDKVersion: UINT): Pointer; stdcall;
  Procedure Direct3DCreate9Ex; stdcall;
  Procedure Direct3DShaderValidatorCreate9; stdcall;
  Procedure PSGPError; stdcall;
  Procedure PSGPSampleTexture; stdcall;


implementation


Function Initialize(): Boolean;
var
  Root: Array of TChar;
begin
  SetLength(Root, MAX_PATH);
  GetSystemDirectoryA(@Root[0], MAX_PATH);
  StrCat(@Root[0], '\d3d9.dll');

  OriginalDX := LoadLibraryA(@Root[0]);

  if (OriginalDX <> NilHandle) then
  begin
    d3d9.D3DPERF_BeginEvent := GetProcAddress(OriginalDX, 'D3DPERF_BeginEvent');
    d3d9.D3DPERF_EndEvent := GetProcAddress(OriginalDX, 'D3DPERF_EndEvent');
    d3d9.D3DPERF_GetStatus := GetProcAddress(OriginalDX, 'D3DPERF_GetStatus');
    d3d9.D3DPERF_QueryRepeatFrame := GetProcAddress(OriginalDX, 'D3DPERF_QueryRepeatFrame');
    d3d9.D3DPERF_SetMarker := GetProcAddress(OriginalDX, 'D3DPERF_SetMarker');
    d3d9.D3DPERF_SetOptions := GetProcAddress(OriginalDX, 'D3DPERF_SetOptions');
    d3d9.D3DPERF_SetRegion := GetProcAddress(OriginalDX, 'D3DPERF_SetRegion');
    d3d9.DebugSetLevel := GetProcAddress(OriginalDX, 'DebugSetLevel');
    d3d9.DebugSetMute := GetProcAddress(OriginalDX, 'DebugSetMute');
    d3d9.Direct3DCreate9 := GetProcAddress(OriginalDX, 'Direct3DCreate9');
    d3d9.Direct3DShaderValidatorCreate9 := GetProcAddress(OriginalDX, 'Direct3DShaderValidatorCreate9');
    d3d9.PSGPError := GetProcAddress(OriginalDX, 'PSGPError');
    d3d9.PSGPSampleTexture := GetProcAddress(OriginalDX, 'PSGPSampleTexture');
    d3d9.Direct3DCreate9Ex := GetProcAddress(OriginalDX, 'Direct3DCreate9Ex');
  end else
    Result := False;

  SetLength(Root, 0);
  Result := True;
end;

Function DeInitialize(): Boolean;
begin
  if (OriginalDX <> NilHandle) then
  begin
    FreeLibrary(OriginalDX);
    OriginalDX := NilHandle;
    Result := True;
  end else
    Result := False;
end;

Procedure D3DPERF_BeginEvent; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_BeginEvent]
end;

Procedure D3DPERF_EndEvent; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_EndEvent]
end;

Procedure D3DPERF_GetStatus; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_GetStatus]
end;

Procedure D3DPERF_QueryRepeatFrame; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_QueryRepeatFrame]
end;

Procedure D3DPERF_SetMarker; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_SetMarker]
end;

Procedure D3DPERF_SetOptions; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_SetOptions]
end;

Procedure D3DPERF_SetRegion; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.D3DPERF_SetRegion]
end;

Procedure DebugSetLevel;  stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.DebugSetLevel]
end;

Procedure DebugSetMute; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.DebugSetMute]
end;

Function Direct3DCreate9(SDKVersion: LongWord): Pointer; stdcall;
type
  D3D9_Type = Function(SDKVersion: LongWord): Pointer; stdcall;

var
  pOriginal: ^IDirect3D9;
begin
  pOriginal := D3D9_Type(d3d9.Direct3DCreate9)(SDKVersion);
  D3D9Proxy := D3D9Proxy.Create(pOriginal);

  MessageBoxA(0, 'Proxy is all good', '', 0);
  Result := @D3D9Proxy;
  MessageBoxA(0, 'Result is all good', '', 0);
end;

Procedure Direct3DCreate9Ex; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.Direct3DCreate9Ex]
end;

Procedure Direct3DShaderValidatorCreate9; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.Direct3DShaderValidatorCreate9]
end;

Procedure PSGPError; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.PSGPError]
end;

Procedure PSGPSampleTexture; stdcall; Assembler; NoStackFrame;
{$ASMMODE INTEL}
asm
  jmp [d3d9.PSGPSampleTexture]
end;


end.
