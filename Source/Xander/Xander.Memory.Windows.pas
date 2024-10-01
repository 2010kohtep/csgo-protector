unit Xander.Memory.Windows;

{$I Default.inc}

interface

uses
  Winapi.Windows;

const
  GET_MODULE_HANDLE_EX_FLAG_PIN = $00000001;
  GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT = $00000002;
  GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS = $00000004;

function GetModuleHandleExA(Flags: Cardinal; ModuleName: PAnsiChar; out Module: HMODULE): BOOL; stdcall; external kernel32;
function GetModuleHandleExW(Flags: Cardinal; ModuleName: PWideChar; out Module: HMODULE): BOOL; stdcall; external kernel32;

function GetModuleSize(Module: Pointer): Cardinal;

implementation

function GetModuleSize(Module: Pointer): Cardinal;
var
  DOS: PImageDosHeader;
  NT: PImageNtHeaders;
begin
  DOS := PImageDosHeader(Module);
  NT := PImageNtHeaders(Integer(DOS) + DOS._lfanew);
  Exit(NT^.OptionalHeader.SizeOfImage);
end;

end.
