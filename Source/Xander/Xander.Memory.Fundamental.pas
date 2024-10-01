unit Xander.Memory.Fundamental;

{$I Default.inc}

interface

uses
  System.SysUtils;

type
  TSearcher = class
    class function Find<T>(SearchStart, SearchEnd: Pointer; Pattern: T; Offset: Integer): Pointer; static;
    class function FindReference(SearchStart, SearchEnd: Pointer; Reference: Pointer): Pointer; static;
  end;

implementation

{ TSearcher }

class function TSearcher.Find<T>(SearchStart, SearchEnd: Pointer; Pattern: T; Offset: Integer): Pointer;
type
  PT = ^T;
var
  P: Pointer;
begin
  P := SearchStart;

  case SizeOf(T) of
    1, 2, 4, 8, 10:
    begin
      SearchEnd := Pointer(Integer(SearchEnd) - SizeOf(T));

      while Cardinal(P) < Cardinal(SearchEnd) do
      begin
        if CompareMem(P, PByte(@Pattern), SizeOf(Pattern)) then
        begin
          Exit(Pointer(Integer(P) + Offset));
        end;

        P := Pointer(Integer(P) + 1);
      end;
    end;

    else
    begin
      raise Exception.Create('TSearcher.Find<T>: Invalid pattern size.');
    end;
  end;

  Exit(nil);
end;

class function TSearcher.FindReference(SearchStart, SearchEnd,
  Reference: Pointer): Pointer;
begin
  if Cardinal(SearchEnd) < Cardinal(SearchStart) then
    Exit(nil);

  SearchEnd := Pointer(Cardinal(SearchEnd) - 5);

  while Cardinal(SearchStart) < Cardinal(SearchEnd) do
  begin
    if PPointer(SearchStart)^ = Reference then
      Exit(SearchStart);

    SearchStart := Pointer(Cardinal(SearchStart) + 1);
  end;

  Exit(nil);
end;

end.
