(*=========== (C) Copyright 2017, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Имя модуля:                                                                *)
(*   Protector.ServerBrowser.SortOrder                                         *)
(*                                                                             *)
(*  Описание:                                                                  *)
(*    Данный модуль внедряет собственный способ сортировки в сервербраузер.    *)
(*=============================================================================*)

unit Protector.ServerBrowser.SortOrder;

{$I Default.inc}

interface

uses {$REGION 'Includes'}
  System.Types,
  System.SysUtils,
  System.AnsiStrings,
  Winapi.Windows,
  Winapi.WinSock,

  Protector.Common,
  Protector.Global,
  Protector.Winapi.Hooks,

  Xander.Memory,
  Xander.ThisWrap,
  Xander.MiniUDP,
  Xander.Buffer,
  Xander.StringList,
  Xander.ClassInformer,
  Xander.Console,

  HTTPSend,
  {$IFDEF USE_SSL}
  SSL_OpenSSL,
  {$ENDIF}

  System.Generics.Collections; {$ENDREGION}

{$REGION 'Types'}

type
  TNetAdr = record
    ConnectionPort: Word;
    QueryPort: Word;
    IP: LongWord;
  end;

  PGameServerItem = ^TGameServerItem;
  TGameServerItem = record
    NetAdr: TNetAdr;
    Ping: Integer;
    HadSuccessfulResponse: Boolean;
    DoNotRefresh: Boolean;
    GameDir: array[0..31] of AnsiChar;
    Map: array[0..31] of AnsiChar;
    GameDescription: array[0..63] of AnsiChar;
    AppID: Integer;
    Players: Integer;
    MaxPlayers: Integer;
    BotPlayers: Integer;
    Password: Boolean;
    Secure: Boolean;
    TimeLastPlayed: LongWord;
    ServerVersion: Integer;
    ServerName: array[0..63] of AnsiChar;
    GameTags: array[0..127] of AnsiChar;
  end;

procedure Find_KeyValues_FindKey;
procedure Find_Mov_AscendingSortFunc;
procedure Find_s_CurrentSortingListPanel;

procedure Hook_ListPanel_RBTreeLessFunc;
procedure Hook_CInternetGames_GetNewServerList;
procedure Hook_CFriendsGames_CheckPrimaryFilters;
procedure Hook_CInternetGames_RefreshComplete;
procedure Hook_CFriendsGames_GetNewServerList;
procedure Hook_CFriendsGames_RefreshComplete;
procedure Hook_AscendingSortFunc;

procedure Patch_SortFunc;

type
  TServer = record
    IP: Cardinal;
    Port: Word;

    ConnectionPort: Word;

    class function Create(IP: Cardinal; Port: Word): TServer; static;
  end;

  TServerList = TList<TServer>;

  TMasterServerParser = class(TMiniUDP)
  private
    FMasterAddress: string;
    FServerList: TServerList;
    FRefreshing: Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    procedure PrintList;

    procedure RequestList(const Addr: string; const Query: string; const Address: string); overload;
    procedure RequestList(const IP: string; Port: Word; const Query: string; const Address: string); overload;
    procedure RequestList(const URL: string); overload;

    function GetServerIndex(IP: Cardinal; Port: Word): Integer;

    function SetConnectionPort(IP: Cardinal; Port: Word; Value: Word): Boolean;
    function GetConnectionPort(IP: Cardinal; Port: Word): Word;

    procedure WaitWhileRefreshing(Tries: Integer; Milliseconds: Integer);

    procedure SetUpdateForcely;

    procedure OnReadUDP(var Buffer: TBuffer); override;

    property List: TServerList read FServerList;
  end;

type
  KeyValueType = (None, Str, Int, Float, Ptr, WStr, Color, UInt64);

  PVKeyValues = ^VKeyValues;
  VKeyValues = record

  end;

  PKeyValues = ^KeyValues;

  DKeyValues = record
    KeyName: Integer;

    StrValueA: PAnsiChar;
    StrValueW: PWideChar;

    KeyValue: record
      case Byte of
        0: (Integer: Integer);
        1: (Float: Single);
        2: (Ptr: Pointer);
        3: (Color: Integer);
      end;

    DataType: KeyValueType;
    HasEscapeSequences: Byte;
    Unused: Word;

    Peer: PKeyValues;
    Sub: PKeyValues;
    Chain: PKeyValues;
  end;

  KeyValues = record
    //VTable: PVKeyValues;
    Data: DKeyValues;
  end;

  PListPanelItem = ^ListPanelItem;
  ListPanelItem = record
    KV: PKeyValues;
    UserData: Cardinal;
    DragData: Pointer;
    Image: Boolean;
    ImageIndex: Integer;
    ImageIndexSelected: Integer;
    Icon: Pointer;
  end;

  HKeySymbol = Integer;

  PVKeyValuesSystem = ^VKeyValuesSystem;
  VKeyValuesSystem = record
    // KeyValuesSystem наследуется от IBaseInterface в 1.6,
    // поэтому зде необходим виртуальный деструктор.
    Destroy: procedure(Dispose: Boolean); stdcall;

    RegisterSizeofKeyValues: procedure(Size: Integer); stdcall;
    AllocKeyValuesMemory: function(Size: Integer): Pointer; stdcall;
    FreeKeyValuesMemory: procedure(Mem: Pointer); stdcall;
    GetSymbolForString: function(Name: PAnsiChar; Create: Boolean): HKeySymbol; stdcall;

    // Функция не имеет кода в 1.6.
    GetStringForSymbol: function(Symbol: HKeySymbol): PAnsiChar; stdcall;
    // Функция не имеет кода в 1.6.
    AddKeyValuesToMemoryLeakList: procedure(Mem: Pointer; Name: HKeySymbol); stdcall;

    RemoveKeyValuesFromMemoryLeakList: procedure(Mem: Pointer); stdcall;
  end;

  PIKeyValuesSystem = ^IKeyValuesSystem;
  IKeyValuesSystem = record
    VTable: PVKeyValuesSystem;
  end;

{$ENDREGION}

implementation

uses
  Protector.Emulator, Protector.Engine.Routines;

type
  TCBaseGamesPage_RefreshComplete = procedure(_EAX, _EDX: Pointer; This: Pointer; Response: Integer; Request: Integer); register;

var
  InternetGamesObject: Pointer = nil;

var
  OFFSET_VTABLE_GETITEMDATA: Integer = 0;

var
  orgKeyValues_FindKey: Pointer;
  orgListPanel_RBTreeLessFunc: Pointer;
  orgMov_AscendingSortFunc: Pointer;
  orgAscendingSortFunc: Pointer;

  CInternetGames_GetNewServerList_Org: procedure(_EAX, _EDX: Pointer; This: Pointer); register;
  // its actually CBaseGamesPage::StartRefresh
  CFriendsGames_GetNewServerList_Org: procedure(_EAX, _EDX: Pointer; This: Pointer); register;

  CInternetGames_RefreshComplete_Org: TCBaseGamesPage_RefreshComplete;
  CFriendsGames_RefreshComplete_Org: TCBaseGamesPage_RefreshComplete;

  CFriendsGames_CheckPrimaryFilters_Org: function(_EAX, _EDX: Pointer; This: Pointer; Server: Pointer): Boolean; register;

  s_CurrentSortingListPanel: Pointer;
  GetItemData: function(_EAX, _EDX: Pointer; This: Pointer; Index: Integer): Pointer; register;

{$REGION 'Helpers'}

function KeyValuesSystem: PIKeyValuesSystem; stdcall; external 'vstdlib.dll';

function GetAddrForListPanelItem(Item: PListPanelItem; var IP: string; var Port: Word): Boolean;
var
  KV: PKeyValues;
  Addr: array[0..255] of AnsiChar;
begin
  if orgKeyValues_FindKey = nil then
    Exit(False);

  IP := '';
  Port := 0;

  if Item = nil then
    Exit(False);

  // KeyValues::FindKey
  KV := ThisCall(Item.KV, orgKeyValues_FindKey, PAnsiChar('IPAddr'), False);

  if KV <> nil then
  begin
    if KV.Data.DataType = WStr then
      WideCharToMultiByte(CP_UTF8, 0, KV.Data.StrValueW, -1, Addr, SizeOf(Addr), nil, nil)
    else
      System.AnsiStrings.StrCopy(Addr, KV.Data.StrValueA);

    SeparateAddress(string(Addr), IP, Port);

    Exit(True);
  end
  else
    Exit(False);
end;

function MasterServerOrderSort(FirstElement: Pointer; SecondElement: Pointer): Integer; cdecl;
const
  Pattern: array[0..7] of Byte = ($55, $8B, $EC, $8B, $45, $08, $8B, $0D);
var
  ItemID1, ItemID2: Integer;

  S1, S2: PListPanelItem;

  IP1: string;
  NIP1: Cardinal;
  Port1: Word;

  IP2: string;
  NIP2: Cardinal;
  Port2: Word;

  P: PByte;

  Idx1, Idx2: Integer;
begin
  ItemID1 := PInteger(FirstElement)^;
  ItemID2 := PInteger(SecondElement)^;

  if s_CurrentSortingListPanel = nil then
  begin
    P := FindPattern(SBBase, SBSize, [$8B, $FF, $14, $85, $C0, $89, $1D], 7);
    P := PPointer(P)^;
    P := PPointer(P)^;
    s_CurrentSortingListPanel := P;

    P := FindPattern(SBBase, SBSize, [$8B, $30, $8B, $01, $FF, $90, $FF, $FF, $FF, $FF, $8B, $0D], 6);
    OFFSET_VTABLE_GETITEMDATA := PInteger(P)^;

    GetItemData := PPointer(Transpose(PPointer(s_CurrentSortingListPanel)^, OFFSET_VTABLE_GETITEMDATA))^;
  end;

  S1 := GetItemData(nil, nil, s_CurrentSortingListPanel, ItemID1);
  S2 := GetItemData(nil, nil, s_CurrentSortingListPanel, ItemID2);

  if S1 = nil then
  begin
{$IFDEF DEBUG}
    TConsole.Error('GetAddrForListPanelItem: S1 = nil');
{$ENDIF}
    Exit(0);
  end;

  if S2 = nil then
  begin
{$IFDEF DEBUG}
    TConsole.Error('GetAddrForListPanelItem: S2 = nil');
{$ENDIF}
    Exit(0);
  end;

//  if (S1 = nil) and (S2 <> nil) then
//  begin
//    WriteLn('NIL check #1');
//    Exit(1);
//  end
//  else if (S1 <> nil) and (S2 = nil) then
//  begin
//    WriteLn('NIL check #2');
//    Exit(-1);
//  end
//  else if (S1 = nil) and (S2 = nil) then
//  begin
//    WriteLn('NIL check #3');
//    Exit(0);
//  end;

  if not GetAddrForListPanelItem(S1, IP1, Port1) then
  begin
{$IFDEF DEBUG}
    TConsole.Error('GetAddrForListPanelItem #1: FALSE');
{$ENDIF}
    Exit(0);
  end;

  if not GetAddrForListPanelItem(S2, IP2, Port2) then
  begin
{$IFDEF DEBUG}
    TConsole.Error('GetAddrForListPanelItem #2: FALSE');
{$ENDIF}
    Exit(0);
  end;

  NIP1 := inet_addr(PAnsiChar(AnsiString(IP1)));
  NIP2 := inet_addr(PAnsiChar(AnsiString(IP2)));

{$IFDEF DEBUG}
//  WriteLn('MasterServerOrderSort:');
//  WriteLn(#9'Server #1: ', IP1, ':', htons(Port1));
//  WriteLn(#9'Server #2: ', IP2, ':', htons(Port2));
{$ENDIF}

  Idx1 := LocalMaster.GetServerIndex(NIP1, htons(Port1));
  Idx2 := LocalMaster.GetServerIndex(NIP2, htons(Port2));

  if Idx1 < Idx2 then
  begin
    Exit(-1)
  end
  else if Idx1 > Idx2 then
  begin
    Exit(1)
  end
  else
  begin
    Exit(0);
  end;
end;

{$ENDREGION}

{$REGION 'Search'}

procedure Find_KeyValues_FindKey;
var
  P: Pointer;
begin
  P := FindPushString(SBBase, SBSize, 'PinnedCornerOffsetY');
  P := FindNextCallEx(P);
  orgKeyValues_FindKey := P;

  if orgKeyValues_FindKey = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not find KeyValues::FindKey.');
  {$ENDIF}

    Exit;
  end;

{$IFDEF DEBUG}
  TConsole.Important('KeyValues::FindKey - %.8X',
    [Cardinal(P) - Cardinal(SBBase)]);
{$ENDIF}
end;

procedure Find_Mov_AscendingSortFunc;
begin
  orgMov_AscendingSortFunc := FindPattern(SBBase, SBSize, [$68, $FF, $FF, $FF, $FF, $6A, $04, $FF, $B6], 1);

  if orgMov_AscendingSortFunc = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not find AscendingSortFunc.');
  {$ENDIF}

    Exit;
  end;

  orgAscendingSortFunc := PPointer(orgMov_AscendingSortFunc)^;
end;

procedure Find_s_CurrentSortingListPanel;
const
  Pattern: array[0..7] of Byte = ($55, $8B, $EC, $8B, $45, $08, $8B, $0D);
var
  P: PPointer;
begin
  P := FindPattern(SBBase, SBSize, @Pattern[0], SizeOf(Pattern), 8);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Could not find s_CurrentSortingListPanel.');
  {$ENDIF}

    Exit;
  end;

  P := P^;

  while P^ = nil do
    Sleep(100);

  P := P^;

  s_CurrentSortingListPanel := P;
  GetItemData := PPointer(Transpose(P^, OFFSET_VTABLE_GETITEMDATA))^;
end;

{$ENDREGION}

var
  J: Integer = 0;

{$REGION 'Implementation'}

//function CFriendsGames_CheckPrimaryFilters(_EAX, _EDX: Pointer; This: Pointer; Server: Pointer): Boolean; register;
//var
//  SwappedIP: Cardinal;
//  SwappedPort: Word;
//begin
////{$IFDEF DEBUG}
////  WriteLn('Calling CInternetGames_CheckPrimaryFilters...');
////  Inc(J);
////{$ENDIF}
//
//  SwappedIP := PInteger(Integer(Server) + 4)^; // m_unIP
//  SwappedIP := htonl(SwappedIP);
//
//  PWord(Integer(Server) + 2)^ := PWord(Integer(Server) + 0)^;
//
//  SwappedPort := PWord(Integer(Server) + 2)^; // m_usQueryPort
//  SwappedPort := htons(SwappedPort);
//
//{$IFDEF DEBUG}
//  //Write('[', inet_ntoa(TInAddr(SwappedIP)), ':', htons(SwappedPort), '] ');
//{$ENDIF}
//
//  if LocalMaster.GetServerIndex(SwappedIP, SwappedPort) = -1 then
//  begin
//{$IFDEF DEBUG}
//    //WriteLn('FALSE');
//{$ENDIF}
//    Exit(False);
//  end;
//
//{$IFDEF DEBUG}
//  //WriteLn('TRUE');
//{$ENDIF}
//
//  Exit(CFriendsGames_CheckPrimaryFilters_Org(_EAX, _EDX, This, Server));
//end;

function CFriendsGames_CheckPrimaryFilters(_EAX, _EDX: Pointer; This: Pointer; Server: PGameServerItem): Boolean; register;
begin
  if Server.MaxPlayers = 1000 then
    Exit(False); // definitely some birzyk shyte coming

  Exit(True);
end;

procedure CInternetGames_RefreshComplete(_EAX, _EDX: Pointer; This: Pointer; Status: Integer; Unk1: Integer); register;
begin
{$IFDEF DEBUG}
  TConsole.Write('Calling CInternetGames::RefreshComplete...');
{$ENDIF}

  CInternetGames_RefreshComplete_Org(nil, nil, This, Status, Unk1);

  WritePointer(orgMov_AscendingSortFunc, orgAscendingSortFunc);

  if MasterServerInited and (LastServerUpdate = 0) or (GetTickCount > LastServerUpdate + 90000) then
  begin
    LocalMaster.LoadFromMaster(LongToIP(MasterServerIPv4), MasterServerPort, MasterRequest, '0.0.0.0:0');
    LastServerUpdate := GetTickCount;
  end;
end;

type
  TThisCallProc = procedure(_EAX, _EDX: Integer; This: Pointer); register;

procedure F;
begin
  ThisCall(FriendsGames_Button_RefreshAll, Transpose(SBBase, $EFE0));
end;

procedure CFriendsGames_RefreshComplete(_EAX, _EDX: Pointer; This: Pointer; Status: Integer; Unk1: Integer); register;
begin
{$IFDEF DEBUG}
  TConsole.Write('Calling CFriendsGames::RefreshComplete...');
{$ENDIF}

  WritePointer(orgMov_AscendingSortFunc, @MasterServerOrderSort);
  CFriendsGames_RefreshComplete_Org(nil, nil, This, Status, Unk1);
  WritePointer(orgMov_AscendingSortFunc, orgAscendingSortFunc);

  if MasterServerInited and (LastServerUpdate = 0) or (GetTickCount > LastServerUpdate + 90000) then
  begin
    LocalMaster.LoadFromMaster(LongToIP(MasterServerIPv4), MasterServerPort, MasterRequest, '0.0.0.0:0');
    LastServerUpdate := GetTickCount;
  end;
end;

procedure hkCInternetGames_GetNewServerList(_EAX, _EDX: Pointer; This: Pointer); register;
begin
{$IFDEF DEBUG}
  TConsole.Write('Calling CInternetGames::GetNewServerList...');
{$ENDIF}

  InternetGamesObject := This;

  BuildServerList;

//  S := Format('%s:%d', [LongToIP(ServerList.IP), htons(ServerList.Port)]);
//  MessageBox(0, PChar(S), 0, MB_SYSTEMMODAL);
//
//  S := IntToHex(Integer(Emulator.ServerList), 8) + #10 + IntToHex(Integer(ServerList), 8);
//  MessageBox(0, PChar(S), 0, MB_SYSTEMMODAL);

  //ServerListRawSize^ := SizeOf(TNetAddress) * 10;

  //BuildServerList(False);

  WritePointer(orgMov_AscendingSortFunc, @MasterServerOrderSort);

//  MessageBox(0, 0, 0, MB_SYSTEMMODAL);

//  P := PAnsiChar(GetModuleHandle('steamclient.dll'));
//  P := @P[$7D231C];
//  System.AnsiStrings.StrCopy(P, '216.52.148.47:27015');

//  MasterServerParser.WaitWhileRefreshing(10, 100);
//
//{$IFDEF DEBUG}
//  MasterServerParser.PrintList;
//{$ENDIF}

  CInternetGames_GetNewServerList_Org(nil, nil, This);
end;

procedure hkCFriendsGames_GetNewServerList(_EAX, _EDX: Pointer; This: Pointer); register;
var
  P: Pointer;
begin
{$IFDEF DEBUG}
  TConsole.Write('Calling CFriendsGames::GetNewServerList...');
{$ENDIF}

  if @CFriendsGames_GetNewServerList_Org = nil then
  begin
    P := PPointer(This)^;
    P := PPointer(Transpose(P, 4));
    P := PPointer(P)^;
    @CFriendsGames_GetNewServerList_Org := P;
  end;

  InternetGamesObject := This;

  BuildServerList;

//  S := Format('%s:%d', [LongToIP(ServerList.IP), htons(ServerList.Port)]);
//  MessageBox(0, PChar(S), 0, MB_SYSTEMMODAL);
//
//  S := IntToHex(Integer(Emulator.ServerList), 8) + #10 + IntToHex(Integer(ServerList), 8);
//  MessageBox(0, PChar(S), 0, MB_SYSTEMMODAL);

  //ServerListRawSize^ := SizeOf(TNetAddress) * 10;

  //BuildServerList(False);

  WritePointer(orgMov_AscendingSortFunc, @MasterServerOrderSort);

//  MessageBox(0, 0, 0, MB_SYSTEMMODAL);

//  P := PAnsiChar(GetModuleHandle('steamclient.dll'));
//  P := @P[$7D231C];
//  System.AnsiStrings.StrCopy(P, '216.52.148.47:27015');

//  MasterServerParser.WaitWhileRefreshing(10, 100);
//
//{$IFDEF DEBUG}
//  MasterServerParser.PrintList;
//{$ENDIF}

  CFriendsGames_GetNewServerList_Org(nil, nil, This);
end;

{$ENDREGION}

{$REGION 'Hooks and Patches'}

procedure Hook_ListPanel_RBTreeLessFunc;
const
  Pattern: array[0..10] of Byte = ($55, $8B, $EC, $56, $8B, $75, $0C, $57, $8B, $7D, $08);
begin
  orgListPanel_RBTreeLessFunc := FindPattern(SBBase, SBSize, @Pattern[0], SizeOf(Pattern));

  {$I Obfuscation-2.inc}

  if orgListPanel_RBTreeLessFunc = nil then
  begin
{$IFDEF DEBUG}
    TConsole.Error('Failed to hook ListPanel::RBTreeLessFunc.');
{$ENDIF}
    Exit;
  end;

{$IFDEF DEBUG}
  TConsole.Important('ListPanel::RBTreeLessFunc - %.8X',
    [Cardinal(orgListPanel_RBTreeLessFunc) - Cardinal(SBBase)]);
{$ENDIF}

  WriteByte(orgListPanel_RBTreeLessFunc, $C3);
end;

procedure Hook_CInternetGames_GetNewServerList;
var
  P: Pointer;
begin
  P := FindPattern(SBBase, SBSize,
    [$66, $C7, $86, $FF, $FF, $FF, $FF, $00, $00,
     $C6, $86, $FF, $FF, $FF, $FF, $00,
     $FF, $FF,
     $FF,
     $FF, $A0]);

  P := FindWordPtr(P, 128, $8B56, 0, True);
  P := FindRefAddr(SBBase, SBSize, P);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CInternetGames::GetNewServerList.');
  {$ENDIF}

    Exit;
  end;

  @CInternetGames_GetNewServerList_Org := PPointer(P)^;
  WritePointer(P, @hkCInternetGames_GetNewServerList);

{$IFDEF DEBUG}
  TConsole.Important('CInternetGames::GetNewServerList - %.8X (%.8X)',
   [Cardinal(@CInternetGames_GetNewServerList_Org) - Cardinal(SBBase),
    Cardinal(P) - Cardinal(SBBase)]);
 {$ENDIF}
end;

procedure Hook_CFriendsGames_GetNewServerList;
var
  P: Pointer;
begin
  P := GetVTableForClass(SBBase, Transpose(SBBase, SBSize - 1), 'CFriendsGames', 400);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CFriendsGames::GetNewServerList #1.');
  {$ENDIF}

    Exit;
  end;

  P := Transpose(P, 8);

  WritePointer(P, @hkCFriendsGames_GetNewServerList);
  @CFriendsGames_GetNewServerList_Org := nil;
end;

procedure Hook_CFriendsGames_RefreshComplete;
var
  P: Pointer;
begin
  P := GetVTableForClass(SBBase, Transpose(SBBase, SBSize - 1), 'CFriendsGames', 404);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CFriendsGames::RefreshComplete #1.');
  {$ENDIF}

    Exit;
  end;

  P := Transpose(P, 12);

  WritePointer(P, @CFriendsGames_RefreshComplete);
  @CFriendsGames_RefreshComplete_Org := PPointer(P)^;
end;

procedure Hook_CInternetGames_RefreshComplete;
var
  P: Pointer;
begin
  P := FindPushString(SBBase, SBSize, '#ServerBrowser_MasterServerNotResponsive');
  P := FindStackPrologue(P);
  P := FindRefAddr(SBBase, SBSize, P);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CInternetGames::RefreshComplete.');
  {$ENDIF}

    Exit;
  end;

  @CInternetGames_RefreshComplete_Org := PPointer(P)^;
  WritePointer(P, @CInternetGames_RefreshComplete);

{$IFDEF DEBUG}
  TConsole.Important('CInternetGames::RefreshComplere - %.8X (%.8X)',
    [Cardinal(@CInternetGames_RefreshComplete_Org) - Cardinal(SBBase),
     Cardinal(P) - Cardinal(SBBase)]);
{$ENDIF}
end;

procedure Hook_CFriendsGames_CheckPrimaryFilters;
var
  P, P2: Pointer;
begin
  P := FindPattern(SBBase, SBSize, [$8B, $80, $88, $00, $00, $00, $FF, $D0, $8B, $FF, $08, $3C, $01]);
  P := FindStackPrologue(P);
  P2 := FindRefAddr(SBBase, SBSize, P);
  P2 := FindRefAddr(Transpose(P2, 4), SBSize - (Cardinal(P) - Cardinal(SBBase)), P);
  P2 := FindRefAddr(Transpose(P2, 4), SBSize - (Cardinal(P) - Cardinal(SBBase)), P);
  P := FindRefAddr(Transpose(P2, 4), SBSize - (Cardinal(P) - Cardinal(SBBase)), P);
  P := Transpose(P, -4);

  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CInternetGames::CheckPrimaryFilters.');
  {$ENDIF}

    Exit;
  end;

  @CFriendsGames_CheckPrimaryFilters_Org := PPointer(P)^;
  WritePointer(P, @CFriendsGames_CheckPrimaryFilters);

{$IFDEF DEBUG}
  TConsole.Important('CFriendsGames::CheckPrimaryFilters - %.8X (%.8X)',
    [Cardinal(@CFriendsGames_CheckPrimaryFilters_Org) - Cardinal(SBBase),
     Cardinal(P) - Cardinal(SBBase)]);
{$ENDIF}
end;

procedure Patch_SortFunc;
var
  Addr: Pointer;
begin
  Addr := FindPattern(SBBase, SBSize, [$8A, $FF, $18, $B9]);
  if Addr = nil then
  begin
{$IFDEF DEBUG}
    TConsole.Error('Failed to patch SortFunc.');
{$ENDIF}
    Exit;
  end;

  Addr := Transpose(Addr, 4);
  Addr := PPointer(Addr)^;

{$IFDEF DEBUG}
  TConsole.Important('SortFunc - %.8X', [Cardinal(Addr) - Cardinal(SBBase)]);
{$ENDIF}

  WriteByte(Addr, $C3);
end;

{$ENDREGION}

procedure Hook_AscendingSortFunc;
begin
  if orgMov_AscendingSortFunc <> nil then
    WritePointer(orgMov_AscendingSortFunc, @MasterServerOrderSort);
end;

{$REGION 'TMasterServerParser'}

{ TMasterServerParser }

constructor TMasterServerParser.Create;
begin
  inherited Create(0);

  FServerList := TServerList.Create;
  FRefreshing := False;
end;

destructor TMasterServerParser.Destroy;
begin
  FServerList.Free;

  inherited;
end;

function TMasterServerParser.GetConnectionPort(IP: Cardinal; Port: Word): Word;
var
  Server: TServer;
begin
  for Server in FServerList do
  begin
    if (Server.IP = IP) and (Server.Port = Port) then
      Exit(Server.ConnectionPort);
  end;

  Exit($FFFF);
end;

function TMasterServerParser.GetServerIndex(IP: Cardinal; Port: Word): Integer;
var
  Server: TServer;
  Index: Integer;
begin
  Index := 0;

  for Server in FServerList do
  begin
    if Server.IP = IP then
    begin
      if Server.Port = Port then
        Exit(Index)
      else if Server.ConnectionPort = Port then
        Exit(Index);
    end;

    Inc(Index);
  end;

//{$IFDEF DEBUG}
//  MessageBox(HWND_DESKTOP, PChar(Format('Could not find server.'#10'Server.Port = %d, Server.ConnectionPort = %d, Port = %d',
//    [Server.Port, Server.ConnectionPort, Port])), '', MB_ICONWARNING or MB_SYSTEMMODAL);
//{$ENDIF}

  Exit(-1);
end;

procedure TMasterServerParser.OnReadUDP(var Buffer: TBuffer);
var
  IP: Cardinal;
  Port: Word;

  Addr: string;
begin
  Buffer.Read<Integer>;

  IP := 0;
  Port := 0;

  if Buffer.Read<Word> = $0A66 then
  begin
    while Buffer.Position <> Buffer.Last do
    begin
      IP := Buffer.Read<Integer>;
      Port := Buffer.Read<Word>;

      if (IP = 0) and (Port = 0) then
      begin
        FRefreshing := False;
        Exit;
      end;

      FServerList.Add(TServer.Create(IP, Port));
    end;

    Addr := Format('%s:%d', [inet_ntoa(TInAddr(IP)), htons(Port)]);

    try
      RequestList(Addr, '\gamedir\cstrike', FMasterAddress);
    except

    end;
  end;
end;

procedure TMasterServerParser.PrintList;
{$IFDEF DEBUG}
var
  Server: TServer;
  I: Integer;
begin
  if FServerList.Count = 0 then
  begin
    WriteLn('TMasterServerParser.PrintList: List is empty.');
    Exit;
  end;

  I := 0;

  for Server in FServerList do
  begin
    WriteLn(I, '. ', inet_ntoa(TInAddr(Server.IP)), ':', htons(Server.Port));
    Inc(I);
  end;
end;
{$ELSE}
begin

end;
{$ENDIF}

procedure TMasterServerParser.RequestList(const IP: string; Port: Word;
  const Query, Address: string);
begin
  RequestList(IP + ':' + Port.ToString, Query, Address);
end;

procedure TMasterServerParser.RequestList(const URL: string);
var
  S: AnsiString;
  List: TXStringList;
  I: Integer;

  IP: string;
  Port: Word;
begin
  List.Create;

  FRefreshing := True;

  with THTTPSend.Create do
  begin
    Protocol := '1.1';
    HTTPMethod('GET', URL);

    if ResultCode = 200 then
    begin
      with Document do
        SetString(S, PAnsiChar(Memory), Size);

      List.Text := string(S);

      for I := 0 to List.Count - 1 do
      begin
        SeparateAddress(List.Items[I], IP, Port);
        FServerList.Add(TServer.Create(inet_addr(PAnsiChar(AnsiString(IP))), htons(Port)))
      end;
    end;

    Free;
  end;

  FRefreshing := False;
end;

function TMasterServerParser.SetConnectionPort(IP: Cardinal; Port,
  Value: Word): Boolean;
var
  Server: TServer;
  I: Integer;
begin
  for I := 0 to FServerList.Count - 1 do
  begin
    Server := FServerList[I];

    if (Server.IP = IP) and (Server.Port = Port) then
    begin
      Server.ConnectionPort := Value;
      FServerList[I] := Server;

      Exit(True);
    end;
  end;

  Exit(False);
end;

procedure TMasterServerParser.SetUpdateForcely;
begin
  FRefreshing := True;
end;

procedure TMasterServerParser.RequestList(const Addr: string; const Query: string; const Address: string);
var
  Buffer: TBuffer;

  IP: string;
  Port: Word;
begin
  if Addr = '0.0.0.0:0' then
    FServerList.Clear;

  FRefreshing := True;
  FMasterAddress := FMasterAddress;

  Buffer.Create;
  Buffer.Write<AnsiChar>('1');
  Buffer.Write<Byte>($FF);
  Buffer.Write<AnsiString>(AnsiString(Addr));
  Buffer.Write<AnsiString>(AnsiString(Query));

  SeparateAddress(Address, IP, Port);
  Send(IP, Port, Buffer.Data, Buffer.Size);

  Buffer.Free;
end;

procedure TMasterServerParser.WaitWhileRefreshing(Tries, Milliseconds: Integer);
begin
  if (Tries = 0) or (Milliseconds = 0) then
    Exit;

{$IFDEF DEBUG}
  if not FRefreshing then
    WriteLn('TMasterServerParser.WaitWhileRefreshing: Not refreshing.');
{$ENDIF}

  while FRefreshing do
  begin
{$IFDEF DEBUG}
    WriteLn('TMasterServerParser.WaitWhileRefreshing: Tries left - ', Tries, '.');
{$ENDIF}

    Dec(Tries);

    if Tries <= 0 then
    begin
{$IFDEF DEBUG}
      WriteLn('TMasterServerParser.WaitWhileRefreshing: Timeout, still refreshing.');
{$ENDIF}
      Exit;
    end;

    Sleep(Milliseconds);
  end;

{$IFDEF DEBUG}
  WriteLn('TMasterServerParser.WaitWhileRefreshing: Refresh completed.');
{$ENDIF}
end;

{$ENDREGION}

{ TServer }

class function TServer.Create(IP: Cardinal; Port: Word): TServer;
begin
  Result.IP := IP;
  Result.Port := Port;
  Result.ConnectionPort := $FFFF;
end;

end.
