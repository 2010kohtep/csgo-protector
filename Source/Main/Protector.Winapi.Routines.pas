unit Protector.Winapi.Routines;

{$I Default.inc}

interface

uses
  System.SysUtils,

  Xander.Console,
  Xander.Buffer,
  Xander.Memory,

  SourceSDK,

  Protector.Emulator,

  Winapi.WinSock,
  Winapi.Windows,

  Steam.API,

  Protector.Global,
  Protector.Common;

function hksendto(S: TSocket; var Buf; Len, Flags: Integer; var AddrTo: TSockAddr; ToLen: Integer): Integer; stdcall;
function hkconnect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
function hkrecv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
function hksend(s: TSocket; const Buf; len, flags: Integer): Integer; stdcall;
function hkrecvfrom(s: TSocket; var Buf; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;

implementation

function hksendto(S: TSocket; var Buf; Len, Flags: Integer; var AddrTo: TSockAddr; ToLen: Integer): Integer; stdcall;
//var
//  Buffer: TBuffer;
begin
  if PAnsiChar(@Buf)^ = '1' then // Заголовок запроса списка серверов
  begin
//  {$IFDEF DEBUG}
//    TConsole.Write('Sending server list request for masterserver %s:%d',
//      [LongToIP(AddrTo.sin_addr.S_addr), htons(AddrTo.sin_port)]);
//  {$ENDIF}

//    Buffer.Create;
//    Buffer.Write<AnsiChar>('1');
//    Buffer.Write<Byte>(255);
//    Buffer.Write<AnsiString>('0.0.0.0:0');
//    Buffer.Write<AnsiString>('');

    {$I Obfuscation-2.inc}

    AddrTo.sin_addr.S_addr := MasterServerIPv4;
    AddrTo.sin_port := htons(MasterServerPort);
  end;

  Result := sendto_Orig(S, Buf, Len, Flags, AddrTo, ToLen);
end;

function hkconnect(s: TSocket; var name: TSockAddr; namelen: Integer): Integer; stdcall;
begin
  Result := connect_Orig(s, name, namelen);

{$IFDEF DEBUG}
  if Result <> INVALID_SOCKET then
    WriteLn('[TCP] Connected to TCP server ' + GetAddressFromSocket(S))
  else
    WriteLn('[TCP] Could not connect to some host.');
{$ENDIF}
end;

function hkrecv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
{$IFDEF DEBUG}
var
  Str: PAnsiChar;
  I1, I2: Integer;
{$ENDIF}
begin
  Result := recv_Orig(s, Buf, len, flags);

{$IFDEF DEBUG}
  I1 := Integer(ReturnAddress);
  I2 := GetModuleHandle('steamclient.dll');
  Str := PAnsiChar(AnsiString(IntToHex(I1 - I2, 8)));

  WriteLn('[TCP] Received TCP data from ', GetAddressFromSocket(s), '; Size: ', Result, '; RetAddr: $', Str);
{$ENDIF}
end;

function hksend(s: TSocket; const Buf; len, flags: Integer): Integer; stdcall;
begin
{$IFDEF DEBUG}
  WriteLn('[TCP] Sending TCP message to ', GetAddressFromSocket(s), '; Size: ', len);
{$ENDIF}

  Result := send_Orig(s, Buf, len, flags);
end;

type
  TServerResponded = procedure(_EAX, _EDX: Integer; This: Pointer; ServerItem: PGameServerItem; Index: Integer); register;
  TUtlMap_Find = function(_EAX, _EDX: Integer; This: Pointer; Address: netadr_s): Integer; register;

function InitInternetDlg: Boolean;
begin
  if InternetDlg <> nil then
    Exit(True);

  if SBBase = nil then
    Exit(False);

  InternetDlg := Transpose(SBBase, $E480C);
  InternetDlg := PPointer(InternetDlg)^;

  Result := InternetDlg <> nil;
end;

function GetInternetGames: Pointer;
begin
  if InternetDlg = nil then
    Exit(nil);

  Result := Transpose(InternetDlg, 592);
  Result := PPointer(Result)^;
end;

function GetServerResponded: TServerResponded;
begin
  if InternetDlg = nil then
    Exit(nil);

  Result := Transpose(SBBase, $7440);
end;

function GetUtlMap_Find: TUtlMap_Find;
begin
  if InternetDlg = nil then
    Exit(nil);

  Result := Transpose(SBBase, $A820);
end;

function hkrecvfrom(s: TSocket; var Buf; len, flags: Integer; var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
begin
  if len = 1600 then
  begin
    FillChar(Buf, len, 0);
  end;

  Result := recvfrom_Orig(s, Buf, len, flags, from, fromlen);

//  if Result <> -1 then
//  begin
//    Data := @Buf;
//    if (PInteger(Data)^ = -1) and (Data[4] = 'I') then
//    begin
//      CInternetGames_ServerResponded(from.sin_addr.S_addr, from.sin_port);
//      Exit(-1);
//    end;
//  end;
end;

end.
