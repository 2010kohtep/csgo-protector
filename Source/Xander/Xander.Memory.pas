unit Xander.Memory;

{$I Default.inc}

{$DEFINE SAFECODE}
{.$DEFINE FATAL}

{$IF CompilerVersion >= 24.0}
  {$LEGACYIFEND ON}
{$IFEND}

{$IF CompilerVersion >= 17.0}
  {$IFNDEF DEBUG}
    {$DEFINE INLINE}
  {$ENDIF}
{$IFEND}

interface

uses
  SysUtils, Windows, Types, Xander.Memory.Segments;

const
  GET_MODULE_HANDLE_EX_FLAG_PIN                = $00000001;
  GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = $00000002;
  GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS       = $00000004;

function GetModuleHandleExA(Flags: Cardinal; ModuleName: PAnsiChar; out Module: HMODULE): BOOL; stdcall; external kernel32;
function GetModuleHandleExW(Flags: Cardinal; ModuleName: PWideChar; out Module: HMODULE): BOOL; stdcall; external kernel32;

function Absolute(Addr: Pointer; Offset: Integer = 0): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function Relative(NewFunc, Address: Pointer): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function Transpose(Addr: Pointer; Offset: Integer; Deref: Boolean = False): Pointer; {$IFDEF INLINE} inline; {$ENDIF}

function IsValidMemory(Addr: Pointer): Boolean;
function IsExecMemory(Addr: Pointer): Boolean;

function AllocExecMem(Size: Cardinal): Pointer;
procedure WriteNOPs(Addr: Pointer; Count: Cardinal);
function SetProtect(Addr: Pointer; Protect: Cardinal; Size: Integer): Cardinal;

function GetModuleSize(Module: HMODULE): Integer; overload;
function GetModuleSize(Module: Pointer): Integer; overload;

function GetSectionPtr(Module: Pointer; Name: PAnsiChar): PImageSectionHeader;
function GetSectionSize(Module: Pointer; Name: PAnsiChar): Integer;
function GetAddressBase(Addr: Pointer): HMODULE;

function WriteLStr(Addr: Pointer; const Value: AnsiString): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function WriteWStr(Addr: Pointer; Value: PWideChar): Pointer;
function WriteCStr(Addr: Pointer; Value: PAnsiChar): Pointer;
function WriteBuffer(Addr: Pointer; const Buffer: array of Byte): Pointer;
function WriteInt64(Addr: Pointer; Value: Int64): Pointer;
function WritePointer(Addr, Value: Pointer): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function WriteDouble(Addr: Pointer; Value: Double): Pointer;
function WriteFloat(Addr: Pointer; Value: Single): Pointer;
function WriteLong(Addr: Pointer; Value: Cardinal): Pointer;
function WriteWord(Addr: Pointer; Value: Word): Pointer;
function WriteByte(Addr: Pointer; Value: Byte): Pointer;

function FindBytePtr(Start: Pointer; Size: Cardinal; Value: Byte; Offset: Integer = 0; Back: Boolean = False): Pointer;
function FindWordPtr(Start: Pointer; Size: Cardinal; Value: Word; Offset: Integer = 0; Back: Boolean = False): Pointer;
function FindLongPtr(Start: Pointer; Size: Cardinal; Value: Cardinal; Offset: Integer = 0; Back: Boolean = False): Pointer;
function FindPattern(Addr: Pointer; Len: Cardinal; const Pattern: array of Byte; Offset: Integer = 0): Pointer; overload;
function FindPattern(Addr: Pointer; Len: Cardinal; Pattern: Pointer; PatternSize: Cardinal; Offset: Integer = 0; IgnoreFF: Boolean = True; Ignore00: Boolean = False): Pointer; overload;

function FindPushString(Module: Pointer; Str: PAnsiChar): Pointer; overload;
function FindPushString(Addr: Pointer; Len: Cardinal; Str: PAnsiChar): Pointer; overload;

function FindStackPrologue(Addr: Pointer; Offset: Integer = 0; Back: Boolean = True): Pointer;

procedure InsertFunc(From, Dest: Pointer; IsCall: Boolean);
procedure InsertCall(From, Dest: Pointer); {$IFDEF INLINE} inline; {$ENDIF}
procedure InsertJump(From, Dest: Pointer); {$IFDEF INLINE} inline; {$ENDIF}

function CheckByte(Addr: Pointer; Value: Byte; Offset: Integer = 0): Boolean; {$IFDEF INLINE} inline; {$ENDIF}
function CheckWord(Addr: Pointer; Value: Word; Offset: Integer = 0): Boolean; {$IFDEF INLINE} inline; {$ENDIF}
function CheckLong(Addr: Pointer; Value: Cardinal; Offset: Integer = 0): Boolean; {$IFDEF INLINE} inline; {$ENDIF}

function Bounds(AddrStart, AddrEnd: Pointer; Addr: Pointer): Boolean; {$IFDEF INLINE} inline; {$ENDIF}

function FindRefAddr(Addr: Pointer; Len: Cardinal; Ref: Pointer; IgnoreHdr: Boolean = True; Hdr: Byte = 0): Pointer;
function FindRefCall(Addr: Pointer; Len: Cardinal; Ref: Pointer): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function FindRefJump(Addr: Pointer; Len: Cardinal; Ref: Pointer): Pointer; {$IFDEF INLINE} inline; {$ENDIF}

function HookRefAddr(Module: Pointer; Ref, NewRef: Pointer; IgnoreHdr: Boolean; Hdr: Byte = $00): Cardinal; overload;
function HookRefAddr(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer; IgnoreHdr: Boolean; Hdr: Byte = $00): Cardinal; overload;

function HookRefCall(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer): Cardinal overload; {$IFDEF INLINE} inline; {$ENDIF}
function HookRefCall(Module: Pointer; Ref, NewRef: Pointer): Cardinal overload; {$IFDEF INLINE} inline; {$ENDIF}
function HookRefJump(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer): Cardinal overload; {$IFDEF INLINE} inline; {$ENDIF}
function HookRefJump(Module: Pointer; Ref, NewRef: Pointer): Cardinal overload; {$IFDEF INLINE} inline; {$ENDIF}

function FindAddr(Addr: Pointer; Offset: Integer; Back: Boolean; Hdr: Byte): Pointer;
function FindAddrEx(Addr: Pointer; Back: Boolean; Hdr: Byte): Pointer; {$IFDEF INLINE} inline; {$ENDIF}
function FindNextAddr(Addr: Pointer; Number: Cardinal; Offset: Integer = 0; Back: Boolean = False; Hdr: Byte = $E8): Pointer;
function FindNextCall(Addr: Pointer; Number: Cardinal; Offset: Integer = 0; Back: Boolean = False): Pointer;
function FindNextCallEx(Addr: Pointer; Back: Boolean = False): Pointer; overload; {$IFDEF INLINE} inline; {$ENDIF}
function FindNextCallEx(Addr: Pointer; Number: Cardinal; Back: Boolean = False): Pointer; overload; {$IFDEF INLINE} inline; {$ENDIF}
function FindNextJump(Addr: Pointer; Number: Cardinal; Offset: Integer = 0; Back: Boolean = False): Pointer;
function FindNextJumpEx(Addr: Pointer; Back: Boolean = False): Pointer; {$IFDEF INLINE} inline; {$ENDIF}

function HookRegular(OldFunc, NewFunc: Pointer; Size: Integer = 0): Pointer;
function HookWinAPI(OldFunc, NewFunc: Pointer): Pointer;
procedure RestoreWinAPI(HkAddr: Pointer);

function StartThread(Func: TThreadFunc): THandle; overload;
function StartThread(Func: TThreadFunc; Arg: Pointer): THandle; overload;

type
  PThreadInfo = ^TThreadInfo;
  TThreadInfo = record
    StartFunction: Pointer;
  end;

function GetThreadInfo: PThreadInfo;

const
  XANDER_MEMORY_DONT_CHANGE_PROTECTION = 1 shl 0;

procedure SetXanderMemoryFlags(Flags: Integer);
procedure UnsetXanderMemoryFlags(Flags: Integer);

function GetInstructionLength(APC: PByte): Integer;

implementation

var
  XanderMemoryFlags: Integer = 0;

procedure SetXanderMemoryFlags(Flags: Integer);
begin
  XanderMemoryFlags := XanderMemoryFlags or Flags;
end;

procedure UnsetXanderMemoryFlags(Flags: Integer);
begin
  XanderMemoryFlags := XanderMemoryFlags and not Flags;
end;

function StrLen(S: Pointer; Wide: Boolean): Integer;
var
  P: Pointer;
begin
  if (S = nil) or (PByte(S)^ = 0) then
  begin
    Result := 0;
    Exit;
  end;

  P := S;

  if Wide then
    while PWord(P)^ <> $0000 do Inc(Integer(P), SizeOf(WideChar))
  else
    while PByte(P)^ <> $00 do Inc(Integer(P), SizeOf(AnsiChar));

  Result := Integer(P) - Integer(S);
end;

function StrCopy(Dest, Source: Pointer; Wide: Boolean): Pointer;
var
  I: Integer;
begin
  if Wide then
  begin
    I := StrLen(Source, True);
    Move(Source^, Dest^, I + SizeOf(WideChar));
    Result := @PWideChar(Dest)[I];
  end
  else
  begin
    I := StrLen(Source, False);
    Move(Source^, Dest^, I + SizeOf(AnsiChar));
    Result := @PAnsiChar(Dest)[I];
  end;
end;

function StrIdent(S1, S2: PAnsiChar): Boolean;
begin
  Result := CompareMem(S1, S2, StrLen(S1, False) + 1);
end;

procedure Crash(const Func: string);
var
  Buf: array[0..511] of Char;
begin
  StrFmt(Buf, '%s: Fatal error.', [Func]);
  MessageBox(HWND_DESKTOP, Buf, 'Fatal Error', MB_ICONERROR or MB_SYSTEMMODAL);
  ExitProcess(0);
end;

function Absolute(Addr: Pointer; Offset: Integer = 0): Pointer;
begin
  if Addr = nil then
    Exit(nil);

  Addr := @PByte(Addr)[Offset];
  Result := Pointer(Integer(Addr) + PInteger(Addr)^ + SizeOf(Pointer));
end;

function Relative(NewFunc, Address: Pointer): Pointer;
begin
  Result := Pointer(Integer(NewFunc) - Integer(Address) - SizeOf(Pointer));
end;

function Transpose(Addr: Pointer; Offset: Integer; Deref: Boolean = False): Pointer;
begin
  if Addr = nil then
    Exit(nil);

  Result := Pointer(Integer(Addr) + Offset);

  if Deref then
    Result := PPointer(Result)^;
end;

function IsValidMemory(Addr: Pointer): Boolean;
var
  Mem: TMemoryBasicInformation;
begin
  if Addr = nil then
    Exit(False);

  if VirtualQuery(Addr, Mem, SizeOf(Mem)) <> SizeOf(Mem) then
    Exit(False);

  if (Mem.Protect = 0) or (Mem.Protect = PAGE_NOACCESS) then
    Exit(False);

  Exit(True);
end;

function IsExecMemory(Addr: Pointer): Boolean;
var
  Mem: TMemoryBasicInformation;
begin
  if VirtualQuery(Addr, Mem, SizeOf(Mem)) <> SizeOf(Mem) then
    Exit(False);

  if (Mem.Protect = 0) or (Mem.Protect = PAGE_NOACCESS) then
    Exit(False);

  case Mem.Protect of
    PAGE_EXECUTE,
    PAGE_EXECUTE_READ,
    PAGE_EXECUTE_READWRITE,
    PAGE_EXECUTE_WRITECOPY: Exit(True);
  else
    Exit(False);
  end;
end;

function AllocExecMem(Size: Cardinal): Pointer;
var
  OldProtect: Cardinal;
begin
  GetMem(Result, Size);
  VirtualProtect(Result, Size, PAGE_EXECUTE_READWRITE, OldProtect);
end;

procedure WriteNOPs(Addr: Pointer; Count: Cardinal);
var
  Protect: Cardinal;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Count = 0) then
    {$IFDEF FATAL} Crash('SetNopes'); {$ELSE} Exit; {$ENDIF}
  {$ENDIF}

  Protect := SetProtect(Addr, PAGE_EXECUTE_READWRITE, Count);
  FillChar(Addr^, Count, $90);
  SetProtect(Addr, Protect, Count);
end;

function GetModuleSize(Module: HMODULE): Integer;
var
  DOS: PImageDosHeader;
  NT: PImageNtHeaders;
begin
  {$IFDEF SAFECODE}
  if Module = 0 then
    {$IFDEF FATAN} begin Crash('GetModuleSize'); Exit(0); {$ELSE} Exit(0); {$ENDIF}
  {$ENDIF}

  DOS := Pointer(Module);
  NT := PImageNtHeaders(Integer(DOS) + DOS._lfanew);

  Result := NT^.OptionalHeader.SizeOfImage;
end;

function GetModuleSize(Module: Pointer): Integer;
begin
  Result := GetModuleSize(HMODULE(Module));
end;

function GetSectionPtr(Module: Pointer; Name: PAnsiChar): PImageSectionHeader;
type
  PImageSectionHeaderArray = ^TImageSectionHeaderArray;
  TImageSectionHeaderArray = array of TImageSectionHeader;
var
  DOS: PImageDosHeader;
  NT: PImageNtHeaders;
  I: Integer;
begin
  DOS := Module;
  NT := PImageNtHeaders(Integer(DOS) + DOS._lfanew);

  Result := PImageSectionHeader(Integer(@NT.OptionalHeader) + NT^.FileHeader.SizeOfOptionalHeader);

  for I := 0 to NT^.FileHeader.NumberOfSections - 1 do
  begin
    if not StrIdent(@Result.Name, Name) then
      Exit;

    Inc(Result, SizeOf(Result^));
  end;

  Result := nil;
end;

function GetSectionSize(Module: Pointer; Name: PAnsiChar): Integer;
var
  Section: PImageSectionHeader;
begin
  Section := GetSectionPtr(Module, Name);

  if Section = nil then
    Result := 0
  else
    Result := Section^.SizeOfRawData;
end;

function GetAddressBase(Addr: Pointer): HMODULE;
begin
  if not GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS or
    GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, Addr, Result) then
    Result := 0;
end;

function SetProtect(Addr: Pointer; Protect: Cardinal; Size: Integer): Cardinal;
begin
  if XanderMemoryFlags and XANDER_MEMORY_DONT_CHANGE_PROTECTION <> 0 then
    Exit(0);

  VirtualProtect(Addr, Size, Protect, Result);
end;

function WriteUStr(Addr: Pointer; const Value: WideString): Pointer;
begin
  Result := WriteWStr(Addr, PWideChar(Value));
end;

function WriteLStr(Addr: Pointer; const Value: AnsiString): Pointer;
begin
  Result := WriteCStr(Addr, PAnsiChar(Value));
end;

function WriteWStr(Addr: Pointer; Value: PWideChar): Pointer;
var
  Len: Integer;
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Value = nil) or (Value^ = #0) then
    {$IFDEF FATAL} Crash('WriteWStr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Len := (StrLen(Value, True) * SizeOf(WideChar(#0))) + SizeOf(WideChar(#0));

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, Len);
  StrCopy(Addr, Value, True);
  SetProtect(Addr, Old, Len);

  Result := @TByteDynArray(Addr)[Len];
end;

function WriteCStr(Addr: Pointer; Value: PAnsiChar): Pointer;
var
  Len: Integer;
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Value = nil) or (Value^ = #0) then
    {$IFDEF FATAL} Crash('WriteCStr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Len := StrLen(Value, False) + SizeOf(AnsiChar(#0));

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, Len);
  StrCopy(Addr, Value, False);
  SetProtect(Addr, Old, Len);

  Result := @TByteDynArray(Addr)[Len];
end;

function WriteBuffer(Addr: Pointer; const Buffer: array of Byte): Pointer;
var
  I: Integer;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Length(Buffer) <= 0) then
    {$IFDEF FATAL} Crash('WriteBuffer'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  for I := 0 to Length(Buffer) - 1 do
  begin
    WriteByte(Addr, Buffer[I]);
    Inc(Integer(Addr));
  end;

  Result := @TByteDynArray(Addr)[SizeOf(Buffer)];
end;


function WriteInt64(Addr: Pointer; Value: Int64): Pointer;
var
  Protect: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then
    {$IFDEF FATAL} Crash('WriteInt64'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Protect := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PInt64(Addr)^ := Value;
  SetProtect(Addr, Protect, SizeOf(Value));
  Result := Pointer(Cardinal(Addr) + SizeOf(Value));
end;

function WritePointer(Addr, Value: Pointer): Pointer;
begin
  Result := WriteLong(Addr, Cardinal(Value));
end;

function WriteDouble(Addr: Pointer; Value: Double): Pointer;
var
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('WriteDouble'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PDouble(Addr)^ := Value;
  SetProtect(Addr, Old, SizeOf(Value));

  Result := @TByteDynArray(Addr)[SizeOf(Value)];
end;

function WriteFloat(Addr: Pointer; Value: Single): Pointer;
var
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('WriteFloat'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PSingle(Addr)^ := Value;
  SetProtect(Addr, Old, SizeOf(Value));

  Result := @TByteDynArray(Addr)[SizeOf(Value)];
end;

function WriteLong(Addr: Pointer; Value: Cardinal): Pointer;
var
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('WriteLong'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PCardinal(Addr)^ := Value;
  SetProtect(Addr, Old, SizeOf(Value));

  Result := @TByteDynArray(Addr)[SizeOf(Value)];
end;

function WriteWord(Addr: Pointer; Value: Word): Pointer;
var
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('WriteWord'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PWord(Addr)^ := Value;
  SetProtect(Addr, Old, SizeOf(Value));

  Result := @TByteDynArray(Addr)[SizeOf(Value)];
end;

function WriteByte(Addr: Pointer; Value: Byte): Pointer;
var
  Old: Cardinal;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then
    {$IFDEF FATAL}
    Crash('WriteByte');
    {$ELSE}
    begin Result := nil; Exit; end;
    {$ENDIF}
  {$ENDIF}

  Old := SetProtect(Addr, PAGE_EXECUTE_READWRITE, SizeOf(Value));
  PByte(Addr)^ := Value;
  SetProtect(Addr, Old, SizeOf(Value));

  Result := @TByteDynArray(Addr)[SizeOf(Value)];
end;

function MemInc(Addr: Pointer): Pointer; begin Result := Pointer(Integer(Addr) + 1) end;
function MemDec(Addr: Pointer): Pointer; begin Result := Pointer(Integer(Addr) - 1) end;

function FindBytePtr(Start: Pointer; Size: Cardinal; Value: Byte; Offset: Integer; Back: Boolean): Pointer;
var
  F: function(Addr: Pointer): Pointer;
begin
  {$IFDEF SAFECODE}
  if (Start = nil) or (Size = 0) then
    {$IFDEF FATAL} Crash('FindBytePtr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  if Back then F := @MemDec else F := @MemInc;

  while Size > 0 do
  begin
    if PByte(Start)^ = Value then
    begin
      Result := Pointer(Integer(Start) + Offset);
      Exit;
    end;

    Start := F(Start);
    Dec(Size);
  end;

  Result := nil;
  Exit;
end;

function FindWordPtr(Start: Pointer; Size: Cardinal; Value: Word; Offset: Integer; Back: Boolean): Pointer;
var
  F: function(Addr: Pointer): Pointer;
begin
  {$IFDEF SAFECODE}
  if (Start = nil) or (Size = 0) then
    {$IFDEF FATAL} Crash('FindWordPtr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  if Back then F := @MemDec else F := @MemInc;

  while Size > 0 do
  begin
    if PWord(Start)^ = Value then
    begin
      Result := Pointer(Integer(Start) + Offset);
      Exit;
    end;

    Start := F(Start);
    Dec(Size);
  end;

  Result := nil;
  Exit;
end;

function FindLongPtr(Start: Pointer; Size: Cardinal; Value: Cardinal; Offset: Integer; Back: Boolean): Pointer;
var
  F: function(Addr: Pointer): Pointer;
begin
  {$IFDEF SAFECODE}
  if (Start = nil) or (Size = 0) then
    {$IFDEF FATAL} Crash('FindLongPtr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  if not IsValidMemory(Transpose(Start, Size)) then
    Dec(Size, SizeOf(LongWord));

  if Back then F := @MemDec else F := @MemInc;

  while Size > 0 do
  begin
    if PCardinal(Start)^ = Value then
    begin
      Result := Pointer(Integer(Start) + Offset);
      Exit;
    end;

    Start := F(Start);
    Dec(Size);
  end;

  Result := nil;
  Exit;
end;

function CompareMemory(Dest, Source: PByte; Len: Integer; IgnoreFF: Boolean; Ignore00: Boolean): Boolean;
var
  I: Integer;
  B: Byte;
begin
  for I := 0 to Len - 1 do
  begin
    B := TByteDynArray(Source)[I];

    if IgnoreFF and (B = $FF) then
      Continue;

    if Ignore00 and (B = $00) then
      Continue;

    if TByteDynArray(Dest)[I] <> B then
      Exit(False);
  end;

  Result := True;
end;

function FindPattern(Addr: Pointer; Len: Cardinal; const Pattern: array of Byte; Offset: Integer): Pointer;
begin
  Result := FindPattern(Addr, Len, @Pattern[0], Length(Pattern), Offset, True, False);
end;

function FindPattern(Addr: Pointer; Len: Cardinal; Pattern: Pointer; PatternSize: Cardinal; Offset: Integer;
  IgnoreFF: Boolean; Ignore00: Boolean): Pointer;
var
  AddrEnd: Pointer;
  Skipped: Integer;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Len = 0) or (Pattern = nil) or (PatternSize = 0) then
    {$IFDEF FATAL} Crash('FindPattern'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Skipped := 0;

  repeat
    if IgnoreFF and (PByte(Pattern)^ = $FF) then
    begin
      Inc(Integer(Pattern));
      Dec(PatternSize); Inc(Skipped);
      Continue;
    end;

    if Ignore00 and (PByte(Pattern)^ = $00) then
    begin
      Inc(Integer(Pattern));
      Dec(PatternSize); Inc(Skipped);
      Continue;
    end;

    Break;
  until False;

  AddrEnd := Pointer(Cardinal(Addr) + Len);

  while Addr <> AddrEnd do
  begin
    if (PByte(Addr)^ = PByte(Pattern)^) and CompareMemory(Addr, Pattern, PatternSize, IgnoreFF, Ignore00) then
    begin
      Result := Pointer(Integer(Addr) - Skipped + Offset);
      Exit;
    end;

    Inc(Cardinal(Addr), 1);
  end;

  Result := nil;
end;

function FindPushString(Module: Pointer; Str: PAnsiChar): Pointer;
var
  P: Pointer;
  A: array[0..4] of Byte;

  Code, Data: PImageSectionHeader;

  CodeBase, CodeEnd: Pointer; CodeSize: Cardinal;
  DataBase, DataEnd: Pointer; DataSize: Cardinal;
begin
  {$IFDEF SAFECODE}
  if (Module = nil) or (Str = nil) or (Str^ = #0) then
    {$IFDEF FATAL} Crash('FindPushString'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Code := GetSegmentByCharacteristics(HMODULE(Module), IMAGE_SCN_CNT_CODE, False);
  Data := GetSegmentByCharacteristics(HMODULE(Module), IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_READ or IMAGE_SCN_MEM_WRITE);

  GetSegmentBounds(HMODULE(Module), Code, CodeBase, CodeEnd); CodeSize := Cardinal(Integer(CodeEnd) - Integer(CodeBase) - 1);
  GetSegmentBounds(HMODULE(Module), Data, DataBase, DataEnd); DataSize := Cardinal(Integer(DataEnd) - Integer(DataBase) - 1);

  P := FindPattern(DataBase, DataSize, Str, StrLen(Str, False), 0);

  if P = nil then
    Exit(nil);

  A[0] := $68;
  PPointer(@A[1])^ := P;

  Result := FindPattern(CodeBase, CodeSize, @A[0], SizeOf(A), 0);
end;

function FindPushString(Addr: Pointer; Len: Cardinal; Str: PAnsiChar): Pointer;
var
  P: Pointer;
  A: array[0..4] of Byte;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Len = 0) or (Str = nil) or (Str^ = #0) then
    {$IFDEF FATAL} Crash('FindPushString'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  P := FindPattern(Addr, Len, Str, StrLen(Str, False), 0);

  if P = nil then
  begin
    Result := nil;
    Exit;
  end;

  A[0] := $68;
  PPointer(@A[1])^ := P;

  Result := FindPattern(Addr, Len, @A[0], SizeOf(A), 0);
end;

function FindStackPrologue(Addr: Pointer; Offset: Integer = 0; Back: Boolean = True): Pointer;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then
    {$IFDEF FATAL} Crash('FindStackPrologue'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  Result := FindWordPtr(Addr, 1024, $8B55, Offset, Back);
end;

procedure InsertFunc(From, Dest: Pointer; IsCall: Boolean);
var
  B: Byte;
begin
  if IsCall then B := $E8 else B := $E9;

  WriteByte(From, B);
  WriteLong(Transpose(From, 1), Cardinal(Relative(Transpose(Dest, -1), From)));
end;

procedure InsertCall(From, Dest: Pointer);
begin
  InsertFunc(From, Dest, True);
end;

procedure InsertJump(From, Dest: Pointer);
begin
  InsertFunc(From, Dest, False);
end;

function CheckByte(Addr: Pointer; Value: Byte; Offset: Integer): Boolean;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('CheckByte'); {$ELSE} begin Result := False; Exit; end; {$ENDIF}
  {$ENDIF}

  Result := TByteDynArray(Addr)[Offset] = Value;
end;

function CheckWord(Addr: Pointer; Value: Word; Offset: Integer): Boolean;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('CheckWord'); {$ELSE} begin Result := False; Exit; end; {$ENDIF}
  {$ENDIF}

  Result := PWord(@TByteDynArray(Addr)[Offset])^ = Value;
end;

function CheckLong(Addr: Pointer; Value: Cardinal; Offset: Integer): Boolean;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('CheckLong'); {$ELSE} begin Result := False; Exit; end; {$ENDIF}
  {$ENDIF}

  Result := PCardinal(@TByteDynArray(Addr)[Offset])^ = Value;
end;

function Bounds(AddrStart, AddrEnd: Pointer; Addr: Pointer): Boolean;
begin
  Result := (Integer(Addr) >= Integer(AddrStart)) and (Integer(Addr) <= Integer(AddrEnd));
end;

function FindRefAddr(Addr: Pointer; Len: Cardinal; Ref: Pointer; IgnoreHdr: Boolean; Hdr: Byte): Pointer;
var
  AddrEnd: Pointer;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Len = 0) or (Ref = nil) then
    {$IFDEF FATAL} Crash('FindRefAddr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  AddrEnd := Pointer(Cardinal(Addr) + Len - 3);

  while Addr <> AddrEnd do
  begin
    if IgnoreHdr then
    begin
      if PPointer(Addr)^ = Ref then
      begin
        Result := Addr;
        Exit;
      end
    end
    else
    if (PByte(Addr)^ = Hdr) and (Absolute(Pointer(Cardinal(Addr) + 1)) = Ref) then
    begin
      Result := Addr;
      Exit;
    end;

    Inc(Cardinal(Addr), 1);
  end;

  Result := nil;
end;

function FindRefCall(Addr: Pointer; Len: Cardinal; Ref: Pointer): Pointer;
begin
  Result := FindRefAddr(Addr, Len, Ref, False, $E8);
end;

function FindRefJump(Addr: Pointer; Len: Cardinal; Ref: Pointer): Pointer;
begin
  Result := FindRefAddr(Addr, Len, Ref, False, $E9);
end;

function HookRefAddr(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer; IgnoreHdr: Boolean; Hdr: Byte): Cardinal;
var
  P: Pointer;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Len = 0) or (Ref = nil) or (NewRef = nil) then
    {$IFDEF FATAL} Crash('HookRefAddr'); {$ELSE} begin Result := 0; Exit; end; {$ENDIF}
  {$ENDIF}

  Result := 0;

  if Ref = NewRef then
    Exit;

  repeat
    P := FindRefAddr(Addr, Len, Ref, IgnoreHdr, Hdr);

    if P = nil then
      Exit;

    if IgnoreHdr then
      WritePointer(P, NewRef)
    else
      InsertFunc(P, NewRef, Hdr = $E8);

    Inc(Result);
  until False;
end;

function HookRefAddr(Module: Pointer; Ref, NewRef: Pointer; IgnoreHdr: Boolean; Hdr: Byte): Cardinal;
var
  CodeSection: PImageSectionHeader;
  CodeStart, CodeEnd: Pointer;
begin
  {$IFDEF SAFECODE}
  if (Module = nil) or (Ref = nil) or (NewRef = nil) then
    {$IFDEF FATAL} Crash('HookRefAddr'); {$ELSE} begin Result := 0; Exit; end; {$ENDIF}
  {$ENDIF}

  CodeSection := GetSegmentByCharacteristics(HMODULE(Module), IMAGE_SCN_CNT_CODE, False);
  if CodeSection = nil then
    Exit(0);

  GetSegmentBounds(HMODULE(Module), CodeSection, CodeStart, CodeEnd);

  Result := HookRefAddr(CodeStart, Cardinal(Integer(CodeEnd) - Integer(CodeStart)), Ref, NewRef, IgnoreHdr, Hdr);
end;

function HookRefCall(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer): Cardinal;
begin
  Result := HookRefAddr(Addr, Len, Ref, NewRef, False, $E8);
end;

function HookRefCall(Module: Pointer; Ref, NewRef: Pointer): Cardinal;
begin
  Result := HookRefAddr(Module, Ref, NewRef, False, $E8);
end;

function HookRefJump(Addr: Pointer; Len: Cardinal; Ref, NewRef: Pointer): Cardinal;
begin
  Result := HookRefAddr(Addr, Len, Ref, NewRef, False, $E9);
end;

function HookRefJump(Module: Pointer; Ref, NewRef: Pointer): Cardinal;
begin
  Result := HookRefAddr(Module, Ref, NewRef, False, $E9);
end;

function FindAddr(Addr: Pointer; Offset: Integer; Back: Boolean; Hdr: Byte): Pointer;
var
  F: function(Addr: Pointer): Pointer;
  BaseAddr: Pointer;
  MemInfo: TMemoryBasicInformation;
  P, P2: Pointer;
begin
  {$IFDEF SAFECODE}
  if Addr = nil then {$IFDEF FATAL} Crash('FindAddr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  if Back then
    F := @MemDec
  else
    F := @MemInc;

  if VirtualQuery(Addr, MemInfo, SizeOf(MemInfo)) = 0 then
  begin
    Result := nil;
    Exit;
  end;

  BaseAddr := MemInfo.AllocationBase;
  P := Addr;

  repeat
    P := FindBytePtr(P, Cardinal(-1), Hdr, 0, Back);

    P2 := P;
    P2 := Transpose(P2, 1);
    P2 := Absolute(P2);

    if VirtualQuery(P2, MemInfo, SizeOf(MemInfo)) = 0 then
    begin
      P := F(P);
      Continue;
    end;

    if MemInfo.AllocationBase <> BaseAddr then
    begin
      P := F(P);
      Continue;
    end;

    Result := Pointer(Integer(P) + Offset);
    Exit;
  until False;

  Result := nil;
end;

function FindAddrEx(Addr: Pointer; Back: Boolean; Hdr: Byte): Pointer;
begin
  Result := FindAddr(Addr, 1, Back, Hdr);

  if Result <> nil then
    Result := Absolute(Result);
end;

function FindNextAddr(Addr: Pointer; Number: Cardinal; Offset: Integer; Back: Boolean; Hdr: Byte): Pointer;
var
  F: function(Addr: Pointer): Pointer;
  OffsetTo: Integer;
begin
  {$IFDEF SAFECODE}
  if (Addr = nil) or (Number = 0) then {$IFDEF FATAL} Crash('FindNextAddr'); {$ELSE} begin Result := nil; Exit; end; {$ENDIF}
  {$ENDIF}

  if Back then
    OffsetTo := -1
  else
    OffsetTo := 1;

  if not Back then
    F := @MemDec
  else
    F := @MemInc;

  Result := Addr;
  repeat
    Result := FindAddr(Result, OffsetTo, Back, Hdr);

    if Result = nil then
      Exit;

    Dec(Number);
    if Number = 0 then
    begin
      Result := Transpose(F(Result), Offset);
      Exit;
    end;
  until False;

  Result := nil;
end;

function FindNextCall(Addr: Pointer; Number: Cardinal; Offset: Integer; Back: Boolean): Pointer;
begin
  Result := FindNextAddr(Addr, Number, Offset, Back, $E8);
end;

function FindNextCallEx(Addr: Pointer; Back: Boolean): Pointer;
begin
  Result := FindAddrEx(Addr, Back, $E8);
end;

function FindNextCallEx(Addr: Pointer; Number: Cardinal; Back: Boolean): Pointer;
begin
  Result := FindNextCall(Addr, Number, 1, Back);

  if Result <> nil then
    Result := Absolute(Result);
end;

function FindNextJump(Addr: Pointer; Number: Cardinal; Offset: Integer; Back: Boolean): Pointer;
begin
  Result := FindNextAddr(Addr, Number, Offset, Back, $E9);
end;

function FindNextJumpEx(Addr: Pointer; Back: Boolean): Pointer;
begin
  Result := FindAddrEx(Addr, Back, $E9);
end;

const
  WINAPI_HEADER: array[0..4] of Byte = ($8B, $FF,  // mov edi, edi
                                        $55,       // push ebp
                                        $8B, $EC); // mov ebp, esp

function HookRegular(OldFunc, NewFunc: Pointer; Size: Integer): Pointer;
var
  InstSize: Integer;
begin
  if (OldFunc = nil) or (NewFunc = nil) then
    Exit(nil);

  if Size = 0 then
  begin
    InstSize := 0;

    while Size < 5 do
    begin
      InstSize := GetInstructionLength(Transpose(OldFunc, InstSize));
      if InstSize = 0 then
        Exit(nil);

      Inc(Size);
    end;
  end;

  Result := AllocExecMem(Size + 5);

  Move(OldFunc^, Result^, Size);

  WriteNOPs(OldFunc, Size);

  InsertJump(Transpose(Result, Size), Transpose(OldFunc, Size));
  InsertJump(OldFunc, NewFunc);
end;

function HookWinAPI(OldFunc, NewFunc: Pointer): Pointer;
var
  Addr: Pointer;
begin
  if (OldFunc = nil) or (NewFunc = nil) then
    Result := nil
  else
  begin
    if PWord(OldFunc)^ = $25FF then
    begin
      Addr := PPointer(Cardinal(OldFunc) + 2)^;
      Addr := PPointer(Addr)^;
    end
    else
      Addr := OldFunc;

   if (PCardinal(Addr)^ <> PCardinal(@WINAPI_HEADER[0])^) then
      Result := nil
    else
    begin
      InsertJump(Addr, NewFunc);
      Result := AllocExecMem(8);
      PCardinal(Result)^ := $90E58955;
      InsertJump(Pointer(Cardinal(Result) + 3), Pointer(Cardinal(Addr) + 5));
    end;
  end;
end;

procedure RestoreWinAPI(HkAddr: Pointer);
var
  Addr: PByte;
begin
  {$IFDEF SAFECODE}
   if HkAddr = nil then {$IFDEF FATAL} Crash('RestoreWinAPI'); {$ELSE} Exit; {$ENDIF}
  {$ENDIF}

  Addr := Absolute(@PByte(HkAddr)[4]);
  WriteBuffer(@Addr[-SizeOf(WINAPI_HEADER)], WINAPI_HEADER);
  FreeMem(HkAddr);
end;

function StartThread(Func: TThreadFunc): THandle; overload;
begin
  Result := StartThread(Func, nil);
end;

function StartThread(Func: TThreadFunc; Arg: Pointer): THandle; overload;
var
  ThreadId: Cardinal;
begin
  Result := BeginThread(nil, 0, Func, Arg, 0, ThreadId);

{$IFDEF DEBUG}
  WriteLn('StartThread: Id - ', ThreadId, '; Func - ', IntToHex(Integer(@Func), 8), '; Arg - ', IntToHex(Integer(Arg), 8));
{$ENDIF}
end;

threadvar
  ThreadInfo: TThreadInfo;

function GetThreadInfo: PThreadInfo;
begin
  Result := @ThreadInfo;
end;

var
  TraceCloneChecking: Boolean = False;

function GetInstructionLength(APC: PByte): Integer;
label
  Error, ModRM, ModRMFetched;
var
  Opcode, Opcode2: Byte;
  Len: Integer;
  MRM, SIB: Integer;
begin
  if APC = nil then
    Exit(0);

  Len := 0;

  repeat
    Opcode := APC^;
    Inc(APC);

    case Opcode of
      $64, $65, // FS: GS: prefixes
      $36,      // SS: prefix
      $66, $67, // operand size overrides
      $F0, $F2: // LOCK, REPNE prefixes
      begin
        Inc(Len);
      end;

      $2E, // CS: prefix, used as HNT prefix on jumps
      $3E: // DS: prefix, used as HT prefix on jumps
      begin
        Inc(Len);
        // goto process relative jmp
        // tighter check possible here
      end
      else
        Break;
    end;

    Inc(APC);
  until False;

  case Opcode of
    // ONE BYTE OPCODE, move to next opcode without remark
    $27, $2F,
    $37, $3F,
    $40, $41, $42, $43, $44, $45, $46, $47,
    $48, $49, $4A, $4B, $4C, $4D, $4E, $4F,
    $50, $51, $52, $53, $54, $55, $56, $57,
    $58, $59, $5A, $5B, $5C, $5D, $5E, $5F,
    $90, // nop
    $91, $92, $93, $94, $95, $96, $97, // xchg
    $98, $99,
    $9C, $9D, $9E, $9F,
    $A4, $A5, $A6, $A7, $AA, $AB, // string operators
    $AC, $AD, $AE, $AF,
    (* $C3, // RET handled elsewhere *)
    $C9,
    $CC, // int3
    $F5, $F8, $F9, $FC, $FD:
    begin
      Exit(Len + 1); // include opcode
    end;

    $C3: // RET
    begin
      if APC^ = $CC then
        Exit(Len + 1);
      Inc(APC);

      if APC^ = $CC then
        Exit(Len + 2);
      Inc(APC);

      if (APC[0] = $CC) and (APC[1] = $CC) then
        Exit(Len + 5);
      //Inc(APC, 2);

      goto Error;
    end;

    // TWO BYTE INSTRUCTION
    $04, $0C, $14, $1C, $24, $2C, $34, $3C,
    $6A,
    $B0, $B1, $B2, $B3, $B4, $B5, $B6, $B7,
    $C2:
    begin
      Exit(Len + 2);
    end;

		// TWO BYTE RELATIVE BRANCH
    $70, $71, $72, $73, $74, $75, $76, $77,
    $78, $79, $7A, $7B, $7C, $7D, $7E, $7F,
    $E0, $E1, $E2, $E3, $EB:
    begin
      Exit(Len + 2);
    end;

    // THREE BYTE INSTRUCTION (NONE!)

    // FIVE BYTE INSTRUCTION,
    $05, $0D, $15, $1D,
    $25, $2D, $35, $3D,
    $68,
    $A9,
    $B8, $B9, $BA, $BB, $BC, $BD, $BE, $BF:
    begin
      Exit(Len + 5);
    end;

    // FIVE BYTE RELATIVE CALL
    $E8:
    begin
      Exit(Len + 5);
    end;

    // FIVE BYTE RELATIVE BRANCH
    $E9:
    begin
      if APC[4] = $CC then
        Exit(Len + 6); // <jmp near ptr ...  int 3>

      Exit(Len + 5); // plain <jmp near ptr>
    end;

    // FIVE BYTE DIRECT ADDRESS
    $A1, $A2, $A3: // MOV AL,AX,EAX moffset...
    begin
      Exit(Len + 5);
    end;

    // ModR/M with no immediate operand
    $00, $01, $02, $03, $08, $09, $0A, $0B,
    $10, $11, $12, $13, $18, $19, $1A, $1B,
    $20, $21, $22, $23, $28, $29, $2A, $2B,
    $30, $31, $32, $33, $38, $39, $3A, $3B,
    $84, $85, $86, $87, $88, $89, $8A, $8B, $8D, $8F,
    $D1, $D2, $D3,
    $FE, $FF: // misinterprets JMP far and CALL far, not worth fixing
    begin
      Inc(Len); // count opcode
      goto ModRM;
    end;

    // ModR/M with immediate 8 bit value
    $80, $82, $83,
    $C0, $C1,
    $C6:  // with r=0?
    begin
      Inc(Len, 2); // count opcode and immediate byte
      goto ModRM;
    end;

    // ModR/M with immediate 32 bit value
    $81,
    $C7:  // with r=0?
    begin
      Inc(Len, 5); // count opcode and immediate byte
      goto ModRM;
    end;

    $9B: // FSTSW AX = 9B DF E0
    begin
      if APC^ = $DF then
      begin
        Inc(APC);
        if APC^ = $E0 then
          Exit(Len + 3);

        //Inc(APC);

        //printf("InstructionLength: Unimplemented 0x9B tertiary opcode %2x at %x\n", *p, p);
        goto Error;
      end
      else
      begin
        //printf("InstructionLength: Unimplemented 0x9B secondary opcode %2x at %x\n", *p, p);
        goto Error;
      end;
    end;

    $D9: // various FP instructions
    begin
      MRM := APC^;
      Inc(APC);
      Inc(Len); //  account for FP prefix

      case MRM of
        $C9, $D0,
        $E0, $E1, $E4, $E5,
        $E8, $E9, $EA, $EB, $EC, $ED, $EE,
        $F8, $F9, $FA, $FB, $FC, $FD, $FE, $FF:
        begin
          Exit(Len + 1);
        end
        else  // r bits matter if not one of the above specific opcodes
        begin
          case (MRM and $38) shr 3 of
            0: goto ModRMFetched;  // fld
            1: Exit(Len + 1); // fxch
            2: goto ModRMFetched; // fst
            3: goto ModRMFetched; // fstp
            4: goto ModRMFetched; // fldenv
            5: goto ModRMFetched; // fldcw
            6: goto ModRMFetched; // fnstenv
            7: goto ModRMFetched; // fnstcw
          else goto Error; // unrecognized 2nd byte
          end;
        end;
      end;
    end;

    $DB: // various FP instructions
    begin
      MRM := APC^;
      //Inc(APC);
      Inc(Len); //  account for FP prefix
      case MRM of
      $E3:
        Exit(Len + 1);
      else  // r bits matter if not one of the above specific opcodes
        goto Error; // unrecognized 2nd byte
      end;
    end;

    $DD: // various FP instructions
    begin
      MRM := APC^;
      Inc(APC);
      Inc(Len); //  account for FP prefix
      case MRM of
        $E1, $E9:
          Exit(Len + 1);
        else  // r bits matter if not one of the above specific opcodes
          case (MRM and $38) shr 3 of
            0: goto ModRMFetched;  // fld
            1: Exit(Len + 1); // fisttp
            2: goto ModRMFetched; // fst
            3: goto ModRMFetched; // fstp
            4: Exit(Len + 1); // frstor
            5: Exit(Len + 1); // fucomp
            6: goto ModRMFetched; // fnsav
            7: goto ModRMFetched; // fnstsw
          end;
          goto Error; // unrecognized 2nd byte
      end;
    end;

    $F3: // funny prefix REPE
    begin
      Opcode2 := APC^;  // get second opcode byte
      Inc(APC);
      case Opcode2 of
        $90, // == PAUSE
        $A4, $A5, $A6, $A7, $AA, $AB: // string operators
          Exit(Len + 2);
        $C3: // (REP) RET
        begin
          if APC^ <> $CC then
            Exit(Len + 2); // only (REP) RET

          Inc(APC);
          if APC^ <> $CC then
            goto error;

          Inc(APC);
          if APC^ = $CC then
            Exit(Len + 5); // (REP) RET CLONE IS LONG JUMP RELATIVE

          //Inc(APC);
          goto Error;
        end;

        $66: // operand size override (32->16 bits)
        begin
          if APC^ = $A5 then // "rep movsw"
            Exit(Len + 3);
          //Inc(APC);
          goto Error;
        end;

        else goto Error;
      end;
    end;

    $F6: // funny subblock of opcodes
    begin
      MRM := APC^;
      Inc(APC);

      if (MRM and $20) = 0 then
        Inc(Len); // 8 bit immediate operand
      goto ModRMFetched;
    end;

    $F7: // funny subblock of opcodes
    begin
      MRM := APC^;
      Inc(APC);

      if (MRM and $30) = 0 then
        Inc(Len, 4); // 32 bit immediate operand
      goto ModRMFetched;
    end;

    // Intel's special prefix opcode
    $0F:
    begin
      Inc(Len, 2); // add one for special prefix, and one for following opcode
      Opcode2 := APC^;
      Inc(APC);
      case Opcode2 of
        $31: // RDTSC
          Exit(Len);

        // CMOVxx
        $40, $41, $42, $43, $44, $45, $46, $47,
        $48, $49, $4A, $4B, $4C, $4D, $4E, $4F:
          goto ModRM;

          // JC relative 32 bits
        $80, $81, $82, $83, $84, $85, $86, $87,
        $88, $89, $8A, $8B, $8C, $8D, $8E, $8F:
          Exit(Len + 4); // account for subopcode and displacement

        // SETxx rm32
        $90, $91, $92, $93, $94, $95, $96, $97,
        $98, $99, $9A, $9B, $9C, $9D, $9E, $9F:
          goto ModRM;

        $A2: // CPUID
          Exit(Len + 2);

        $AE: // LFENCE, SFENCE, MFENCE
        begin
          Opcode2 := APC^;
          //Inc(APC);
          case Opcode2 of
            $E8, // LFENCE
            $F0, // MFENCE
            $F8: // SFENCE
              Exit(Len + 1);
            else
            begin
              //printf("InstructionLength: Unimplemented 0x0F, 0xAE tertiary opcode in clone  %2x at %x\n", opcode2, p - 1);
              goto Error;
            end;
          end;
        end;

        $AF, // imul
        $B0: // cmpxchg 8 bits
          goto Error;

        $B1, // cmpxchg 32 bits
        $B6, $B7, // movzx
        $BC, (* bsf *) $BD, // bsr
        // $BE, $BF, // movsx
        $C1, // xadd
        $C7: // cmpxchg8b
          goto ModRM;

        else
        begin
          //printf("InstructionLength: Unimplemented 0x0F secondary opcode in clone %2x at %x\n", opcode, p - 1);
          goto Error;
        end;
      end;
    end;

	 // ALL THE THE REST OF THE INSTRUCTIONS; these are instructions that runtime system shouldn't ever use
	else
		(*
      $26, $36, // ES, SS, prefixes
		  $9A,
		  $C8, $CA, $CB, $CD, $CE, $CF,
		  $D6, $D7,
		  $E4, $E5, $E6, $E7, $EA, $EB, $EC, $ED, $EF,
		  $F4, $FA, $FB:
    *)
		//printf("InstructionLength: Unexpected opcode %2x\n", opcode);
		goto Error;
  end;

ModRM:
  MRM := APC^;
  Inc(APC);

ModRMFetched:
  if TraceCloneChecking then
  begin
    //printf("InstructionLength: ModR/M byte %x %2x\n", pc, modrm);
  end;

  if MRM >= $C0 then
    Exit(Len + 1) // account for modrm opcode
  else
  begin
    (* memory access *)
    if MRM and $7 = $04 then
    begin
      (* instruction with SIB byte *)
      Inc(Len); // account for SIB byte
      SIB := APC^; // fetch the sib byte

      if SIB and $7 = $05 then
      begin
        if MRM and $C0 = $40 then
          Exit(Len + 1 + 1) // account for MOD + byte displacment
        else
          Exit(Len + 1 + 4); // account for MOD + dword displacement
      end;
    end;

    case MRM and $C0 of
      $00:
      begin
        if MRM and $7 = $05 then
          Exit(Len + 5) // 4 byte displacement
        else
          Exit(Len + 1); // zero length offset
      end;

      $80:
      begin
        Exit(Len + 5); // 4 byte offset
      end;

      else
        Exit(Len + 2); // one byte offset
    end;
  end;

Error:
  Exit(0);
end;

end.
