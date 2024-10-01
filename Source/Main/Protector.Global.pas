unit Protector.Global;

{$I Default.inc}

interface

uses
  Winapi.Windows,
  Winapi.WinSock,
  SourceSDK,
  Protector.LocalMasterServer;

const
  IniSectionName: PAnsiChar = 'steamclient';
  IniKeyName: PAnsiChar = 'PlayerName';
  IniFileName: PAnsiChar = '.\rev.ini';

var
  EngineBase, LauncherBase, ClientBase, Tier0Base, GameUIBase, SCBase, SBBase, WSBase: Pointer;
  EngineSize, LauncherSize, ClientSize, Tier0Size, GameUISize, SCSize, SBSize, WSSize: Cardinal;

  GameUI011: PIGameUI011;

  sendto_Orig: function(s: TSocket; var Buf; len, flags: Integer; var addrto: TSockAddr;
    tolen: Integer): Integer; stdcall;
  send_Orig: function(s: TSocket; const Buf; len, flags: Integer): Integer; stdcall;
  recv_Orig: function(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
  connect_Orig: function(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
  recvfrom_Orig: function(s: TSocket; var Buf; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;

var
  malloc_org: function(Size: Integer): Pointer; cdecl;

  MasterServerInited: Boolean = False;

const
{$IFDEF CSGOMY}
  // ms.csgo-my.ru
  MasterServerAddr: array[0..12] of LongWord = ($1DE2035F, $834E7C56, $2CF817E8,
    $B3AF65AB, $834E7C56, $F77727A4, $7F86A25A,
    $DD6724EB, $1DE2035F, $29395951, $2CF817E8,
    $B03C0D59, $E5729F55);

var
  MasterServerPort: Word = 27010 xor $3333;
{$ELSE}
  // csgo.cs-love.club
  MasterServerAddr: array[0..16] of LongWord = ($B3AF65AB, $834E7C56, $F77727A4,
    $7F86A25A, $2CF817E8, $B3AF65AB, $834E7C56,
    $DD6724EB, $0A50D05E, $7F86A25A, $F484CE52,
    $955384A6, $2CF817E8, $B3AF65AB, $0A50D05E,
    $E5729F55, $A01D3AAA);

var
  MasterServerPort: Word = 27011 xor $3333;
{$ENDIF}

var
  MasterServerIPv4: Integer = $00000000;
  MasterRequest: AnsiString = '1'#$FF'0.0.0.0:0'#0'\gamedir\csgo\region\255\gametagsnor\valve_ds\gametype\no-steam'#0;

  LocalMaster: TLocalMaster;

  LastServerUpdate: Cardinal = 0;

  Cmd_Name: Pointer;
  SteamclientName: PAnsiChar;
  m_pConCommandList: Pointer;

  Msg, Warning, Log: procedure(Format: PAnsiChar); cdecl varargs;
  CreateInterfaceE: CreateInterfaceFn;
  CreateInterfaceL: CreateInterfaceFn;
  CreateInterfaceG: CreateInterfaceFn;

  CVEngineCvar003: PICvar003;
  CVEngineCvar004: PICvar004;
  GameConsole003: PIGameConsole003;
  GameConsole004: PIGameConsole004;
  VENGINETOOL001: PIEngineTool003;

  CCPseudoInterface: procedure(Name: PAnsiChar; Callback: Pointer; Description: PAnsiChar; Flags: LongWord; Completion: Pointer); stdcall;
  CVarPseudoInterface: procedure(Name, Value: PAnsiChar; Flags: LongWord; Desc: PAnsiChar; Completion: Pointer); stdcall;

// CServerBrowser::m_pInternetGames offset is 592
// CServerBrowser is actually s_InternetDlg
// s_InternetDlg is in CServerBrowserDialog::CServerBrowserDialog
// s_InternetDlg address is serverbrowser+$E480C
// CInternetGames::ServerResponded address is serverbrowser+$16CE0
//
// CUtlMap::Find address is serverbrowser+$A820
// m_mapServerIP address is CInternetGames(this)+$560

var
  InternetDlg: Pointer = nil;
  FriendsGames: Pointer;
  FriendsGames_GameList: Pointer;
  FriendsGames_Button_RefreshAll: Pointer;

  IsFirstFriendsRefresh: Boolean = True;

{$REGION 'Winapi Specified'}
const
  GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = $00000004;

function GetModuleHandleExA(Flags: Cardinal; ModuleName: PAnsiChar; out Module: HMODULE): BOOL; stdcall; external kernel32;
function GetModuleHandleExW(Flags: Cardinal; ModuleName: PWideChar; out Module: HMODULE): BOOL; stdcall; external kernel32;
{$ENDREGION}

implementation

end.

