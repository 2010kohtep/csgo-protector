unit Protector.Exception;

interface

uses
  Winapi.Windows,

  System.SysUtils,
  System.JSON,

  Xander.Exception;

procedure Init;

implementation

function OnVEH(Module: THandle; const Name: string; const ExceptionInfo: TExceptionPointers): Integer; cdecl;
begin
  if SameText(ExtractFileExt(Name), '.dat') then
    Exit(EXCEPTION_CONTINUE_SEARCH);

  if SameText(Name, 'kernel32.dll') or
     SameText(Name, 'winhttp.dll') or
     SameText(Name, 'tier0.dll') then
  begin
    Exit(EXCEPTION_CONTINUE_SEARCH);
  end;

{$IFDEF DEBUG}
  MessageBox(HWND_DESKTOP, 'OnVEH Called', '', MB_ICONWARNING or MB_SYSTEMMODAL);
{$ENDIF}

  (* Отправить информацию об исключении на сервер и создать дамп файл исключения
   * в папке с игрой. *)
  TExceptionBuster.HandleException(ExceptionInfo);

  (* Отобразить стандартное сообщение с ошибкой. *)
  TExceptionBuster.RaiseError(False);

  Result := EXCEPTION_CONTINUE_SEARCH;
end;

function OnVEHPrepare(const ExceptionInfo: TExceptionPointers): Boolean; cdecl;
begin
  Exit(True);
end;

procedure OnDumpBegin(Dump: TJSONObject); cdecl;
begin

end;

procedure OnDumpEnd(Dump: TJSONObject); cdecl;
begin

end;

procedure OnRaiseError; cdecl;
begin

end;

procedure Init;
begin
  CreateExceptionHandler;

  SetOnVEH(OnVEH);
  SetOnVEHPrepare(OnVEHPrepare);
  SetOnDumpBegin(OnDumpBegin);
  SetOnDumpEnd(OnDumpEnd);
  SetOnRaiseError(OnRaiseError);
end;

end.
