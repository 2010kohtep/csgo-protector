unit Protector.Birzyk.ServerBrowser;

{$I Default.inc}

interface

uses
  Winapi.Windows, System.SysUtils, Protector.Global, Xander.Memory, Xander.Console,
  Protector.Common, Xander.ClassInformer;

procedure Hook_CDialogGameInfo_ServerResponded;
procedure Hook_CDialogGameInfo_ServerFailedToRespond;

implementation

{$REGION 'Исправление вылета CDialogGameInfo::ServerResponded'}

var
  orgCDialogGameInfo_ServerResponded: procedure(_EAX, _EDX: Integer; This: Pointer; Server: Pointer); register;
  gateCDialogGameInfo_ServerResponded: procedure(_EAX, _EDX: Integer; This: Pointer; Server: Pointer); register;

procedure hkCDialogGameInfo_ServerResponded(_EAX, _EDX: Integer; This: Pointer; Server: Pointer); register;
var
  Addr: Pointer;
  Table: Integer;
begin
  Addr := Transpose(This, $48);
  Addr := PPointer(Addr)^;
  Addr := PPointer(Addr)^;

  //WriteLn('hkCDialogGameInfo_ServerResponded - ', IntToHex(Integer(Server), 8));

  if not IsValidMemory(Server) then
  begin
{$IFDEF DEBUG}
    WriteLn('CDialogGameInfo::ServerResponded: Incorrect ''server'' variable address, exiting...');
{$ENDIF}

    Exit;
  end;

  //WriteLn('CDialogGameInfo::ServerResponded called, [[ecx+48]] = ', IntToHex(Integer(Addr), 8));

  //
  // Проверка половины адреса виртуальной таблицы this переменной. Если эта таблица
  // не класса vgui2::ToggleButton, то выйти из функции.
  //

  Table := Cardinal(Addr) and $0000FF00;

  if Table <> $4100 then
  begin
{$IFDEF DEBUG}
    TConsole.Error('CDialogGameInfo::ServerResponded: Incorrect virtual table in object (%.8X), exiting...)', [Integer(Addr)]);
{$ENDIF}

    Exit;
  end;

  orgCDialogGameInfo_ServerResponded(_EAX, _EDX, This, Server);
end;

procedure Hook_CDialogGameInfo_ServerResponded;
var
  Addr: Pointer;
begin
  Addr := GetVTableForClass(SBBase, Transpose(SBBase, SBSize - 1), 'CDialogGameInfo', $21C);

  if Addr = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CDialogGameInfo::ServerResponded');
  {$ENDIF}

    Exit;
  end;

  @orgCDialogGameInfo_ServerResponded := PPointer(Addr)^;
  @gateCDialogGameInfo_ServerResponded := HookRegular(@orgCDialogGameInfo_ServerResponded, @hkCDialogGameInfo_ServerResponded);
end;

{$ENDREGION}

{$REGION 'Исправление вылета CDialogGameInfo::ServerFailedToRespond'}

var
  orgCDialogGameInfo_ServerFailedToRespond: procedure(_EAX, _EDX: Integer; This: Pointer); register;
  gateCDialogGameInfo_ServerFailedToRespond: procedure(_EAX, _EDX: Integer; This: Pointer); register;

procedure hkCDialogGameInfo_ServerFailedToRespond(_EAX, _EDX: Integer; This: Pointer); register;
var
  Addr: Pointer;
  Table: Cardinal;
begin
  Addr := Transpose(This, -$21C);
  Addr := PPointer(Addr)^;
  //Addr := PPointer(Addr)^;

  if not IsValidMemory(Addr) then
  begin
{$IFDEF DEBUG}
    WriteLn('CDialogGameInfo::ServerFailedToRespond: Incorrect ''Addr'' variable address, exiting...');
{$ENDIF}

    Exit;
  end;

  Table := Cardinal(Addr) and $0000FFFF;
  if (Table <> $AE30) and (Table <> $AE60) and (Table <> $2D00) then
  begin
{$IFDEF DEBUG}
    TConsole.Error('CDialogGameInfo::ServerFailedToRespond: Incorrect virtual table in object (%.8X), exiting...)', [Integer(Addr)]);
{$ENDIF}

    Exit;
  end;

{$IFDEF DEBUG}
  //WriteLn('CDialogGameInfo::ServerFailedToRespond called, [ecx-21C] = ', IntToHex(Integer(Addr) - GetAddressBase(Addr), 8));
{$ENDIF}

  gateCDialogGameInfo_ServerFailedToRespond(0, 0, This);
end;

procedure Hook_CDialogGameInfo_ServerFailedToRespond;
var
  Addr: Pointer;
begin
  Addr := GetVTableForClass(SBBase, Transpose(SBBase, SBSize - 1), 'CDialogGameInfo', $21C);

  if Addr = nil then
  begin
  {$IFDEF DEBUG}
    TConsole.Error('Failed to hook CDialogGameInfo::ServerFailedToRespond');
  {$ENDIF}

    Exit;
  end;

  Addr := Transpose(Addr, 4);

  @orgCDialogGameInfo_ServerFailedToRespond := PPointer(Addr)^;
  @gateCDialogGameInfo_ServerFailedToRespond := HookRegular(@orgCDialogGameInfo_ServerFailedToRespond, @hkCDialogGameInfo_ServerFailedToRespond);
end;

{$ENDREGION}

end.
