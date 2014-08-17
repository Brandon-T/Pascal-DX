library DXI;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Windows, Direct3D9, D3DProxy, ExportInfo, SmartPlugin,
  DXHooks;

procedure DllMain(Reason: PtrInt);
begin
  Case Reason Of
    DLL_PROCESS_ATTACH:
    begin
      Initialize();
      Exit;
    end;

    DLL_PROCESS_DETACH:
    begin
      DeInitialize();
      Exit;
    end;
  end;
end;


exports SMARTPluginInit;
exports D3DPERF_BeginEvent;
exports D3DPERF_EndEvent;
exports D3DPERF_GetStatus;
exports D3DPERF_QueryRepeatFrame;
exports D3DPERF_SetMarker;
exports D3DPERF_SetOptions;
exports D3DPERF_SetRegion;
exports DebugSetLevel;
exports DebugSetMute;
exports Direct3DCreate9;
exports Direct3DCreate9Ex;
exports Direct3DShaderValidatorCreate9;
exports PSGPError;
exports PSGPSampleTexture;

var
  called: boolean = false;
begin
  Dll_Process_Detach_Hook := @DllMain;
  if (not called) then
  begin
    DllMain(DLL_PROCESS_ATTACH);
    called := true;
  end;
end.

