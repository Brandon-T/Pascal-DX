library DXI;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Windows, Direct3D9, SmartPlugin, D3DDevice9Proxy, D3DProxy,
  ExportInfo;

procedure EntryPoint(Reason: DWORD);
begin
  Case Reason Of
    DLL_PROCESS_ATTACH:
    begin
      Initialize();
    end;

    DLL_PROCESS_DETACH:
    begin
      Texture._Release();
      DeInitialize();
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

begin
  EntryPoint(DLL_PROCESS_ATTACH);
end.
