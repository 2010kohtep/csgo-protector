unit Protector.Emulator;

{$I Default.inc}

interface

uses
  System.ZLib,
  System.AnsiStrings,
  System.Types,
  System.Classes,

  Winapi.WinSock,
  Winapi.Windows,

  Xander.Memory,
  Xander.Console;

type
  PNetAddress = ^TNetAddress;
  TNetAddress = packed record
    IP: LongWord;
    Port: Word;
  end;

type
  (* Примерная структура объекта, в котором хранится информация о серверах с 4exchange,
     а также вспомогательные структуры для распаковки gzip/deflate и некоторые HTTP
     заголовки. *)
  PEmulatorObject = ^TEmulatorObject;
  TEmulatorObject = record
    CritSec: RTL_CRITICAL_SECTION;

    Align: array[0..999] of AnsiChar;
    Unk01: Integer;
    Unk02: Integer;

    szStr: array[0..255] of AnsiChar;
    Unk03: Integer;

    szAcceptHeader: array[0..259] of AnsiChar;
    Stream: z_stream;

    Unk04: Integer;
    Unk05: Integer;

    ZLibUnpacked: Integer;
    InflateResult: Integer;

    StreamData: Integer;
    Unk06: array[0..99999] of AnsiChar;
    HTTPResponse: array[0..99999] of AnsiChar;
  end;

type
  TEmulatorWrapper = object
  private
    FEmulator: PEmulatorObject;

    procedure SetServerList(Data: PAnsiChar);
    function GetServerList: PAnsiChar;
  public
    procedure InitializeObject(Obj: PEmulatorObject);

    property ServerList: PAnsiChar read GetServerList write SetServerList;
  end;

var
  Emulator: TEmulatorWrapper;

var
  BirzykStubInited: Boolean = False;

  ServerListRawSize: PInteger;
  ServerList: PNetAddress;

procedure BuildServerList;

procedure BirzykStub;

implementation

uses
  Protector.Engine.Routines,
  Protector.Global,
  Protector.Common;

{ TEmulatorWrapper }

procedure TEmulatorWrapper.InitializeObject(Obj: PEmulatorObject);
begin
  FEmulator := Obj;
end;

function TEmulatorWrapper.GetServerList: PAnsiChar;
begin
  Result := FEmulator.HTTPResponse;
end;

procedure TEmulatorWrapper.SetServerList(Data: PAnsiChar);
begin
  ZeroMemory(@FEmulator.HTTPResponse, SizeOf(FEmulator.HTTPResponse));

  Move(Data^, FEmulator.HTTPResponse[0], Length(Data));
  FEmulator.ZLibUnpacked := 1;
end;

procedure BuildServerList;
var
  Server: string;
  EmuServer: PNetAddress;

  IP: string;
  Port: Word;
begin
  if not BirzykStubInited then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('BuildServerList: WARNING! Stub is not inited.');
  {$ENDIF}

    Exit;
  end;

  EmuServer := ServerList;

  for Server in LocalMaster.List do
  begin
    SeparateAddress(Server, IP, Port);

    EmuServer.IP := inet_addr(PAnsiChar(AnsiString(IP)));
    EmuServer.Port := htons(Port);

    Inc(EmuServer);
  end;

  //LocalMaster.PrintList;

  ServerListRawSize^ := LocalMaster.List.Count * SizeOf(TNetAddress);

{$IFDEF DEBUG}
  TConsole.Important('BuildServerList: Built %d servers.', [ServerListRawSize^ div 6]);
{$ENDIF}
end;

(* Поиск двух переменных эмулятора - ServerListRawSize и ServerList. В первой
   находится количество байт, записанных в ServerList, во второй же переменной
   находится массив TNetAddress. *)
function FindServerList: Boolean;
const
  Pattern: array[0..8] of Byte = ($E8, $FF, $FF, $FF, $FF, $8D, $43, $30, $50);
var
  P: Pointer;
begin
  P := FindPattern(SCBase, SCSize, @Pattern[0], SizeOf(Pattern), 0);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('WARNING! Could not find server list data #1.');
  {$ENDIF}

    Exit(False);
  end;

  P := FindWordPtr(P, 256, $E58B, 1);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('WARNING! Could not find server list data #2.');
  {$ENDIF}

    Exit(False);
  end;

  P := FindBytePtr(P, 64, $8B);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('WARNING! Could not find server list data #2.');
  {$ENDIF}

    Exit(False);
  end;

  ServerListRawSize := PPointer(Transpose(P, 2))^;
  ServerList := PPointer(Transpose(P, 8))^;

  Exit(True);
end;

(* Эмулятор устроен так, что список серверов заносится в базу сервербраузера один раз,
   затем нужно подождать 90 секунд для того, чтобы при следующем обновлении список
   занёсся ещё раз. Данная функция снимает это ограничение, чтобы сервера заносились в
   базу каждый раз, как пользователь обновляет список серверов. *)
function Patch_RefreshInterval: Boolean;
var
  P: Pointer;
begin
  P := FindLongPtr(SCBase, SCSize, $835AC183, 2);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('WARNING! Patch_RefreshInterval failed');
  {$ENDIF}

    Exit(False);
  end;

  WriteByte(P, $00);
  Exit(True);
end;

type
  TEmulatorPatch = (epNoPatch, epOld, epNew, epDynamic);

var
  EmulatorPatch: TEmulatorPatch = epNoPatch;

function IsBadSteamclient: Boolean;
begin
  if SCBase = nil then
    Exit(False);

	if CheckLong(SCBase, $F0000025, $548CB) then // and     eax, 0FFF00000h
    EmulatorPatch := epOld
  else
  if CheckWord(SCBase, $3D80, $54873) then // cmp     byte ptr ds:1FF59F74h, 0
    EmulatorPatch := epNew
  else
    EmulatorPatch := epDynamic;

  Result := EmulatorPatch <> epDynamic;
end;

procedure PatchSteamClientDynamic; // dynamic patch
var
  Pattern: array[0..6] of Byte;
  P: Pointer;

{$IFDEF DEBUG}
  Count: Integer;
{$ENDIF}
begin
//  P := FindPattern(SCBase, SCSize, [$8D, $46, $F0, $75, $35], 3);
//  if P = nil then
//  begin
//  {$IFDEF DEBUG}
//    TConsole.Error('PatchSteamClientInternal: Pattern #1 not found.');
//  {$ENDIF}
//
//    Exit;
//  end;
//
//{$IFDEF DEBUG}
//  TConsole.Success('PatchSteamClientInternal: Pattern #1 found at %x', [Integer(P)]);
//{$ENDIF}
//
//  WriteNOPs(P, 2);

  P := FindPattern(SCBase, SCSize, [$74, $07, $C6, $05, $FF, $FF, $FF, $FF, $01], 4);
  if P = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('PatchSteamClientInternal: Pattern #2 not found.');
  {$ENDIF}

  end;

  P := PPointer(P)^;
  if not IsValidMemory(P) then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('PatchSteamClientInternal: Pattern #2 result points at invalid memory address (%x).', [Integer(P)]);
  {$ENDIF}

    Exit;
  end;

{$IFDEF DEBUG}
  TConsole.Success('PatchSteamClientInternal: Pattern #2 found at %x', [Integer(P)]);
{$ENDIF}

  PInteger(P)^ := 0;

  WriteBuffer(@Pattern[0], [$C6, $05, $FF, $FF, $FF, $FF, $01]);
  PPointer(@Pattern[2])^ := P;

{$IFDEF DEBUG}
  Count := 0;
{$ENDIF}

  repeat
    P := FindPattern(SCBase, SCSize, Pattern);
    if P = nil then
      Break;

  {$IFDEF DEBUG}
    TConsole.Success('PatchSteamClientInternal: Pattern #3.%d found (%x).', [Count, Integer(P)]);
    Inc(Count);
  {$ENDIF}

    WriteNOPs(P, 7);
  until False;

{$IFDEF DEBUG}
  if Count <> 4 then
    TConsole.Important('PatchSteamClientInternal: Found %d candidates for pattern #3, expected 4.', [Count, Integer(P)]);
{$ENDIF}
end;

procedure PatchSteamClientStatic;
begin
	if SCBase = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Write('PatchSteamClientStatic: Tried to do patch without steamclient''s image base address.', RED);
  {$ENDIF}

    Exit;
  end;

  case EmulatorPatch of
    epOld:
    begin
    {$IFDEF DEBUG}
      TConsole.Write('PatchSteamClientStatic: Using OLD emulator patch.', YELLOW);
    {$ENDIF}

      WriteNOPs(Transpose(SCBase, $B1281), 2);

      WriteNOPs(Transpose(SCBase, $548D8), 2);
      WriteNOPs(Transpose(SCBase, $548E5), 2);
      WriteNOPs(Transpose(SCBase, $548EE), 2);

      WriteByte(Transpose(SCBase, $6B9F74), 0);
    end;

    epNew:
    begin
    {$IFDEF DEBUG}
      TConsole.Write('PatchSteamClientStatic: Using NEW emulator patch.', YELLOW);
    {$ENDIF}

      WriteNOPs(Transpose(SCBase, $B1201), 2);
      WriteByte(Transpose(SCBase, $5488C), $EB);
    end;

    else
    begin
    {$IFDEF DEBUG}
      TConsole.Write('PatchSteamClientStatic: Unknown patch requested.', RED);
    {$ENDIF}
    end;
  end;
end;

procedure BirzykStub;
begin
  {$I Obfuscation-2.inc}

{$IFDEF DEBUG}
  TConsole.Important('Searching for emulator data to implement stub... ');
{$ENDIF}

  if not IsBadSteamclient then
    PatchSteamClientDynamic
  else
    PatchSteamClientStatic;

  if FindServerList and Patch_RefreshInterval then
  begin
    BirzykStubInited := True;

  {$IFDEF DEBUG}
    TConsole.Success('Stub implemented.');
  {$ENDIF}
  end
  else
  begin
  {$IFDEF DEBUG}
    TConsole.Error('WARNING! Could not implement emulator stub.');
  {$ENDIF}
  end;

  {$I Obfuscation-1.inc}
end;

procedure __________________________________;
begin

end;

procedure __birzyk_Te6e_geJIaTb_He4ero_4ToJIu;
begin

end;

procedure __JIy4we_6bI_TbI_kpawu_B_cBoem_emyJI9Tope_ucnpaBuJI;
begin

end;

procedure __BmecTo_Te69_eTum_3aHuma10Tc9_gpyrue;
begin

end;

procedure __Tak_TbI_ewe_u_mewaewb;
begin

end;

procedure __geJIom_3aumucb;
begin

end;

exports
  __________________________________,
  __geJIom_3aumucb,
  __Tak_TbI_ewe_u_mewaewb,
  __BmecTo_Te69_eTum_3aHuma10Tc9_gpyrue,
  __JIy4we_6bI_TbI_kpawu_B_cBoem_emyJI9Tope_ucnpaBuJI,
  __birzyk_Te6e_geJIaTb_He4ero_4ToJIu,
  __________________________________;

end.
