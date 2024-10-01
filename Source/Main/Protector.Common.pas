unit Protector.Common;

{$I Default.inc}

interface

uses
  System.SysUtils, Winapi.Windows, Winapi.WinSock, Xander.Memory;

const
 INTERNET_CONNECTION_MODEM      = 1;
 INTERNET_CONNECTION_LAN        = 2;
 INTERNET_CONNECTION_PROXY      = 4;
 INTERNET_CONNECTION_MODEM_BUSY = 8;

function IsInternetConnected: Boolean;

procedure SeparateAddress(const Addr: string; out IP: string; out Port: Word); overload;
procedure SeparateAddress(const Addr: string; out IP: Integer; out Port: Word); overload;

function DomainToInt(const Domain: string): Integer;

function LongToIP(IP: Cardinal): string; inline;

function GetRegionModuleHandle(Addr: Pointer): Cardinal;

function IntToHex(Value: Integer): string; overload;
function IntToHex(Value: Pointer): string; overload;

function GetAddressFromSocket(S: TSocket): string;

function SearchResource(const ResourceName: string; out Data: Pointer; out Size: Integer): Boolean;
function CopyResource(const ResourceName: string; out Data: Pointer; out Size: Integer): Boolean;
function ExtractResource(const ResourceName: string; const Name: string): Boolean;
function ResourceExists(const ResourceName: string): Boolean;

function BeautifyPointer(Addr: Pointer): string;

implementation

function InternetGetConnectedState(lpdwFlags: LPDWORD; dwReserved:DWORD):BOOL; stdcall; external 'wininet.dll' name 'InternetGetConnectedState';

function IsInternetConnected: Boolean;
var
  dwConnectionTypes: DWORD;
begin
  dwConnectionTypes := INTERNET_CONNECTION_MODEM or
                       INTERNET_CONNECTION_LAN or
                       INTERNET_CONNECTION_PROXY;

  Result := InternetGetConnectedState(@dwConnectionTypes, 0);
end;

procedure SeparateAddress(const Addr: string; out IP: string; out Port: Word);
begin
  if Pos(':', Addr) <> 0 then
  begin
    IP := Addr.Split([':'])[0];
    Port := StrToIntDef(Addr.Split([':'])[1], 27015);
  end
  else
  begin
    IP := Addr;
    Port := 27015;
  end;
end;

procedure SeparateAddress(const Addr: string; out IP: Integer; out Port: Word);
var
  StrIP: string;
begin
  SeparateAddress(Addr, StrIP, Port);
  IP := inet_addr(PAnsiChar(AnsiString(StrIP)));
end;

function DomainToInt(const Domain: string): Integer;
var
  Addr: PHostEnt;
begin
  Addr := gethostbyname(PAnsiChar(AnsiString(Domain)));
  if Addr <> nil then
    Result := PInteger(PCardinal(in_addr(Addr.h_addr).S_addr)^)^
  else
    Result := -1;
end;

function LongToIP(IP: Cardinal): string; inline;
begin
  Result := string(inet_ntoa(TInAddr(IP)));
end;

function GetRegionModuleHandle(Addr: Pointer): Cardinal;
var
  MBI: MEMORY_BASIC_INFORMATION;
begin
  if VirtualQuery(Addr, MBI, SizeOf(MBI)) <> 0 then
    Exit(Cardinal(MBI.AllocationBase))
  else
    Exit(0);
end;

function IntToHex(Value: Integer): string;
begin
  Result := System.SysUtils.IntToHex(Value, 8);
end;

function IntToHex(Value: Pointer): string;
begin
  Result := System.SysUtils.IntToHex(Integer(Value), 8);
end;

function GetAddressFromSocket(S: TSocket): string;
var
  Addr: TSockAddrIn;
  AddrSize: Integer;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  getpeername(S, Addr, AddrSize);

  Result := inet_ntoa(Addr.sin_addr) + ':' + htons(Addr.sin_addr.S_addr).ToString;
end;

function SearchResource(const ResourceName: string; out Data: Pointer; out Size: Integer): Boolean;
var
  hRes: HRSRC;
  hResData: HGLOBAL;
  Resource: PByte;
begin
  hRes := FindResource(HInstance, PChar(ResourceName), RT_RCDATA);
  if hRes = 0 then
    Exit(False);

  Size := SizeofResource(HInstance, hRes);
  if Size = 0 then
    Exit(False);

  hResData := LoadResource(HInstance, hRes);

  if hResData = 0 then
    Exit(False);

  Resource := LockResource(hResData);
  if Resource = nil then
    Exit(False);

  Data := Resource;
  Exit(True);
end;

(* Функция, КОПИРУЮЩАЯ ресурс в новый участок памяти. *)
function CopyResource(const ResourceName: string; out Data: Pointer; out Size: Integer): Boolean;
var
  Resource: Pointer;
begin
  if not SearchResource(ResourceName, Resource, Size) then
    Exit(False);

  Data := GetMemory(Size);
  System.Move(Resource^, Data^, Size);

  Exit(True);
end;

(* Извлечь ресурс из текущего проекта, используя WinAPI. *)
function ExtractResource(const ResourceName: string; const Name: string): Boolean;
var
  Size: Integer;
  Resource: Pointer;

  Flags: Cardinal;

  F: File of Byte;
begin
  if not SearchResource(ResourceName, Resource, Size) then
    Exit(False);

  if FileExists(Name) then
  begin
    Flags := GetFileAttributes(Pointer(Name));
    SetFileAttributes(Pointer(Name), Flags and not (FILE_ATTRIBUTE_SYSTEM or FILE_ATTRIBUTE_READONLY));
    System.SysUtils.DeleteFile(Name);
  end
  else
    Flags := 0;

  try
    AssignFile(F, Name);
    ReWrite(F);
    BlockWrite(F, Resource^, Size);
    CloseFile(F);
  except
    Exit(False);
  end;

  if Flags <> 0 then
    SetFileAttributes(Pointer(Name), Flags);

  Exit(True);
end;

function ResourceExists(const ResourceName: string): Boolean;
var
  Data: Pointer;
  Size: Integer;
begin
  Result := SearchResource(ResourceName, Data, Size);
end;

function BeautifyPointer(Addr: Pointer): string;
var
  Base: Pointer;
  Name: string;
begin
  if Addr = nil then
    Exit('null');

  Base := Pointer(GetAddressBase(Addr));
  if Base = nil then
    Exit(IntToHex(Integer(Addr), 8));

  Name := GetModuleName(Cardinal(Base));
  Name := ExtractFileName(Name);
  Name := ChangeFileExt(Name, '');

  Result := Format('%s.%.08X', [Name, Integer(Addr) - Integer(Base)]);
end;

end.
