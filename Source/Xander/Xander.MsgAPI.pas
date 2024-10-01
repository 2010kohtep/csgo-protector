unit Xander.MsgAPI;

{$I Default.inc}

interface

uses
  System.SysUtils,
  Winapi.Windows,
  Protector.Global;

procedure Info(const Msg: PAnsiChar);
procedure Alert(const Msg: PAnsiChar);
procedure Error(const Msg: PAnsiChar; Terminate: Boolean = True);
procedure ShowPointer(Ptr: Pointer);

implementation

uses
  Protector.Common, Protector.Engine.Cmds;

procedure Info(const Msg: PAnsiChar);
const
  INFO_HEADER: PAnsiChar = 'Info';
{$IFDEF PUREASM}
asm
  push MB_ICONINFORMATION or MB_SYSTEMMODAL
  push INFO_HEADER
  push eax
  push HWND_DESKTOP
  call MessageBox
end;
{$ELSE}
begin
  MessageBoxA(HWND_DESKTOP, Msg, INFO_HEADER, MB_ICONINFORMATION or MB_SYSTEMMODAL);
end;
{$ENDIF}

procedure Alert(const Msg: PAnsiChar);
const
  ALERT_HEADER: PAnsiChar = 'Alert';
{$IFDEF PUREASM}
asm
  push MB_ICONWARNING or MB_SYSTEMMODAL
  push ALERT_HEADER
  push eax
  push HWND_DESKTOP
  call MessageBox
end;
{$ELSE}
begin
  MessageBoxA(HWND_DESKTOP, Msg, ALERT_HEADER, MB_ICONWARNING or MB_SYSTEMMODAL);
end;
{$ENDIF}

procedure Error(const Msg: PAnsiChar; Terminate: Boolean = True);
const
  ERROR_HEADER: PAnsiChar = 'Error';
{$IFDEF PUREASM}
asm
  push ebx
  mov bl, dl

  push MB_ICONERROR or MB_SYSTEMMODAL
  push ERROR_HEADER
  push eax
  push HWND_DESKTOP
  call MessageBox

  dec bl
  jnz @Cont // continue program execution
   jmp System.@Halt0
@Cont:
  pop ebx
end;
{$ELSE}
begin
  MessageBoxA(HWND_DESKTOP, Msg, ERROR_HEADER, MB_ICONERROR or MB_SYSTEMMODAL);
  TerminateProcess(DWORD(-1), 0);
end;
{$ENDIF}

procedure ShowPointer(Ptr: Pointer);
{$IFDEF PUREASM}
asm
  push 0 // alloc IntToHex string pointer place
  mov edx, 8
  lea ecx, [esp]
  call IntToHex

  mov eax, [eax]
  call Info

  pop eax
  call System.@LStrClr
end;
{$ELSE}
begin
  MessageBox(HWND_DESKTOP, PChar(IntToHex(LongWord(Ptr), 8)), 'Info', MB_ICONINFORMATION or MB_SYSTEMMODAL);
end;
{$ENDIF}

end.

