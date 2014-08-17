unit DXHooks;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Windows, SmartPlugin, Direct3D9;


Procedure EndSceneHook(ptr_Direct3DDevice9: IDirect3DDevice9);

implementation

Procedure EndSceneHook(ptr_Direct3DDevice9: IDirect3DDevice9);
var
  weakRef_Direct3DDevice9: IDirect3DDevice9;
  block: IDirect3DStateBlock9;
  {Ptr: Pointer;
  Mini: Boolean;
  W, H: Integer;
  Fmt: D3DFormat;}
  X, Y: Integer;
  Minimised: Boolean;
begin
  Minimised := False;
  weakRef_Direct3DDevice9 :=  IDirect3DDevice9(ptr_Direct3DDevice9);

  if (SmartGlobal^.Version >= $08010000) then
  begin
    dxReadPixels(weakRef_Direct3DDevice9, SmartGlobal^.img, Minimised, SmartGlobal^.width, SmartGlobal^.height);
    weakRef_Direct3DDevice9.CreateStateBlock(D3DSBT_ALL, block);
    block.Capture();

    weakRef_Direct3DDevice9.SetRenderState(D3DRS_LIGHTING, D3DZB_FALSE);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_FOGENABLE, D3DZB_FALSE);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_ALPHABLENDENABLE, D3DZB_FALSE); //DISABLED 2014-02-28..
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_BLENDOP, D3DBLENDOP_ADD);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
    weakRef_Direct3DDevice9.SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);

    if (SmartDebugEnabled and (Not Minimised)) then
       BltSmartBuffer(weakRef_Direct3DDevice9);

    X := -1; Y := -1;
    SmartGlobal^.getMousePos(X, Y);

    if ((X > -1) and (Y > -1)) then
    begin
      //weakRef_Direct3DDevice9^.SetRenderState(D3DRS_ZFUNC,D3DCMP_NEVER);
      weakRef_Direct3DDevice9.SetTexture(0, nil);
      weakRef_Direct3DDevice9.SetPixelShader(nil);
      weakRef_Direct3DDevice9.SetVertexShader(nil);
      DrawCircle(weakRef_Direct3DDevice9, X, Y, 2.5);
    end;

    block.Apply();
    block._Release();
  end;
end;

end.

