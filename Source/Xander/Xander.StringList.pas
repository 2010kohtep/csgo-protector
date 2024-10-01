(*=========== (C) Copyright 2017, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(* Имя модуля:                                                                 *)
(*   Xander.StringList                                                         *)
(*                                                                             *)
(* Назначение:                                                                 *)
(*   Реализация собственного аналога класса TStringList.                       *)
(*=============================================================================*)

unit Xander.StringList;

{$I Default.inc}

interface

uses
  System.SysUtils;

type
  TXStringList = object
  strict private
    FData: array of string;
    FLineBreak: string;

    function GetCount: Integer;
    procedure SetTextStr(const Value: string);
    function GetTextStr: string;

    function GetItem(Index: Integer): string;
    procedure WriteItem(Index: Integer; const Value: string);
  public
    property Items[Index: Integer]: string read GetItem write WriteItem; default;

    property Count: Integer read GetCount;
    property Text: string read GetTextStr write SetTextStr;

    procedure Create;
    procedure Free;

    function Add(const S: string): Integer;
    procedure Append(const S: string);
    procedure Clear;

    procedure SaveToFile(const FileName: string);
  end;

implementation

{ TXStringList }

function TXStringList.Add(const S: string): Integer;
var
  I: Integer absolute Result;
begin
  I := Length(FData);

  SetLength(FData, Succ(I));
  FData[I] := S;
end;

procedure TXStringList.Append(const S: string);
var
  I: Integer;
begin
  I := Length(FData);

  SetLength(FData, Succ(I));
  FData[I] := S;
end;

procedure TXStringList.Clear;
begin
  SetLength(FData, 0);
end;

procedure TXStringList.Create;
begin
  SetLength(FData, 0);
  FLineBreak := sLineBreak;
end;

procedure TXStringList.Free;
begin
  SetLength(FData, 0);
end;

function TXStringList.GetCount: Integer;
begin
  Result := Length(FData);
end;

function TXStringList.GetItem(Index: Integer): string;
begin
  if Index > Length(FData) then
    raise Exception.Create('TXStringList.GetItem: Index is out of bounds.');

  Result := FData[Index];
end;

function TXStringList.GetTextStr: string;
var
  I, L, Size, C: Integer;
  P: PChar;
  S, LB: string;
begin
  C := GetCount;
  Size := 0;
  LB := FLineBreak;
  for I := 0 to C - 1 do Inc(Size, Length(GetItem(I)) + Length(LB));
  SetString(Result, nil, Size);
  P := Pointer(Result);
  for I := 0 to C - 1 do
  begin
    S := GetItem(I);
    L := Length(S);
    if L <> 0 then
    begin
      System.Move(Pointer(S)^, P^, L * SizeOf(Char));
      Inc(P, L);
    end;
    L := Length(LB);
    if L <> 0 then
    begin
      System.Move(Pointer(LB)^, P^, L * SizeOf(Char));
      Inc(P, L);
    end;
  end;
end;

procedure TXStringList.SaveToFile(const FileName: string);
var
  F: TextFile;
begin
  if FileExists(FileName) then
    DeleteFile(FileName);

  AssignFile(F, FileName);
  ReWrite(F);
  Write(F, Text);
  CloseFile(F);
end;

procedure TXStringList.SetTextStr(const Value: string);
var
  P, Start, LB: PChar;
  S: string;
  LineBreakLen: Integer;
begin
  Clear;

  P := Pointer(Value);

  if P <> nil then
  begin
    if FLineBreak = '' then
      raise Exception.Create('TXStringList.SetTextStr: Incorrect FLineBreak value.')
    else
    if FLineBreak = sLineBreak then
    begin
      while P^ <> #0 do
      begin
        Start := P;
        while not (AnsiChar(P^) in [#0, #10, #13]) do Inc(P);
        SetString(S, Start, P - Start);
        Add(S);
        if P^ = #13 then Inc(P);
        if P^ = #10 then Inc(P);
      end;
    end
    else
    begin
      LineBreakLen := Length(FLineBreak);
      while P^ <> #0 do
      begin
        Start := P;
        LB := AnsiStrPos(P, PChar(FLineBreak));
        while (P^ <> #0) and (P <> LB) do Inc(P);
        SetString(S, Start, P - Start);
        Add(S);
        if P = LB then
          Inc(P, LineBreakLen);
      end;
    end;
  end;
end;

procedure TXStringList.WriteItem(Index: Integer; const Value: string);
begin
  if Index > Length(FData) then
    raise Exception.Create('TXStringList.WriteItem: Index is out of bounds.');

  FData[Index] := Value;
end;

end.

