unit Protector.LocalMasterServer;

{$I Default.inc}

interface

uses
  System.Classes,
  System.SysUtils,

  Winapi.Windows,
  Winapi.WinSock,

  Protector.Common,

  Xander.MiniUDP,
  Xander.Buffer;

const
  MS_HEADER = '1';
  OOB_HEADER = -1;

  MSMAGIC = $BFEF2010;
  MSFILE    = 'mscache.dat';
  MSFILETXT = 'mscache.txt';

type
  TLocalMaster = class(TMiniUDP)
  private
    // Список серверов. Сервера хранятся в таком виде, как они выглядят для пользователя (порт не htons)
    FServerList: TStringList;
    FIsMasterOnline: Boolean;
    FCheckingMaster: Boolean;

    FTag: Integer;

    function GetPort: Word;
  public
    property IsDestMasterOnline: Boolean read FIsMasterOnline write FIsMasterOnline; // true if master is online
    property DestMasterMonitor: Boolean read FCheckingMaster; // true if monitor is enabled
    property Servers: TStringList read FServerList;
    property Port: Word read GetPort;

    constructor Create;
    destructor Destroy; override;

    procedure LoadFromFile(const FileName: string);
    procedure LoadFromMaster(const IP: string; Port: Word; const Request, Address: string);
    procedure SaveToFile(const FileName: string; Add: Boolean; AsText: Boolean = False);

    procedure SendServerList(const IP: string; Port: Word; const Offset: string);

    procedure PutServer(Addr: TSockAddrIn);
    function IsExisting(Addr: TSockAddrIn): Boolean;

    procedure StartDestMasterMonitor;
    procedure StopDestMasterMonitor;

    function GetServerIndex(IP: Cardinal; Port: Word): Integer;
    procedure PrintList;

    procedure OnReadUDP(var Buffer: TBuffer); override;

    property List: TStringList read FServerList;

    property Tag: Integer read FTag;
  end;

implementation

uses
  Protector.Global;

procedure TLocalMaster.OnReadUDP(var Buffer: TBuffer);
const
  WSAECONNRESET = 10054;

  MS_HEADER = '1';
  OOB_HEADER = -1;
  SPLIT_HEADER = -2;
var
  Addr: TSockAddrIn;

  IP: Cardinal;
  Port: Word;
begin
{$IFDEF DEBUG}
  WriteLn('TLocalMaster.OnReadUDP: Size - ', Buffer.Size, ', Header - $', IntToHex(Buffer.Data^, 2));
{$ENDIF}

  if Buffer.Read<Integer> <> -1 then
    Exit;

  if Buffer.Read<Word> = $0A66 then
  begin
{$IFDEF DEBUG}
  Write('TLocalMaster.OnReadUDP: Received server list datagram. Processing... ');
{$ENDIF}

    if LocalMaster.DestMasterMonitor then
      LocalMaster.IsDestMasterOnline := True;

    while Buffer.Position <> Buffer.Last do
    begin
      IP := Buffer.Read<Integer>;
      Port := Buffer.Read<Word>;

      Addr.sin_family := AF_INET;
      Addr.sin_addr.S_addr := IP;
      Addr.sin_port := htons(Port);

      if IsExisting(Addr) then
      begin
      {$IFDEF DEBUG}
        WriteLn('TLocalMaster.OnReadUDP: Server ', LongToIP(IP), ':', Addr.sin_port, ' is already exists.');
      {$ENDIF}
      end
      else
        LocalMaster.PutServer(Addr);
    end;

{$IFDEF DEBUG}
    WriteLn('Done. Collected ', LocalMaster.Servers.Count, ' servers.');
{$ENDIF}

    LocalMaster.SaveToFile(MSFILE, False);

{$IFDEF DEBUG}
    LocalMaster.SaveToFile(MSFILETXT, False, True);
{$ENDIF}

    Exit;
  end;

  if Buffer.Read<AnsiChar> = MS_HEADER then
  begin
{$IFDEF  DEBUG}
    WriteLn('TLocalMaster.OnReadUDP: Requested server list.');
{$ENDIF}

    Buffer.Read<Byte>; // region

    LocalMaster.SendServerList(string(Self.PeerIPStr), Self.PeerPort, string(Buffer.Read<AnsiString>));
  end;
end;


{ TLocalMaster }

constructor TLocalMaster.Create;
begin
  inherited Create(0);

  FServerList := TStringList.Create;
  FIsMasterOnline := False;
  FCheckingMaster := False;
  FTag := 0;
end;

destructor TLocalMaster.Destroy;
begin
  inherited;
end;

function TLocalMaster.GetPort: Word;
begin
  Result := Port;
end;

function TLocalMaster.GetServerIndex(IP: Cardinal; Port: Word): Integer;
var
  Addr: string;
  I: Integer;
begin
  Addr := Format('%s:%d', [inet_ntoa(TInAddr(IP)), htons(Port)]);

  for I := 0 to FServerList.Count - 1 do
  begin
    if FServerList[I] = Addr then
      Exit(I);
  end;

  Exit(-1);
end;

function TLocalMaster.IsExisting(Addr: TSockAddrIn): Boolean;
var
  Address, S: string;
begin
  Address := Format('%s:%d', [LongToIP(Addr.sin_addr.S_addr), Addr.sin_port]);

  for S in Servers do
  begin
    if Address = S then
      Exit(True);
  end;

  Exit(False);
end;

procedure TLocalMaster.LoadFromFile(const FileName: string);
var
  Buf: TBuffer;
  I: LongInt;
  F: File of Byte;
  Data: array[0..65535] of Byte;
  S: string;
begin
  if not FileExists(FileName) then
    Exit;

  AssignFile(F, FileName);
  Reset(F);
  I := FileSize(F);

  if I > SizeOf(Data) then
  begin
    CloseFile(F);
    Exit;
  end;

  BlockRead(F, Data[0], I);
  CloseFile(F);

  Buf.Create(@Data[0], SizeOf(Data));
  if Buf.Read<Cardinal> <> MSMAGIC then
    Exit;

  Dec(I, SizeOf(LongInt));
  while Buf.Size < I do
  begin
    Buf.Read<Integer>;

    // S := Format('%s:%d', [inet_ntoa(in_addr(0)), htons(Buf.Read<Word>)]);
    FServerList.Append(S);
  end;
end;

procedure TLocalMaster.LoadFromMaster(const IP: string; Port: Word; const Request, Address: string);
var
  Buf: TBuffer;
  Data: array[0..255] of Byte;
begin
  Servers.Clear;

  Buf.Create(@Data[0], SizeOf(Data));
  Buf.Write<AnsiChar>('1');
  Buf.Write<Byte>($FF);

  if Address <> '' then
    Buf.Write<AnsiString>(AnsiString(Address))
  else
    Buf.Write<AnsiString>('0.0.0.0:0');

  Buf.Write<AnsiString>(Request);
  Send(IP, Port, @Data[0], Buf.Size);
end;

procedure TLocalMaster.SaveToFile(const FileName: string; Add: Boolean; AsText: Boolean);
var
  Buf: TBuffer;
  Data: array[0..65535] of Byte;
  I: Integer;

  F: File of Byte;
  FT: TextFile;

  IP: Integer;
  Port: Word;
begin
  if AsText then
  begin
    AssignFile(FT, FileName);
    if Add then Reset(FT) else ReWrite(FT);
    WriteLn(FT, FServerList.Text);
    CloseFile(FT);

    Exit;
  end;

  Buf.Create(@Data[0], SizeOf(Data));

  Buf.Write<Cardinal>(MSMAGIC);
  for I := 0 to FServerList.Count - 1 do
  begin
    SeparateAddress(FServerList[I], IP, Port);

    Buf.Write<Integer>(IP);
    Buf.Write<Word>(Port);
  end;

  AssignFile(F, FileName);

  if Add then Reset(F) else ReWrite(F);

  BlockWrite(F, Buf.Data^, Buf.Size);
  CloseFile(F);
end;

procedure TLocalMaster.SendServerList(const IP: string; Port: Word; const Offset: string);
var
  Buf: TBuffer;
  I: Integer;
  Data: array[0..8191] of Byte;

  CurIP: Integer;
  CurPort: Word;
begin
  if Offset <> '0.0.0.0:0' then
    Exit;

  Buf.Create(@Data[0], SizeOf(Data));
  Buf.Write<Integer>(-1);
  Buf.Write<Word>($0A66);

  for I := 0 to FServerList.Count - 1 do
  begin
    SeparateAddress(FServerList[I], CurIP, CurPort);
    Buf.Write<Integer>(CurIP);
    Buf.Write<Word>(CurPort);
  end;

  Buf.Write<Integer>(0);
  Buf.Write<Word>(0);

  Send(IP, Port, Buf.Data, Buf.Size);
end;

procedure TLocalMaster.StartDestMasterMonitor;
begin
  FIsMasterOnline := False;
  FCheckingMaster := True;
end;

procedure TLocalMaster.StopDestMasterMonitor;
begin
  FCheckingMaster := False;
end;

procedure TLocalMaster.PrintList;
var
  I: Integer;
begin
  if FServerList.Count = 0 then
    WriteLn('TMasterServerParser.PrintList: List is empty.');

  for I := 0 to FServerList.Count - 1 do
    WriteLn(I, '. ', FServerList[I]);
end;

procedure TLocalMaster.PutServer(Addr: TSockAddrIn);
var
  S: string;
  I: LongInt;
begin
  S := Format('%s:%d', [inet_ntoa(Addr.sin_addr), Addr.sin_port]);
  if not FServerList.Find(S, I) then
    FServerList.Append(S);
end;

end.

