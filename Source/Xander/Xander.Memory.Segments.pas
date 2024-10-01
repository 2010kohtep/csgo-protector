unit Xander.Memory.Segments;

{$I Default.inc}

interface

uses
  Winapi.Windows,

  Xander.Memory.Windows;

function GetSegmentByCharacteristics(Module: HMODULE; Characteristics: Cardinal; Pedantic: Boolean = True): PImageSectionHeader;
function GetRDataSegment(Module: HMODULE): PImageSectionHeader;
function GetMainCodeSegment(Module: HMODULE): PImageSectionHeader;
function GetSegmentBounds(Module: HMODULE; Segment: PImageSectionHeader; out SegStart, SegEnd: Pointer): Boolean; overload;
function GetSegmentBounds(Segment: PImageSectionHeader; out SegStart, SegEnd: Pointer): Boolean; overload;

implementation

function GetSegmentByCharacteristics(Module: HMODULE; Characteristics: Cardinal; Pedantic: Boolean = True): PImageSectionHeader;
var
  DOS: PImageDosHeader;
  NT: PImageNtHeaders;

  I: Integer;

  Segment: PImageSectionHeader;
begin
  if Module = 0 then
    Exit(nil);

  DOS := PImageDosHeader(Module);
  NT := PImageNtHeaders(Integer(DOS) + DOS._lfanew);

  Segment := Ptr(Integer(@NT.OptionalHeader) + NT.FileHeader.SizeOfOptionalHeader);

  if Pedantic then
  begin
    for I := 0 to NT.FileHeader.NumberOfSections - 1 do
    begin
      if Segment.Characteristics = Characteristics then
        Exit(Segment);

      Inc(Segment);
    end;
  end
  else
  begin
    for I := 0 to NT.FileHeader.NumberOfSections - 1 do
    begin
      if Segment.Characteristics and Characteristics <> 0 then
        Exit(Segment);

      Inc(Segment);
    end;
  end;

  Exit(nil);
end;

function GetRDataSegment(Module: HMODULE): PImageSectionHeader;
begin
  Result := GetSegmentByCharacteristics(Module, IMAGE_SCN_CNT_INITIALIZED_DATA or IMAGE_SCN_MEM_READ);
end;

function GetMainCodeSegment(Module: HMODULE): PImageSectionHeader;
begin
  Result := GetSegmentByCharacteristics(Module, IMAGE_SCN_CNT_CODE);
end;

function GetSegmentBounds(Module: HMODULE; Segment: PImageSectionHeader; out SegStart, SegEnd: Pointer): Boolean; overload;
begin
  SegStart := nil;
  SegEnd := nil;

  if Segment = nil then
    Exit(False);

  SegStart := Ptr(Integer(Module) + Integer(Segment.VirtualAddress));
  SegEnd := Ptr(Integer(SegStart) + Integer(Segment.Misc.VirtualSize) - 1);

  Exit(True);
end;

function GetSegmentBounds(Segment: PImageSectionHeader; out SegStart, SegEnd: Pointer): Boolean;
var
  Module: HMODULE;
begin
  SegStart := nil;
  SegEnd := nil;

  if not GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS or
    GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT, PAnsiChar(Segment), Module) then
    Exit(False);

  Result := GetSegmentBounds(Module, Segment, SegStart, SegEnd);
end;

end.
