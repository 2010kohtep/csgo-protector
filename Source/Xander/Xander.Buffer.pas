unit Xander.Buffer;

{$I Default.inc}

interface

uses
  {$IFDEF MSWINDOWS} System.AnsiStrings, {$ENDIF}
  System.SysUtils;

type
  TBuffer = object
  strict private
    function GetPosition: PByte;
  public type
    TSeekType = (stCurrent, stBegin, stEnd);
  private
    function GetLast: PByte;
  protected
    FBuffer: PByte;
    FCapacity: Integer;
    FSize: Integer;
  public
    procedure Create(ABuffer: Pointer = nil; ACapacity: Integer = 0);
    procedure Free;

    procedure Write<T>(A: T); overload;
    procedure Write(const AData; ASize: Integer); overload;

    function Read<T>: T; overload;
    procedure Read(var AData; ASize: Integer); overload;

    procedure Clip(Value: Integer);

    function Seek(Value: Integer; SeekType: TSeekType): Boolean; deprecated 'Not implemented.';

    property Data: PByte read FBuffer;
    property Capacity: Integer read FCapacity write FCapacity;
    property Size: Integer read FSize write FSize;
    property Position: PByte read GetPosition;
    property Last: PByte read GetLast;
  end;

implementation

{ TBuffer }

procedure TBuffer.Clip(Value: Integer);
begin
  if Value < 0 then
    Exit;

  if Value = FCapacity then
    Exit;

  if FSize > Value then
    FSize := Value;

  FBuffer := ReallocMemory(FBuffer, Value);
end;

procedure TBuffer.Create(ABuffer: Pointer; ACapacity: Integer);
begin
  FBuffer := ABuffer;
  FCapacity := ACapacity;
  FSize := 0;
end;

procedure TBuffer.Free;
begin
  if FBuffer <> nil then
    FreeMemory(FBuffer);
end;

function TBuffer.GetLast: PByte;
begin
  Result := PByte(Integer(FBuffer) + FCapacity);
end;

function TBuffer.GetPosition: PByte;
begin
  Result := PByte(Integer(FBuffer) + FSize);
end;

procedure TBuffer.Read(var AData; ASize: Integer);
begin
  Move(FBuffer[FSize], AData, ASize);
  Inc(FSize, ASize);
end;

function TBuffer.Read<T>: T;
type
  PRawByteString = ^RawByteString;
var
  I: Integer;
  P: PRawByteString;
  UStr: UnicodeString absolute Result;
  LStr: RawByteString absolute Result;
begin
  if TypeInfo(T) = TypeInfo(UnicodeString) then
  begin
    I := StrLen(PWideChar(Integer(FBuffer) + FSize));
    SetLength(UStr, I);
    Read(PWideChar(UStr)^, I * SizeOf(WideChar));
    Inc(FSize, SizeOf(WideChar(#0)));
  end
  else
  if (TypeInfo(T) = TypeInfo(RawByteString)) {$IFDEF MSWINDOWS} or (TypeInfo(T) = TypeInfo(AnsiString)) {$ENDIF} then
  begin
//    {$REGION 'RawStrLen'}
//    P := Pointer(Integer(FBuffer) + FOffset);
//
//    I := 1;
//    while PByte(P)^ <> 0 do
//    begin
//      Inc(P);
//      Inc(I);
//    end;
//
//    Dec(I);
//    {$ENDREGION}

    I := System.AnsiStrings.StrLen(PAnsiChar(Integer(FBuffer) + FSize));
    SetLength(LStr, I);
    Read(PPointer(LStr)^, I * SizeOf(Byte));
    Inc(FSize, SizeOf(Byte(#0)));
  end
  else
    Read(Result, SizeOf(T));
end;

function TBuffer.Seek(Value: Integer; SeekType: TSeekType): Boolean;
begin
  case SeekType of
    stCurrent:
    begin

    end;

    stBegin:
    begin

    end;

    stEnd:
    begin

    end;
  end;

  Result := True;
end;

procedure TBuffer.Write(const AData; ASize: Integer);
var
  I: Integer;
begin
  if FSize + ASize > FCapacity then
  begin
    I := FCapacity + ASize + 256;
    FBuffer := ReallocMemory(FBuffer, I);
    FCapacity := I;
  end;

  Move(AData, FBuffer[FSize], ASize);
  Inc(FSize, ASize);
end;

procedure TBuffer.Write<T>(A: T);
type
  AnsiChar = Byte;
begin
  if IsManagedType(A) then // interface, string or dynamic array
  begin
    if TypeInfo(T) = TypeInfo(UnicodeString) then
    begin
      if PPointer(@A)^ <> nil then
        Write(PPointer(@A)^^, PCardinal(Integer(PPointer(@A)^) - 4)^ * SizeOf(Char) + SizeOf(Char))
      else
        Write<Byte>(0);
    end
    else
    begin
      if PPointer(@A)^ <> nil then
        Write(PPointer(@A)^^, PCardinal(Integer(PPointer(@A)^) - 4)^ * SizeOf(AnsiChar) + SizeOf(AnsiChar))
      else
        Write<Byte>(0);
    end;
  end
  else
    Write(A, SizeOf(A));
end;

end.
