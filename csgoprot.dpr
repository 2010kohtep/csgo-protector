library csgoprot;

{$I Default.inc}



uses
  {$REGION}
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.WinSock,
  Protector.Engine.Routines in 'Source\Main\Protector.Engine.Routines.pas',
  Protector.Engine.Search in 'Source\Main\Protector.Engine.Search.pas',
  Protector.Global in 'Source\Main\Protector.Global.pas',
  Protector.LocalMasterServer in 'Source\Main\Protector.LocalMasterServer.pas',
  Protector.ServerBrowser.SortOrder in 'Source\Main\Protector.ServerBrowser.SortOrder.pas',
  Protector.Winapi.Hooks in 'Source\Main\Protector.Winapi.Hooks.pas',
  Protector.Winapi.Routines in 'Source\Main\Protector.Winapi.Routines.pas',
  Protector.Birzyk.ServerBrowser in 'Source\Main\Protector.Birzyk.ServerBrowser.pas',
  Protector.Common in 'Source\Main\Protector.Common.pas',
  Protector.Emulator in 'Source\Main\Protector.Emulator.pas',
  Protector.Engine.Cmds in 'Source\Main\Protector.Engine.Cmds.pas',
  Steam.API in 'Source\Public\Steam.API.pas',
  Winapi.Native in 'Source\Public\Winapi.Native.pas',
  SourceSDK in 'Source\Public\SourceSDK.pas',
  SynaIP in 'Source\Synapse\SynaIP.pas',
  SynaUtil in 'Source\Synapse\SynaUtil.pas',
  SynSock in 'Source\Synapse\SynSock.pas',
  BlckSock in 'Source\Synapse\BlckSock.pas',
  HTTPSend in 'Source\Synapse\HTTPSend.pas',
  SSL_OpenSSL in 'Source\Synapse\SSL_OpenSSL.pas',
  SSL_OpenSSL_Lib in 'Source\Synapse\SSL_OpenSSL_Lib.pas',
  SynaCode in 'Source\Synapse\SynaCode.pas',
  SynaFPC in 'Source\Synapse\SynaFPC.pas',
  Xander.Memory.Fundamental in 'Source\Xander\Xander.Memory.Fundamental.pas',
  Xander.Memory in 'Source\Xander\Xander.Memory.pas',
  Xander.Memory.Segments in 'Source\Xander\Xander.Memory.Segments.pas',
  Xander.Memory.Windows in 'Source\Xander\Xander.Memory.Windows.pas',
  Xander.MiniUDP in 'Source\Xander\Xander.MiniUDP.pas',
  Xander.MsgAPI in 'Source\Xander\Xander.MsgAPI.pas',
  Xander.RevFix in 'Source\Xander\Xander.RevFix.pas',
  Xander.StringList in 'Source\Xander\Xander.StringList.pas',
  Xander.ThisWrap in 'Source\Xander\Xander.ThisWrap.pas',
  Xander.Buffer in 'Source\Xander\Xander.Buffer.pas',
  Xander.ClassInformer in 'Source\Xander\Xander.ClassInformer.pas',
  Xander.Console in 'Source\Xander\Xander.Console.pas',
  Xander.CPUID in 'Source\Xander\Xander.CPUID.pas',
  Xander.DllCallback in 'Source\Xander\Xander.DllCallback.pas',
  Xander.Exception in 'Source\Xander\Xander.Exception.pas',
  Xander.Git.Info in 'Source\Xander\Xander.Git.Info.pas',
  Xander.Helpers in 'Source\Xander\Xander.Helpers.pas',
  Xander.IfThen in 'Source\Xander\Xander.IfThen.pas',
  Xander.LdrMonitor in 'Source\Xander\Xander.LdrMonitor.pas',
  Protector.Exception in 'Source\Main\Protector.Exception.pas',
  Xander.StrCrypt in 'Source\Xander\Xander.StrCrypt.pas';

{$ENDREGION}

function Init: Boolean; inline;
begin
  CreateMutex(nil, False, 'CSGO-Protector');
  Result := GetLastError <> ERROR_ALREADY_EXISTS;
end;

procedure InitMasterServer;
var
  Port: Word;
  S: AnsiString;
begin
  if not MasterServerInited then
  begin
    S := DecodeString(MasterServerAddr);

    MasterServerIPv4 := DomainToInt(S);

    if MasterServerIPv4 = -1 then
    begin
    {$IFDEF DEBUG}
      TConsole.Error('WARNING! DomainToInt received -1');
    {$ENDIF}
      Exit;
    end;

    Port := MasterServerPort;
    Port := Port xor $3333;
    MasterServerPort := Port;

    {$I Obfuscation-1.inc}

    MasterServerInited := True;

  {$IFDEF DEBUG}
    if MasterServerIPv4 <> 0 then
      TConsole.Success('Master server inited. Address: %s:%d', [inet_ntoa(TInAddr(MasterServerIPv4)), Port]);
  {$ENDIF}
  end;

  {$I Obfuscation-2.inc}
end;

procedure Hook_CDialogGameInfo_AddPlayerToList; forward;

function GetHSteamPipe: HSteamPipe; stdcall; external 'steam_api.dll';
function GetHSteamUser: HSteamUser; stdcall; external 'steam_api.dll';

const
  STEAMMATCHMAKING_INTERFACE_VERSION: PAnsiChar = 'SteamMatchMaking009';
  STEAMMATCHMAKINGSERVERS_INTERFACE_VERSION: PAnsiChar = 'SteamMatchMakingServers002';

var
  ServerInfo: Pointer = Pointer(-1);

var
  SteamMatchmaking: PVSteamMatchmaking;
  SteamMatchmakingServers: PSteamMatchmakingServers;

function hkGetServerDetails(Request: HServerListRequest; Server: Integer): PGameServerItem; stdcall;
begin
  if ServerInfo = Pointer(-1) then
  begin
    ServerInfo := FindPattern(SCBase, SCSize, [$8B, $40, $60, $5D, $FF, $E0, $B8], 7);

    if ServerInfo <> nil then
      ServerInfo := PPointer(ServerInfo)^;
  end;

  Result := ServerInfo;
end;

function hkRequestInternetServerList(App: TAppId; Filters: PPMatchMakingKeyValuePair; FilterCount: Cardinal; RequestServersResponse: PISteamMatchmakingServerListResponse): HServerListRequest; stdcall;
begin
  Result := HServerListRequest(0);
end;

function GetSteamMatchmaking(var ASteamMatchmaking: PVSteamMatchmaking; var ASteamMatchmakingServers: PSteamMatchmakingServers): Boolean;
var
  P: function(Name: PAnsiChar; Error: PInteger): Pointer; cdecl;
  SteamClient: PISteamClient;

  User: HSteamUser;
  Pipe: HSteamPipe;

  D: Pointer;
begin
  @P := GetProcAddress(HMODULE(SCBase), 'CreateInterface');

  if @P = nil then
    Exit(False);

  SteamClient := P('SteamClient017', nil);

  if SteamClient = nil then
    Exit(False);

  Pipe := GetHSteamPipe;
  User := GetHSteamUser;

  asm
    push [STEAMMATCHMAKING_INTERFACE_VERSION]
    push [Pipe]
    push [User]
    mov ecx, [SteamClient]
    mov eax, [ecx]
    call [eax].ISteamClient.GetISteamMatchmaking
    mov [D], eax
  end;

  ASteamMatchmaking := D;

  asm
    push [STEAMMATCHMAKINGSERVERS_INTERFACE_VERSION]
    push [Pipe]
    push [User]
    mov ecx, [SteamClient]
    mov eax, [ecx]
    call [eax].ISteamClient.GetISteamMatchmakingServers
    mov [D], eax
  end;

  ASteamMatchmakingServers := D;

  Result := True;
end;

procedure F;
var
  GetServerDetails: Pointer;
begin
  if not GetSteamMatchmaking(SteamMatchmaking, SteamMatchmakingServers) then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('[Error] Could not get SteamMatchmaking.');
  {$ENDIF}

    Exit;
  end;

{$IFDEF DEBUG}
  TConsole.Important('[SteamMatchmaking] SteamMatchmaking - %s', [IntToHex(Integer(SteamMatchmaking), 8)]);
  TConsole.Important('[SteamMatchmaking] SteamMatchmakingServers - %s', [IntToHex(Integer(SteamMatchmakingServers), 8)]);
{$ENDIF}

  GetServerDetails := Transpose(PPointer(SteamMatchmaking)^, 28, True);
  WritePointer(Transpose(PPointer(SteamMatchmaking)^, 28), @hkGetServerDetails);

  //WritePointer(@@SteamMatchmakingServers.VTable.RequestInternetServerList, @hkRequestInternetServerList);
end;

procedure InitSteamHooks;
begin
  if not BirzykStubInited then
    BirzykStub;
end;

var
  orgCDialogGameInfo_AddPlayerToList: Pointer = nil;
  CDialogGameInfo_AddPlayerToList_Internal_Result: Boolean = False;

procedure hkCDialogGameInfo_AddPlayerToList_Internal(This: Pointer; Score: Integer; TimePlayedSeconds: Single; PlayerName: PAnsiChar); stdcall;
var
  Addr: Pointer;
begin
  Addr := Transpose(This, $58);
  Addr := PPointer(Addr)^;
  Addr := PPointer(Addr)^;

  if (Integer(Addr) and $0000FFF0 <> $2630) and (Integer(Addr) and $0000FFF0 <> $3900) then
  begin
{$IFDEF DEBUG}
    TConsole.Error('CDialogGameInfo::AddPlayerToList: Incorrect virtual table in object (%08X), exiting...', [Integer(Addr)]);
{$ENDIF}

    CDialogGameInfo_AddPlayerToList_Internal_Result := False;
  end
  else
  begin
    CDialogGameInfo_AddPlayerToList_Internal_Result := True;
  end;
end;

procedure hkCDialogGameInfo_AddPlayerToList(TimePlayedSeconds: Single; Score: Integer; PlayerName: PAnsiChar); stdcall;
asm
  pushad

  push [PlayerName]
  push [Score]
  push [TimePlayedSeconds]
  push ecx
  call hkCDialogGameInfo_AddPlayerToList_Internal

  popad

  pop ebp

  cmp byte ptr [CDialogGameInfo_AddPlayerToList_Internal_Result], 0
  je @Skip
    jmp [orgCDialogGameInfo_AddPlayerToList]

@Skip:
  ret 12
end;

procedure Hook_CDialogGameInfo_AddPlayerToList;
var
  P: Pointer;
  PRef: Pointer;
begin
  P := FindPattern(SBBase, SBSize, [$55, $8B, $EC, $83, $EC, $44, $53, $8B, $D9, $57, $80]);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Hook_CDialogGameInfo_AddPlayerToList: Failed #1');
  {$ENDIF}
    Exit;
  end;

  PRef := FindRefAddr(SBBase, SBSize, P);
  if PRef = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Hook_CDialogGameInfo_AddPlayerToList: Failed #2');
  {$ENDIF}
    Exit;
  end;

  orgCDialogGameInfo_AddPlayerToList := P;
  WritePointer(PRef, @hkCDialogGameInfo_AddPlayerToList);
end;

procedure InitProt;
var
  WSA: TWSAData;
begin
{$IFDEF DEBUG}
  Protector.Exception.Init;
{$ENDIF}

{$IFDEF DEBUG}
  TConsole.Important('Initializing protector...');
{$ENDIF}

{$IFDEF DEBUG}
  if WSAStartup($0202, WSA) <> 0 then
    TConsole.Error('WARNING! Could not start WinSock interface. Error code: %s', [WSAGetLastError]);
{$ELSE}
  WSAStartup($0202, WSA);
{$ENDIF}

  InitMasterServer;

  LocalMaster := TLocalMaster.Create;

  if MasterServerInited then
  begin
    try
      LocalMaster.LoadFromMaster(LongToIP(MasterServerIPv4), MasterServerPort, MasterRequest, '');
      LastServerUpdate := GetTickCount;
    except
    {$IFDEF DEBUG}
      on E: Exception do
        TConsole.Error('LocalMaster.LoadFromMaster: %s', [E.Message]);
    {$ENDIF}
    end;
  end;

{$IFDEF DEBUG}
  TConsole.Important('Searching modules...');
{$ENDIF}

  FindModules;

{$IFDEF DEBUG}
  TConsole.Important('Search done.');
{$ENDIF}

  InitSteamHooks;

{$IFDEF DEBUG}
  TConsole.Success('Protector inited.');
{$ENDIF}
end;

procedure RevFixOnError(Code: Integer) cdecl;
var
  Msg: string;
begin
{$IFDEF DEBUG}
  TConsole.Important('RevFixOnError: Called');
{$ENDIF}

  Msg := Format('Could not set HWID. Code: %d', [Code]);
  MessageBox(HWND_DESKTOP, PChar(Msg), 'Fatal Error', MB_ICONWARNING or MB_SYSTEMMODAL);
end;

function RevFixOnBegin: Boolean; cdecl;
begin
{$IFDEF DEBUG}
  TConsole.Important('RevFixOnBegin: Called');
{$ENDIF}

//  if not BirzykStubInited then
//    BirzykStub;

  Exit(True);
end;

procedure InitRevFix;
var
  Msg: string;
  Code: Integer;
begin
  Code := Xander.RevFix.Init;

  if Code <> RF_NO_ERROR then
  begin
    Msg := Format('Could not initialize emulator fix. Code: %d', [Code]);
    MessageBox(HWND_DESKTOP, PChar(Msg), 'Fatal Error', MB_ICONWARNING or MB_SYSTEMMODAL);
    Exit;
  end;

  SetOnError(RevFixOnError);
  SetOnBegin(RevFixOnBegin);
end;

procedure MakeServerBrowserAsInternet;
const
  SBFILE = 'platform\config\serverbrowser.vdf';
var
  List: TStringList;
begin
  if not FileExists(SBFILE) then
    Exit;

  List := TStringList.Create;

  try
    List.LoadFromFile(SBFILE);
    List.Text := StringReplace(List.Text, '"friends"', '"internet"', [rfIgnoreCase]);
    List.Text := StringReplace(List.Text, '"favorites"', '"internet"', [rfIgnoreCase]);
    List.SaveToFile(SBFILE);
  except
  {$IFDEF DEBUG}
    on E: Exception do
      TConsole.Error('MakeServerBrowserAsInternet: %s', [E.Message]);
  {$ENDIF}
  end;

  List.Free;

{$IFDEF DEBUG}
  TConsole.Success('MakeServerBrowserAsInternet: Default tab successfully changed to "internet"');
{$ENDIF}
end;

procedure MakeServerBrowserAsFriends;
const
  SBFILE = 'platform\config\serverbrowser.vdf';
var
  List: TStringList;
begin
  if not FileExists(SBFILE) then
    Exit;

  List := TStringList.Create;

  try
    List.LoadFromFile(SBFILE);
    List.Text := StringReplace(List.Text, '"internet"', '"friends"', [rfIgnoreCase]);
    List.Text := StringReplace(List.Text, '"favorites"', '"friends"', [rfIgnoreCase]);
    List.SaveToFile(SBFILE);
  except
  {$IFDEF DEBUG}
    on E: Exception do
      TConsole.Error('MakeServerBrowserAsFriends: %s', [E.Message]);
  {$ENDIF}
  end;

  List.Free;

{$IFDEF DEBUG}
  TConsole.Success('MakeServerBrowserAsFriends: Default tab successfully changed to "friends"');
{$ENDIF}
end;

var
  CServerBrowserDialog_CServerBrowserDialog: function(_EAX, _EDX: Integer; This: Pointer; Parent: Pointer): Pointer; register;
  CServerBrowser_Activate: function(_EAX, _EDX: Integer; This: Pointer): Boolean; register;
  ButtonClick: Pointer;

function hkCServerBrowser_Activate(_EAX, _EDX: Integer; This: Pointer): Boolean; register;
begin
  Result := CServerBrowser_Activate(0, 0, This);

  ThisCall(FriendsGames_Button_RefreshAll, ButtonClick);
end;

procedure Hook_CServerBrowser_Activate;
var
  P: Pointer;
begin
  P := FindPattern(SBBase, SBSize, [$55, $8B, $EC, $51, $80, $3D]);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not find CServerBrowser::Activate method.');
  {$ENDIF}
    Exit;
  end;

  @CServerBrowser_Activate := P;

  if HookRefJump(SBBase, SBSize, @CServerBrowser_Activate, @hkCServerBrowser_Activate) = 0 then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not hook CServerBrowser::Activate method in first hook cycle.');
  {$ENDIF}
    Exit;
  end;

  if HookRefAddr(SBBase, SBSize, @CServerBrowser_Activate, @hkCServerBrowser_Activate, True) = 0 then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not hook CServerBrowser::Activate method in second hook cycle.');
  {$ENDIF}
    Exit;
  end;
end;

function hkCServerBrowserDialog_CServerBrowserDialog(_EAX, _EDX: Integer; This: Pointer; Parent: Pointer): Pointer; register;
var
  P: Pointer;
begin
  Result := CServerBrowserDialog_CServerBrowserDialog(0, 0, This, Parent);
  InternetDlg := Result;

{$IFDEF DEBUG}
  TConsole.Success('InternetDlg found - %.08X', [Integer(InternetDlg)]);
{$ENDIF}

  P := InternetDlg;
  FriendsGames := Transpose(P, 604, True);
  FriendsGames_GameList := Transpose(FriendsGames, 464, True);
  FriendsGames_Button_RefreshAll := Transpose(FriendsGames, 480, True);

  ButtonClick := FindPattern(SBBase, SBSize, [$8B, $01, $FF, $A0, $14, $04, $00, $00]);
end;

procedure Hook_CServerBrowserDialog_Constructor;
var
  P: Pointer;
begin
  P := FindPattern(SBBase, SBSize, [$55, $8B, $EC, $83, $EC, $10, $53, $56, $57, $51, $6A, $01]);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not find CServerBrowserDialog::CServerBrowserDialog method.');
  {$ENDIF}
    Exit;
  end;

  @CServerBrowserDialog_CServerBrowserDialog := P;

  if HookRefCall(SBBase, @CServerBrowserDialog_CServerBrowserDialog, @hkCServerBrowserDialog_CServerBrowserDialog) = 0 then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not hook CServerBrowserDialog::CServerBrowserDialog method.');
  {$ENDIF}
    Exit;
  end;
end;

procedure Hook_ServerBrowser;
begin
  Find_KeyValues_FindKey;
  Find_Mov_AscendingSortFunc;

  Hook_CInternetGames_GetNewServerList;
  Hook_CInternetGames_RefreshComplete;

  Hook_CFriendsGames_RefreshComplete;
  Hook_CFriendsGames_CheckPrimaryFilters;
  Hook_CFriendsGames_GetNewServerList;

  Hook_CDialogGameInfo_ServerResponded;
  Hook_CDialogGameInfo_ServerFailedToRespond;

  Hook_CDialogGameInfo_AddPlayerToList;

  Hook_CServerBrowserDialog_Constructor;
  Hook_CServerBrowser_Activate;

  Hook_AscendingSortFunc;

  Patch_SortFunc;
end;

procedure DllCallback(const Name: string; Base: Pointer); register;
var
  GenName: string;
begin
  GenName := ExtractFileName(Name);
  GenName := LowerCase(GenName);

  if SameText('serverbrowser.dll', GenName) then
  begin
    SBBase := Base;
    SBSize := GetModuleSize(Base);

  {$IFDEF DEBUG}
    TConsole.Important('DllCallback: %s', [GenName]);
  {$ENDIF}

    Hook_ServerBrowser;
  end;
end;

function DestroyHeaders(Module: HMODULE): Boolean;
var
  DOS: PImageDosHeader;
  OldProtect: Cardinal;
begin
  DOS := Pointer(Module);

  if DOS.e_magic <> IMAGE_DOS_SIGNATURE then
    Exit(False);

  if not VirtualProtect(DOS, $1000, PAGE_READWRITE, OldProtect) then
    Exit(False);

  FillChar(DOS^, $1000, 0);

  if not VirtualProtect(DOS, $1000, OldProtect, OldProtect) then
    Exit(False);

  {$I Obfuscation-2.inc}

  Exit(True);
end;

function UnlinkModule(Module: HMODULE): Boolean;

  procedure Unlink(var Entry: TListEntry);
  begin
    Entry.Flink.Blink := Entry.Blink;
    Entry.Blink.Flink := Entry.Flink;
  end;

var
  Peb: PPeb;
  Ldr: PPebLdrData;
  FList, List: PLdrModule;
begin
  {$I Obfuscation-1.inc}

  asm
    mov eax, fs:[$30]
    mov Peb, eax
  end;

  Ldr := Peb.Ldr;
  List := Pointer(Ldr.InLoadOrderModuleList.Flink);
  FList := List;

  repeat
    {$I Obfuscation-2.inc}

    if List.BaseAddress = Pointer(Module) then
    begin
      Unlink(List.InLoadOrderModuleList);
      Unlink(List.InMemoryOrderModuleList);
      Unlink(List.InInitializationOrderModuleList);
      Unlink(List.HashTableEntry);

      Exit(True);
    end;

    List := Pointer(List.InLoadOrderModuleList.Flink);
  until List = FList;

  Exit(False);
end;

procedure HideSelf;
begin
  {$I Obfuscation-2.inc}

  //DestroyHeaders(HInstance);
  UnlinkModule(HInstance);
  DisableThreadLibraryCalls(HInstance);
end;

begin
{$IFDEF DEBUG}
  AllocConsole;
  TConsoleBasic.Init(True);
{$ENDIF}

{$IFDEF VDFFIX}
  MakeServerBrowserAsFriends;
{$ENDIF}

{$IFDEF SSDFIX}
  InitRevFix;
{$ENDIF}

  HideSelf;

  //DisableThreadLibraryCalls(HInstance);

  Xander.DllCallback.Setup(DllCallback);

  if Init then
    BeginThread(nil, 0, @InitProt, nil, 0, PCardinal(nil)^)
  else
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not start protector initialization thread.');
  {$ENDIF}
  end;
end.
