unit Xander.ClassInformer;

{$I Default.inc}

interface

uses
  Winapi.Windows,

  System.SysUtils,
  System.Generics.Collections,

  Xander.Memory.Windows,
  Xander.Memory.Segments,
  Xander.Memory.Fundamental;

type
  PRTTITypeDescriptor = ^TRTTITypeDescriptor;
  TRTTITypeDescriptor = record
    (* Always points to type_info's VFTable *)
    VFTable: PPointer;
    (* ? *)
    Spare: Pointer;
    (* Class Name *)
    Name: array[0..0] of AnsiChar;
  end;

  PPMD = ^TPMD;
  TPMD = record
    (* VFTable offset (if PMD.PDisp is -1) *)
    MDisp: Integer;
    (* VBTable offset (-1: VFTable is at displacement PMD.MDisp is -1) *)
    PDisp: Integer;
    (* Displacement of the base class VFTable pointer inside the VBTable *)
    VDisp: Integer;
  end;

  PRTTIBaseClassDescriptor = ^TRTTIBaseClassDescriptor;
  TRTTIBaseClassDescriptor = record
    (* TypeDescriptor of this base class *)
    TypeDescriptor: PRTTITypeDescriptor;
    (* Number of direct bases of this base class *)
    NumCintainedBases: LongWord;
    (* Pointer-to-member displacement info *)
    Where: TPMD;
    (* Flags, usually 0 *)
    Attributes: LongWord;
  end;

  PRTTIBaseClassArray = ^TRTTIBaseClassArray;
  TRTTIBaseClassArray = record
    ArrayOfBaseClassDescriptors: array[0..0] of PRTTIBaseClassDescriptor;
  end;

  PRTTIClassHierarchyDescriptor = ^TRTTIClassHierarchyDescriptor;
  TRTTIClassHierarchyDescriptor = record
    (* Always 0? *)
    Signature: LongWord;
    (* Bit 0 - multiple inheritance; Bit 1 - virtual inheritance *)
    Attributes: LongWord;
    (* Number of base classes. Count includes the class itself *)
    NumBaseClasses: LongWord;
    (* Array of RTTIBaseClassDescriptor *)
    BaseClassArray: PRTTIBaseClassArray;
  end;

  PRTTICompleteObjectLocator = ^TRTTICompleteObjectLocator;
  TRTTICompleteObjectLocator = record
    (* Always 0? *)
    Signature: LongWord;
    (* Offset of VFTable within the class *)
    Offset: LongWord;
    (* Constructor displacement offset *)
    CDOffset: LongWord;
    (* Class Information *)
    TypeDescriptor: PRTTITypeDescriptor;
    (* Class Hierarchy information *)
    ClassDescriptor: PRTTIClassHierarchyDescriptor;
  end;

type
  TObjectLocators = TList<PRTTICompleteObjectLocator>;

function GetRTTIDescriptor(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): PRTTITypeDescriptor; overload;
function GetRTTIDescriptor(const ModuleName: string; const Name: string): PRTTITypeDescriptor; overload;

function GetObjectLocatorsForClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): TObjectLocators; overload;
function GetObjectLocatorsForClass(const ModuleName: string; const Name: PAnsiChar): TObjectLocators; overload;

function GetVTableForLocator(ModuleStart, ModuleEnd: Pointer; Locator: PRTTICompleteObjectLocator): PPointer; overload;
function GetVTableForLocator(const ModuleName: string; Locator: PRTTICompleteObjectLocator): PPointer; overload;

function GetVTableForFirstClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): PPointer; overload;
function GetVTableForFirstClass(const ModuleName: string; const Name: string): PPointer; overload;

function GetVTableForClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar; Offset: LongWord): PPointer;

implementation

function GetRTTIDescriptor(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): PRTTITypeDescriptor;
const
  CLASS_SIGNATURE = Ord('V') shl 24 or Ord('A') shl 16 or Ord('?') shl 8 or Ord('.'); // 'VA?.'
var
  IsFull: Boolean;
  NameEx: array[0..255] of AnsiChar;
  NameLen: Integer;

  P: Pointer;

  TypeDescriptor: PRTTITypeDescriptor;
begin
  if (Name = nil) or (Name^ = #0) then
    Exit(nil);

  StrCopy(NameEx, Name);

  if PLongWord(Name)^ = CLASS_SIGNATURE then
  begin
    IsFull := True;
    NameLen := 0;
  end
  else
  begin
    IsFull := False;
    NameLen := StrLen(Name);

    PWord(@NameEx[NameLen])^ := Ord(#0) shl 8 or Ord('@');

    Inc(NameLen);
  end;

  P := ModuleStart;
  repeat
    P := TSearcher.Find<LongWord>(P, ModuleEnd, CLASS_SIGNATURE, 4);

    if P = nil then
      Exit(nil);

    TypeDescriptor := Pointer(Integer(P) - 8 - 4); // (int)addr - offsetof(RTTITypeDescriptor, name) - 4

    if IsFull then
    begin
      if StrIComp(TypeDescriptor.Name, NameEx) = 0 then
        Exit(TypeDescriptor);
    end
    else
    begin
      if StrLIComp(@PAnsiChar(@TypeDescriptor.Name[0])[4], NameEx, NameLen) = 0 then
        Exit(TypeDescriptor);
    end;
  until False;
end;

function GetRTTIDescriptor(const ModuleName: string; const Name: string): PRTTITypeDescriptor;
var
  Module: PByte;
begin
  Module := Pointer(GetModuleHandle(PChar(ModuleName)));

  if Module = nil then
    Exit(nil);

  Result := GetRTTIDescriptor(Module, @Module[GetModuleSize(Module) - 1], PAnsiChar(AnsiString(Name)));
end;

function GetObjectLocatorsForClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): TObjectLocators;
var
  TypeDescriptor: PRTTITypeDescriptor;
  ObjectLocator: PRTTICompleteObjectLocator;

  P: PByte;
begin
  Result := TObjectLocators.Create;

  TypeDescriptor := GetRTTIDescriptor(ModuleStart, ModuleEnd, Name);

  if TypeDescriptor = nil then
    Exit;

  P := ModuleStart;

  {$I Obfuscation-2.inc}

  repeat
    P := TSearcher.FindReference(P, ModuleEnd, TypeDescriptor);

    if P = nil then
      Exit;

    ObjectLocator := @P[-12]; // offsetof(RTTICompleteObjectLocator, pTypeDescriptor)

    //if (ObjectLocator.Signature = 0) and (ObjectLocator.Offset = 0) and (ObjectLocator.CDOffset = 0) then
    if (ObjectLocator.Signature = 0) and (ObjectLocator.CDOffset = 0) then
    begin
      Result.Add(ObjectLocator);
    end;

    P := @P[1];
  until False;

  Exit;
end;

function GetObjectLocatorsForClass(const ModuleName: string; const Name: PAnsiChar): TObjectLocators;
var
  Module: PByte;

//  SegStart, SegEnd: Pointer;
begin
  Module := Pointer(GetModuleHandle(PChar(ModuleName)));

  if Module = nil then
    Exit(nil);

//  if not GetSegmentBounds(GetRDataSegment(Module), SegStart, SegEnd) then
//    Exit(nil);

  Result := GetObjectLocatorsForClass(Module, @Module[GetModuleSize(Module) - 1], PAnsiChar(AnsiString(Name)));
  //Result := GetObjectLocatorsForClass(SegStart, SegEnd, PAnsiChar(AnsiString(Name)));
end;

function GetVTableForLocator(ModuleStart, ModuleEnd: Pointer; Locator: PRTTICompleteObjectLocator): PPointer;
var
  P: PByte;
begin
  P := TSearcher.FindReference(ModuleStart, ModuleEnd, Locator);

  if P <> nil then
    Exit(@P[SizeOf(Pointer)]);

  Exit(nil);
end;

function GetVTableForLocator(const ModuleName: string; Locator: PRTTICompleteObjectLocator): PPointer;
var
  Module: PByte;
begin
  Module := Pointer(GetModuleHandle(PChar(ModuleName)));

  if Module = nil then
    Exit(nil);

  Result := GetVTableForLocator(Module, @Module[GetModuleSize(Module) - 1], Locator);
end;

function GetVTableForFirstClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar): PPointer;
var
  TypeDescriptor: PRTTITypeDescriptor;
  ObjectLocator: PRTTICompleteObjectLocator;

  P: Pointer;
begin
  TypeDescriptor := GetRTTIDescriptor(ModuleStart, ModuleEnd, Name);

  if TypeDescriptor = nil then
    Exit(nil);

  P := ModuleStart;

  repeat
    P := TSearcher.FindReference(P, ModuleEnd, TypeDescriptor);

    if P = nil then
      Exit(nil);

    ObjectLocator := Pointer(Integer(P) - 12); // offsetof(RTTICompleteObjectLocator, pTypeDescriptor)

    if (ObjectLocator.Signature = 0) and (ObjectLocator.Offset = 0) and (ObjectLocator.CDOffset = 0) then
    begin
      P := TSearcher.FindReference(ModuleStart, ModuleEnd, ObjectLocator);

      if P <> nil then
        Exit(Pointer(Integer(P) + SizeOf(Pointer)));

      Exit(nil);
    end;

    P := Pointer(Integer(P) + 1);
  until False;

  Exit(nil);
end;

function GetVTableForFirstClass(const ModuleName: string; const Name: string): PPointer;
var
  Module: PByte;
begin
  Module := Pointer(GetModuleHandle(PChar(ModuleName)));

  if Module = nil then
    Exit(nil);

  Result := GetVTableForFirstClass(Module, @Module[GetModuleSize(Module) - 1], PAnsiChar(AnsiString(Name)));
end;

function GetVTableForClass(ModuleStart, ModuleEnd: Pointer; const Name: PAnsiChar; Offset: LongWord): PPointer;
var
  Locators: TObjectLocators;
  L: PRTTICompleteObjectLocator;
begin
  Locators := GetObjectLocatorsForClass(ModuleStart, ModuleEnd, Name);
  for L in Locators do
  begin
    if L.Offset = Offset then
    begin
      Result := GetVTableForLocator(ModuleStart, ModuleEnd, L);
      Exit;
    end;
  end;

  Exit(nil);
end;

end.
