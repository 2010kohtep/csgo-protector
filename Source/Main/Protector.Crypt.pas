(*=========== (C) Copyright 2017, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Имя модуля:                                                                *)
(*   Protector.Crypt                                                           *)
(*                                                                             *)
(*  Описание:                                                                  *)
(*    Данный модуль предоставляет возможность расшифровки зашифрованных        *)
(*    специальным алгоритмом строк.                                            *)
(*=============================================================================*)

unit Protector.Crypt;

{$I Default.inc}

interface

uses
  System.Types;

function DecodeStringW(Source: PCardinal; Len: Integer): WideString; overload;
function DecodeStringW(Source: TCardinalDynArray): WideString; overload;
function DecodeStringA(Source: PCardinal; Len: Integer): AnsiString; overload;
function DecodeStringA(Source: TCardinalDynArray): AnsiString; overload;

implementation

function DecodeStringW(Source: PCardinal; Len: Integer): WideString;
begin
  Result := WideString(DecodeStringA(Source, Len));
end;

function DecodeStringW(Source: TCardinalDynArray): WideString;
begin
  Result := DecodeStringW(@Source[0], Length(Source));
end;

function DecodeStringA(Source: PCardinal; Len: Integer): AnsiString;

  function Swap32(Value: Cardinal): Cardinal;
  asm
    mov ecx, eax

    shl ecx, 24

    mov edx, eax
    and edx, $FF00
    shl edx, 8

    or ecx, edx

    mov edx, eax
    and edx, $FF0000
    shr edx, 8

    shr eax, 24

    or eax, ecx
    or eax, edx
  end;

type
  TDWordArray = array of Cardinal;
var
  L: Integer;
  EncryptedChar: Cardinal;
begin
  if Source = nil then
  begin
    Result := '';
    Exit;
  end;

  SetLength(Result, Len);

  for L := 1 to Len do
  begin
    EncryptedChar := TDWordArray(Source)[L - 1];
    EncryptedChar := Swap32(EncryptedChar);
    EncryptedChar := EncryptedChar xor $DEADC0DE;
    EncryptedChar := EncryptedChar div 19960303;

    Result[L] := AnsiChar(EncryptedChar);
  end;
end;

function DecodeStringA(Source: TCardinalDynArray): AnsiString;
begin
  Result := DecodeStringA(@Source[0], Length(Source));
end;

end.
