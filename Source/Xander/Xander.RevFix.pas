(*=========== (C) Copyright 2019, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  ��� ������:                                                                *)
(*   Xander.RevFix                                                             *)
(*                                                                             *)
(*  ��������:                                                                  *)
(*    ������������� ������, ������������ �������� ��������� RevEmu �           *)
(*    ����������� ���� �����������, ����� � ������� �� ����������.             *)
(*=============================================================================*)

unit Xander.RevFix;

{$I Default.inc}

interface

uses
  System.SysUtils, System.Types, Winapi.Windows, Xander.Memory;

(* ������� ������������� ������. ������ ���� ������� � ������� ������ �� �����
   ������ ���������. ���������� RF-����. *)
function Init: Integer;

(* ������, ��������� ��� ���������� �����������. *)
const
  RF_NO_ERROR = 0;                           (* ��� ������. *)
  RF_ERROR_STEAMCLIENT_NOT_FOUND = -1;       (* �� ������� ����� ��������. *)
  RF_ERROR_HWID_NOT_FOUND = -2;              (* �� ������� ����� ��������� �� HWID ���������. *)
  RF_ERROR_VOLUME_RETRIEVE_FAILED = -3;      (* �� ������� �������� ����� ���������� ����. *)
  RF_ERROR_WINAPI_NOT_HOOKED = -4;           (* ������� GetVersionExW �� ���� �����������. *)
  RF_ERROR_WINAPI_KERNEL_NOT_FOUND = -5;     (* kernel32 ���������� �� ���� �������. *)
  RF_ERROR_WINAPI_GETVERSION_NOT_FOUND = -6; (* ������� GetVersionExW �� �������. *)

type
  TRFOnError = procedure(Code: Integer); cdecl;
  TRFOnBegin = function: Boolean; cdecl;

var
  (* �������, ������������, ���� �� ������� ���������� HWID. �������� Code
     �������� RF-��� ������. *)
  RFOnError: TRFOnError = nil;
  (* �������, ������������, ����� ������� ��������� HWID ����������. ����������
     True, ���� ����������� ����� ����������, � False, ���� ��������. *)
  RFOnBegin: TRFOnBegin = nil;

(* ������� ��������� �������, ������� ��������� ��� ������ ��������� HWID.
   ���������� ���������� ���������� ��� nil, ���� �������� Func ��������� nil. *)
function SetOnError(Func: TRFOnError): TRFOnError;
(* ������� ��������� �������, ������� ��������� ��� ������ ��������� HWID.
   ���������� ���������� ���������� ��� nil, ���� �������� Func ��������� nil. *)
function SetOnBegin(Func: TRFOnBegin): TRFOnBegin;

implementation

var
  (* steamclient.dll ���� � � ������. ������ �������� ���������� � �����
     � Global.pas �����, �� ����� ������� ������ ����� ��������������, � ��������
     �� ����. *)
  SCBase: Pointer;
  SCSize: Cardinal;

var
  (* ��������� HDD/SSD ����� (HWID). ����� ���������� ���� ���������� �� ������
     ������������� GetVersionExW ������� ����� ������������� � SteamID. *)
  HardwareID: PAnsiChar;

function GetModuleNameFromAddr(Addr: Pointer): string;
var
  Module: HMODULE;
begin
  Module := GetAddressBase(Addr);
  Result := GetModuleName(Module);
  Result := ExtractFileName(Result);
  Result := ChangeFileExt(Result, '');
  Result := LowerCase(Result);
end;

type
  TGetVersionExW = function(var lpVersionInformation: TOSVersionInfoW): BOOL; stdcall;

var
  (* �������-��������, ���������� ������������ GetVersionExW. ����� ������� �������
     ����� ��������� �����, ������� ���� '��������' � �������� �������. *)
  orgGetVersionExW: TGetVersionExW;

function PerformEmulatorModification: Integer;
var
  VolumeId: Cardinal;
begin
  (* �������� ��������� �� ���� ���������, � ����� � ������. *)
  SCBase := Ptr(GetModuleHandle('steamclient.dll'));

  if SCBase = nil then
  begin
    (* �� ������� �������� ���� ���������. ������ ����� ������������� ���������
       ����������� (����/�� � ��� �����), ���� �������� �����. *)

    Exit(RF_ERROR_STEAMCLIENT_NOT_FOUND);
  end;

  SCSize := GetModuleSize(Cardinal(SCBase));

  (* �������� ��������� �� ����������, �������� HWID. *)
  HardwareID := FindPushString(SCBase, SCSize, PAnsiChar('%32.32s'));
  if HardwareID = nil then
  begin
    (* ������ ������ �������������� ����� �� �������. ����������� ����� �����,
       �� ����� ���������������� � ������� ���������� ���� ��������. *)

    Exit(RF_ERROR_HWID_NOT_FOUND);
  end;

  HardwareID := Transpose(HardwareID, -4);
  HardwareID := PPointer(HardwareID)^;

  if not IsValidMemory(HardwareID) then
  begin
    (* ������������� ������� � ��������� �� ������������ ������. *)

    Exit(RF_ERROR_HWID_NOT_FOUND);
  end;

  (* �������� ����� ���� ���������� �����. ����� �������� �� ����� �����������
     ������� � �� �������� �������, �������� ������ ���������. *)
  if not GetVolumeInformation('C:\', nil, 0, @VolumeId, PCardinal(nil)^, PCardinal(nil)^, nil, 0) then
  begin
    (* ���-�� ����� �� ���. *)

    Exit(RF_ERROR_VOLUME_RETRIEVE_FAILED);
  end;

  (* �������� ���������� ����� � ��������� HWID. *)
  StrCopy(HardwareID, PAnsiChar(AnsiString(IntToStr(VolumeId))));

  Exit(RF_NO_ERROR);
end;

function GetVersionExW(var lpVersionInformation: TOSVersionInfoW): BOOL; stdcall;
var
  RetAddr: Pointer;
  Name: string;

  P: Pointer;
  Jump: Cardinal;

  Code: Integer;
begin
  (* �������� ����� �������� �� �������. �����, ����� ���������� ����� ������. *)
  RetAddr := ReturnAddress;

  (* �������� ��� ������, ������� ������ �������. *)
  Name := GetModuleNameFromAddr(RetAddr);

  (* ���������, ��������� �� ����� �� ������� ���������, ���������� HWID. *)
  if CheckWord(RetAddr, $D6FF, -2) and (CheckByte(RetAddr, $85) or CheckByte(RetAddr, $3B)) and SameStr(Name, 'steamclient') then
  begin
    if @RFOnBegin <> nil then
    begin
      (* ������� OnBegin ������� False, ����������� �� ���������. *)
      if not RFOnBegin then
      begin
        Result := orgGetVersionExW(lpVersionInformation);
        Exit;
      end;
    end;

    (* ���� �����, ������� ��������� ������ ��������� �������. �����, �������
       � ��������, ��������� � ��������� � ���� �� ��������� 0, �� ����������
       ������� ��������� ������, ��������� 0. ��� ����� �� ����������, �������
       ������ 'test eax, eax' �������� �� ���������� 'xor eax, eax', �������
       ��������� ���� ZF � 1, ��� �������� ��������� ������� � ����� �������,
       ����� ������������ �������� � ���� � ��������� �������. *)
    P := FindWordPtr(RetAddr, 64, $840F, -2);
    P := WriteWord(P, $C031); // xor eax, eax

    (* ������������� ����� ���-����� ������ �������, �� ������ ������ *)
    WriteNOPs(Transpose(P, -7), 5);

    (* ����� ������ ���������� �����, ���� ����� �������� ������, �� ��������
       �������� �� jz ������, ������� ��� ���������. � ��� ������� �� �������
       ���������� � ������� ������� � ����� �������. �� ����� �������� ��� �������� ��
       �������. *)
    Jump := PCardinal(Transpose(P, 2))^;

    (* ��� ��� ������� ���������� 0, �� SteamID �� ����� ������������, ��� ���
       �������� ����� �������, ��� ������� ����������� � �������. �����������
       0 ���������� ��������� 'xor eax, eax', ������� ����������� ����� �����
       ���� ������ ������. �� ������� ��� ���������� �� 'mov al, 1', ��� ��������
       ������� �������� ���������, ��� �� � �������, ���� �������, ����� ����������
       ���������. *)
    P := Transpose(P, 6);
    P := Transpose(P, Jump);
    WriteWord(P, $01B0);

    (* ������ �� ����� ���������� ��� �������� HWID. *)
    Code := PerformEmulatorModification;

    if Code <> RF_NO_ERROR then
    begin
      (* �� ������� ���������� ��������. ��� ��� �� �� ����� �����������, �����
         ����� ������� ���� GetVersionExW �������, �� ������ ������� �������, �������
         ������� ��� ����������, ������� ���������� ��������� ������, ��� ������
         �������� ������������ � ��������. *)

      if @RFOnError <> nil then
        RFOnError(Code);
    end;
  end;

  Result := orgGetVersionExW(lpVersionInformation);
end;

function SetOnError(Func: TRFOnError): TRFOnError;
begin
  if @Func = nil then
    Exit(nil);

  Result := @RFOnError;
  @RFOnError := @Func;
end;

function SetOnBegin(Func: TRFOnBegin): TRFOnBegin;
begin
  if @Func = nil then
    Exit(nil);

  Result := @RFOnBegin;
  @RFOnBegin := @Func;
end;


function Init: Integer;
var
  H: HMODULE;
  P: Pointer;
begin
  (*
    ����� ���������� ����� ����������.

    ������� ���������, ������� �������� ������� ����, � ����� ������ ����� ������
    �������� ������� GetVersionExW. ����� ��� ������� � �� ����� �� �������,
    ��������� ���������� ������ ����� �� ������������, ���� ������ IDA Pro,
    ������ ��� ������� ��� ������� ���������� �������, ����� �� ����� ��������
    ���� HWID. �� ����� �� ����� ��������� � ������������� steamclient.dll �
    ��������� ������, �� ��� �������� �������� ��������� �����, ��� �������� � ����,
    ��� � ��������� ������� ����� �� ����� �������� ��������� ����, � ��������
    ����� ��������� ������������� ������. ��� ��������� ������ ����� (� �� ����
    ������ �������), �� � ��������� ����� � ���� �������� �������� ������ ���������
    � ����� ���������������� ������� ������ �������. ������ ������� ����� �������� �������
    ������������� ������������ ������ � ������� ������ ��� �������� ����������,
    ����� �� ����� �������, ��� �������� ��� �� ��������, � �������� �����������
    ������� � GetVersionExW, ������� ����� ������ ������ ���������� � ����������
    ���� HWID.

    ����� ������ GetVersionExW ������� �������� �������� ����� ������. � �����������
    ������ � �� ���� ���������, �� �� ��������� ������� ��������� ��� SSD �������
    �� �������� ���� ��������� � ������. � ������� ����� �� ����� ����������� ���������
    ����� ����������, � ������ ����� ����� ������ ��� ����, ����� ����� �������
    GetVersionExW.
  *)

  H := GetModuleHandle('kernel32.dll');
  if H = 0 then
  begin
    (* kernel32.dll ���������� �� �������. ��� ������ � ������ �����������
       ��������, ��������� ��� ���������� ���� � ������ ��������. ������ �����
       �� ����� ���� � ������-�� ����������� ������ �� ������ �������. *)

    Exit(RF_ERROR_WINAPI_KERNEL_NOT_FOUND);
  end;

  P := GetProcAddress(H, 'GetVersionExW');
  if P = nil then
  begin
    (* GetVersionExW ������� �� �������. ���� ����� �������� ��������,
       �� ���������� ����������� ������� � ������� ����� kernel32.dll. *)

    Exit(RF_ERROR_WINAPI_GETVERSION_NOT_FOUND);
  end;

  @orgGetVersionExW := HookWinAPI(P, @GetVersionExW);

  if @orgGetVersionExW = nil then
  begin
    (* �� ������� ��������� �������� ������� GetVersionExW. ���������� ����������� -
       ����������� ������� ������� GetVersionExW � ������� HookWinAPI �������� ��������,
       ��������� �������, ����� ������ ���������� ������� ���� 'mov edi, edi'. *)

    Exit(RF_ERROR_WINAPI_NOT_HOOKED);
  end;

  Exit(RF_NO_ERROR);
end;

end.
