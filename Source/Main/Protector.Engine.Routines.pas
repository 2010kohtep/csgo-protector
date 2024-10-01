unit Protector.Engine.Routines;

{$I Default.inc}

interface

uses
  HTTPSend,
  {$IFDEF USE_SSL}
  SSL_OpenSSL,
  {$ENDIF}

  System.SysUtils,
  System.Classes,
  System.AnsiStrings,

  Winapi.Windows,
  Winapi.WinSock,
  Protector.Winapi.Routines,

  Xander.MsgAPI,
  Xander.Memory,

  Protector.Global,
  Protector.Common,
  Protector.ServerBrowser.SortOrder;

procedure Hook_WS2_32;

implementation

uses
  Protector.Emulator;

var
  ServerListInited: Boolean = False;

procedure Hook_WS2_32;
begin
  sendto_Orig := HookWinAPI(GetProcAddress(Cardinal(WSBase), 'sendto'), @hksendto);
  recvfrom_Orig := HookWinAPI(GetProcAddress(Cardinal(WSBase), 'recvfrom'), @hkrecvfrom);

{$IFDEF DEBUG}
  if @sendto_Orig <> nil then
    WriteLn('sendto successfully hooked.')
  else
    WriteLn('Could not hook sendto, may cause problems with server list.');
{$ENDIF}
end;

end.
