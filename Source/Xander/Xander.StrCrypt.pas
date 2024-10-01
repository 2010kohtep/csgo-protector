(*========= (C) Copyright 2017-2019, Alexander B. All rights reserved. ========*)
(*                                                                             *)
(*  Имя модуля:                                                                *)
(*   Xander.StrCrypt                                                           *)
(*                                                                             *)
(*  Описание:                                                                  *)
(*    Данный модуль предоставляет возможность расшифровки зашифрованных        *)
(*    специальным алгоритмом строк.                                            *)
(*=============================================================================*)

unit Xander.StrCrypt;

{$I Default.inc}

interface

uses
  System.Types;

function DecodeString(const Source: array of LongWord): {$IF SizeOf(Char) = 2} WideString {$ELSE} AnsiString {$ENDIF};

implementation

uses
{$IFDEF STRING_ENCRYPT_NEW}
  Xander.CRC,
{$ENDIF}
  Xander.Console;

function DecodeStringW(Source: PLongWord; Len: Integer): WideString; overload; forward;
function DecodeStringW(const Source: TLongWordDynArray): WideString; overload; forward;
function DecodeStringA(Source: PLongWord; Len: Integer): AnsiString; overload; forward;
function DecodeStringA(const Source: TLongWordDynArray): AnsiString; overload; forward;

function DecodeStringW(Source: PLongWord; Len: Integer): WideString;
begin
  Result := WideString(DecodeStringA(Source, Len));
end;

function DecodeStringW(const Source: TLongWordDynArray): WideString;
begin
  Result := DecodeStringW(@Source[0], Length(Source));
end;

function DecodeStringA(Source: PLongWord; Len: Integer): AnsiString;

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

{$IFDEF STRING_ENCRYPT_NEW}
var
  I: Integer;
  Key: LongWord;
  EC: LongWord;
begin
  if (Source = nil) or (Len = 0) then
    Exit('');

  Key := Source[0];

  SetLength(Result, Len - 1);

  for I := 1 to Len - 1 do
  begin
    EC := Source[I];
    EC := Swap32(EC);
    EC := EC xor CRC32CTable[I mod 256];
    EC := EC xor Key;
    EC := EC div 19960303;

    {$I Obfuscation-2.inc}

    Result[I] := AnsiChar(EC);
  end;

  {$I Obfuscation-1.inc}
end;
{$ELSE}
var
  L: Integer;
  EncryptedChar: Cardinal;
begin
  if Source = nil then
  begin
    Result := '';
    Exit;
  end;

  {$I Obfuscation-1.inc}

  SetLength(Result, Len);

  for L := 1 to Len do
  begin
    EncryptedChar := TLongWordDynArray(Source)[L - 1];
    EncryptedChar := Swap32(EncryptedChar);
    EncryptedChar := EncryptedChar xor $DEADC0DE;
    EncryptedChar := EncryptedChar div 19960303;

    {$I Obfuscation-2.inc}

    Result[L] := AnsiChar(EncryptedChar);
  end;
end;
{$ENDIF}

function DecodeStringA(const Source: TLongWordDynArray): AnsiString;
begin
  Result := DecodeStringA(@Source[0], Length(Source));
end;

function DecodeString(const Source: array of LongWord): {$IF SizeOf(Char) = 2} WideString {$ELSE} AnsiString {$ENDIF};
begin
  Result := {$IF SizeOf(Char) = 2} DecodeStringW {$ELSE} DecodeStringA {$ENDIF} (@Source[0], Length(Source));
end;

end.
