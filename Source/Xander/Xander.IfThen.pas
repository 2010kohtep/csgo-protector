unit Xander.IfThen;

{$I Default.inc}

interface

function IfThen(AValue: Boolean; const ATrue, AFalse: string): string; inline; overload;
function IfThen(AValue: Boolean; const ATrue, AFalse: Integer): Integer; inline; overload;

implementation

function IfThen(AValue: Boolean; const ATrue, AFalse: string): string;
begin
  if AValue then
    Exit(ATrue)
  else
    Exit(AFalse);
end;

function IfThen(AValue: Boolean; const ATrue, AFalse: Integer): Integer;
begin
  if AValue then
    Exit(ATrue)
  else
    Exit(AFalse);
end;

end.
