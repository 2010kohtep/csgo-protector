unit Xander.MiniUDP;

{$I Default.inc}

{$LEGACYIFEND ON}

interface

uses
  Winapi.WinSock, Winapi.Windows, System.SysUtils, Xander.Buffer;

type
  sockaddr = sockaddr_in;

const
  PORT_ANY = 0;

type
  TIdBytes = array of Byte;
  TOnReadUDP = procedure(Sender: TObject; var Buffer: TBuffer) of object;

  TMiniUDP = class
  protected
    FSocket: TSocket;
    FReadThread: THandle;
    FPort: Word;

    FStrPeerIP: string;
    FLongPeerIP: LongWord;
    FPeerPort: Word;
  private
    procedure OnReadUDPRaw;
    function GetIP: string;
  public
    property SocketHandle: TSocket read FSocket;
    property ReadThread: THandle read FReadThread;
    property IP: string read GetIP;
    property Port: Word read FPort;

    property PeerIPStr: string read FStrPeerIP;
    property PeerIP: LongWord read FLongPeerIP;
    property PeerPort: Word read FPeerPort;

    constructor Create(Port: Word = PORT_ANY);
    destructor Destroy; override;

    procedure Send(const IP: string; Port: Word; Data: Pointer; Size: Integer); overload;
    procedure Send(const IP: string; Port: Word; Data: string); overload; {$IF CompilerVersion >= 17} inline; {$IFEND}
    procedure Send(const IP: string; Port: Word; Data: TIdBytes); overload; {$IF CompilerVersion >= 17} inline; {$IFEND}
    procedure Send(const IP: string; Port: Word; const Data: array of const); overload;

    procedure OnReadUDP(var Buffer: TBuffer); virtual;
  end;

implementation

var
  WSA: TWSAData;

function WSAStartup(wVersionRequired: word; var WSData: TWSAData): {$IFDEF MSWINDOWS} Integer {$ELSE} Cardinal {$ENDIF};
begin
  Result := Winapi.WinSock.WSAStartup(wVersionRequired, WSData);
end;

procedure CloseSocket(H: TSocket);
begin
  Winapi.Winsock.closesocket(H);
end;

function SocketLastError: Integer;
begin
  Result := WSAGetLastError;
end;

constructor TMiniUDP.Create(Port: Word = PORT_ANY);
var
  I: Integer;
  Addr: TSockAddr;
begin
  inherited Create;

  FSocket := socket(AF_INET, SOCK_DGRAM, IPPROTO_IP);
  if FSocket = INVALID_SOCKET then
    raise Exception.CreateFmt('TMiniUDP.Create: socket() : %d', [SocketLastError]);

  FPort := Port;

  Addr.sin_family := AF_INET;
  Addr.sin_addr.S_addr := INADDR_ANY;
  Addr.sin_port := htons(Port);

  if bind(FSocket, TSockAddr(Addr), SizeOf(Addr)) = SOCKET_ERROR then
    raise Exception.CreateFmt('TMiniUDP.Create: bind() : %d', [SocketLastError]);

  if Port = PORT_ANY then
  begin
    I := SizeOf(Addr);
    if getsockname(FSocket, sockaddr(Addr), I) = 0 then
      FPort := htons(Addr.sin_port)
    else
      raise Exception.CreateFmt('TMiniUDP.Create: getsockname() : %d', [SocketLastError]);
  end;

  FReadThread := System.BeginThread(nil, 0, @TMiniUDP.OnReadUDPRaw, Self, 0, PCardinal(nil)^);
end;

destructor TMiniUDP.Destroy;
begin
  TerminateThread(FReadThread, 0);

  if FSocket <> 0 then
    closesocket(FSocket);

  inherited;
end;

function TMiniUDP.GetIP: string;
var
  HostEnt: PHostEnt;
  InAddr: in_addr;
  NameBuf: array[0..255] of Byte;
begin
  gethostname(@NameBuf[0], SizeOf(NameBuf));
  HostEnt := gethostbyname(@NameBuf[0]);
  InAddr.S_addr := Cardinal(PCardinal(HostEnt^.h_addr_list^)^);
  Result := string(inet_ntoa(InAddr));
end;

procedure TMiniUDP.OnReadUDP(var Buffer: TBuffer);
begin

end;

procedure TMiniUDP.OnReadUDPRaw;
const
  EightKB = 1024 * 8;
var
  I: Integer;

  Addr: sockaddr_in;

  Data: array[0..EightKB - 1] of Byte;
  Buffer: TBuffer;
begin
  Buffer.Create(@Data[0], SizeOf(Data));

  repeat
    I := SizeOf(Addr);
    FillChar(Addr, SizeOf(Addr), 0);

    I := recvfrom(FSocket, Data[0], SizeOf(Data), 0, sockaddr(Addr), I);

    if I = INVALID_SOCKET then
    begin
      I := GetLastError;
      if I <> 10054 then // WSAECONNRESET
        raise Exception.CreateFmt('TMiniUDP.OnReadUDPRaw: %d', [SocketLastError]);

      Continue;
    end;

    FStrPeerIP := string(inet_ntoa(Addr.sin_addr));
    FLongPeerIP := Addr.sin_addr.S_addr;
    FPeerPort := htons(Addr.sin_port);

    Buffer.Capacity := I;
    Buffer.Size := 0;

    OnReadUDP(Buffer);
  until False;

  Buffer.Free;
end;

procedure TMiniUDP.Send(const IP: string; Port: Word; Data: Pointer;
  Size: Integer);
var
  Addr: sockaddr_in;
  Host: PHostEnt;
begin
  if (Data = nil) or (Size = 0) then
    Exit;

  Addr.sin_family := AF_INET;
  Addr.sin_port := htons(Port);

  Host := gethostbyname(MarshaledAString(RawByteString(IP)));
  if Host <> nil then
    Addr.sin_addr.S_addr := PInteger(PCardinal(Host.h_addr)^)^
  else
    Addr.sin_addr.S_addr := inet_addr(MarshaledAString(RawByteString(IP))); // remove?

  if sendto(FSocket, Data^, Size, 0, sockaddr(Addr), SizeOf(Addr)) = INVALID_SOCKET then
    raise Exception.CreateFmt('TMiniUDP.Send: WinSock Error (%d).', [WSAGetLastError]);
end;

procedure TMiniUDP.Send(const IP: string; Port: Word; Data: string);
begin
  Send(IP, Port, PChar(Data), Length(Data));
end;

procedure TMiniUDP.Send(const IP: string; Port: Word; Data: TIdBytes);
begin
  Send(IP, Port, @Data[0], Length(Data));
end;

procedure TMiniUDP.Send(const IP: string; Port: Word;
  const Data: array of const);
var
  I: Integer;
  J: Integer;
  Buf: array[0..8191] of Byte;
begin
  J := 0;

  for I := 0 to Length(Data) - 1 do
    case Data[I].VType of
      varBoolean, varByte:
      begin
        Buf[J] := Byte(Data[I].VChar);
        Inc(J, SizeOf(Byte));
      end;

      varWord, varSmallint:
      begin
        PWord(@Buf[J])^ := Word(Data[I].VInteger);
        Inc(J, SizeOf(Word));
      end;

      varInteger, varLongWord:
      begin
        PLongWord(@Buf[J])^ := Data[I].VInteger;
        Inc(J, SizeOf(Integer));
      end;

      varInt64:
      begin
        PInt64(@Buf[J])^ := Data[I].VInt64^;
        Inc(J, SizeOf(Int64));
      end;
    end;

  Send(IP, Port, @Data[0], J);
end;

initialization
  if WSA.wVersion = 0 then
    if WSAStartup($0002, WSA) = INVALID_SOCKET then
      raise Exception.CreateFmt('MiniUDP.initialization: %s', [SocketLastError]);
end.
