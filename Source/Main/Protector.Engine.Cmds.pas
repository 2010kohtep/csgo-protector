unit Protector.Engine.Cmds;

{$I Default.inc}

interface

uses
  System.SysUtils,
  System.Types,

  Winapi.Windows,
  Winapi.Messages,
  Winapi.WinSock,

  Protector.Global,

  SourceSDK,

  Xander.Memory,
  Xander.ThisWrap;

function FindConCmd(Name: PAnsiChar): Pointer;
function FindCmdCallback(Name: PAnsiChar): Pointer;
function FindCVarCallback(Name: PAnsiChar): Pointer;
function HookCVarCallback(Name: PAnsiChar; Callback: Pointer): Pointer;
function HookCmdCallback(Name: PAnsiChar; Callback: Pointer): Pointer;
procedure Cmd_AddCommand(Name: PAnsiChar; Callback: Pointer; Description: PAnsiChar = nil; Flags: LongWord = 0; Completion: Pointer = nil); stdcall;
procedure RegisterVariable(Name, Value: PAnsiChar; Flags: LongWord = 0; Desc: PAnsiChar = nil; Completion: Pointer = nil); stdcall;
function Cmd_FindVarValue(Name: PAnsiChar): PAnsiChar;
function Cmd_FindVarValueInt(Name: PAnsiChar): LongInt;
function Cmd_FindVarValueBool(Name: PAnsiChar): Boolean;

procedure Cmd_ParseLoadedVGui2Interfaces;
procedure Cmd_ParseLoadedEngineInterfaces;
procedure Cmd_Int3;
procedure Cmd_DumpCmds;
procedure Cmd_NameNew;

procedure RegisterCommands;

implementation

uses
  Protector.Common;

function FindConCmd(Name: PAnsiChar): Pointer;
asm
  mov ecx, [m_pConCommandList]
  test ecx, ecx
  jnz @A
    xor eax, eax
    ret
  
@A:
  push edi
  push esi
  mov esi, [ecx] // cmd list
  mov edi, eax // cmd that we need to find
  jmp @InitCycle
@Loop:
  mov esi, [esi + 4] // go to next cmd
  test esi, esi // end of the list
  jz @NotFound
 
@InitCycle:
   mov eax, [esi + 12]
   mov edx, edi
   call StrComp
   test eax, eax
    jz @Found
  jmp @Loop

@NotFound:
  xor eax, eax
  pop esi
  pop edi
  ret

@Found:
  mov eax, esi
  pop esi
  pop edi
end;

function FindCmdCallback(Name: PAnsiChar): Pointer;
asm
  call FindConCmd
  test eax, eax
   jz @Exit

  mov eax, [eax + 24]
  
@Exit:
end;

function FindCVarCallback(Name: PAnsiChar): Pointer;
asm
  call FindConCmd
  test eax, eax
   jz @Exit

  cmp [eax + 64], 0 // new patches check
  jnz @A
   add eax, 4
@A:
  mov eax, [eax + 64]

@Exit:
end;

function HookCVarCallback(Name: PAnsiChar; Callback: Pointer): Pointer;
asm
  push edx
  
  call FindConCmd
  test eax, eax
   jz @Exit

  cmp [eax + 64], 0 // new patches check
  jnz @A
   add eax, 4
@A:
  xchg eax, edx
  mov eax, [edx + 64]
  pop [edx + 64]
  ret

@Exit:
  pop edx
end;

function HookCmdCallback(Name: PAnsiChar; Callback: Pointer): Pointer;
asm
  push edx

  call FindConCmd
  test eax, eax
   jz @Exit

  xchg eax, edx
  mov eax, [edx + 24]
  pop [edx + 24]
  ret
  
@Exit:
  pop edx
end;

procedure Cmd_AddCommand(Name: PAnsiChar; Callback: Pointer; Description: PAnsiChar = nil; Flags: LongWord = 0; Completion: Pointer = nil); stdcall;
{$IFDEF PUREASM}
asm
  mov ebp, [CCPseudoInterface]
  test ebp, ebp
  jz @A
    push 36
    call GetMemory
    pop edx

    xchg eax, ebp
    pop ebp
    jmp eax
@A:
end;
{$ELSE}
begin
  ThisCall(GetMemory(36), @CCPseudoInterface, Name, Callback, Description, Flags, Completion);
end;
{$ENDIF}

procedure RegisterVariable(Name, Value: PAnsiChar; Flags: LongWord = 0; Desc: PAnsiChar = nil; Completion: Pointer = nil); stdcall;
{$IFDEF PUREASM}
asm
  mov ebp, [CVarPseudoInterface]
  test ebp, ebp
  jz @A
    push 68
    call GetMemory
    pop edx

    xchg eax, ebp
    pop ebp
    jmp eax
@A:
end;
{$ELSE}
begin
  if @CVarPseudoInterface <> nil then
    ThisCall(GetMemory(68), @CVarPseudoInterface, Name, Value, Flags, Desc, Completion);
end;
{$ENDIF}

// use TLongWordDynArray(FindConCmd('cmdname'))[8/9] for avoid native search via Cmd_FindVarValue
function Cmd_FindVarValue(Name: PAnsiChar): PAnsiChar;
{$IFDEF PUREASM}
asm
  mov ecx, [CVEngineCvar003]
  test ecx, ecx
  jz @A
   push eax
   mov eax, [ecx].ICvar003.Table
   call [eax].ICvar003Table.FindVar
   test eax, eax // FindVar can return nil
   jz @C
   mov eax, [eax + 32]
   ret
@A:
  mov ecx, [CVEngineCvar004]
  test ecx, ecx
  jz @B
   push eax
   mov eax, [ecx].ICvar004.Table
   call [eax].ICvar004Table.FindVar
   test eax, eax
   jz @C
   mov eax, [eax + 36]
   ret
@B:
  xor eax, eax
@C:
end;
{$ELSE}
var
  P: Pointer;
begin
  Result := nil;

  if CVEngineCvar003 <> nil then
  begin
    P := CVEngineCvar003.Table.FindVar(Name);
    if P <> nil then
      Result := PPointer(@TLongWordDynArray(P)[8])^;
  end
  else
  if CVEngineCvar004 <> nil then
  begin
    P := CVEngineCvar004.Table.FindVar(Name);
    if P <> nil then
      Result := PPointer(@TLongWordDynArray(P)[9])^;
  end;
end;
{$ENDIF}

function Cmd_FindVarValueInt(Name: PAnsiChar): LongInt;
{$IFDEF PUREASM}
asm
  call Cmd_FindVarValue
  test eax, eax
   jz @Exit

  push esp
  lea edx, [esp]
  call TryStrToInt

  test al, al
   jz @Exit
  pop eax
  ret
@Exit:
  or eax, -1
end;
{$ELSE}
var
  P: PAnsiChar;
begin
  P := Cmd_FindVarValue(Name);
  if (P = nil) or (not TryStrToInt(string(P), Result)) then
    Result := -1;
end;
{$ENDIF}

function Cmd_FindVarValueBool(Name: PAnsiChar): Boolean;
{$IFDEF PUREASM}
asm
  call Cmd_FindVarValue
  test eax, eax
   jz @Exit

  push esp
  lea edx, [esp]
  call TryStrToBool

  test al, al
   jz @Exit
  pop eax
@Exit:
end;
{$ELSE}
var
  P: PAnsiChar;
begin
  P := Cmd_FindVarValue(Name);
  if (P = nil) or (not TryStrToBool(string(P), Result)) then
    Result := False;
end;
{$ENDIF}

// Cmds

procedure Cmd_ParseLoadedVGui2Interfaces;
type
  PInterfaceInfo = ^TInterfaceInfo;
  TInterfaceInfo = record
    CallInterface: function(Name: PAnsiChar): Pointer; cdecl;
    Name: PAnsiChar;
    Next: PInterfaceInfo;
  end;
var
  CurInterface: PInterfaceInfo;
  Func: Pointer;
begin
  Func := GetProcAddress(GetModuleHandle('vgui2.dll'), 'CreateInterface');
  if Func = nil then
    Exit;

  CurInterface := Pointer(LongWord(Func) + 4);
  if PByte(CurInterface)^ = $E9 then
  begin
    Inc(LongWord(CurInterface));
    CurInterface := Pointer(LongWord(CurInterface) + LongWord(Pointer(CurInterface)^) + 10);
  end
  else
    Inc(LongWord(CurInterface), 1);

  CurInterface := PPointer(PPointer(CurInterface)^)^;
  while CurInterface <> nil do
  begin
    Msg('%s'#10, CurInterface.Name);
    CurInterface := CurInterface.Next;
  end;
end;

procedure Cmd_ParseLoadedEngineInterfaces;
type
  PInterfaceInfo = ^TInterfaceInfo;
  TInterfaceInfo = record
    CallInterface: function(Name: PAnsiChar): Pointer; cdecl;
    Name: PAnsiChar;
    Next: PInterfaceInfo;
  end;
var
  CurInterface: PInterfaceInfo;
begin
  CurInterface := Pointer(LongWord(@CreateInterfaceE) + 4);
  if PByte(CurInterface)^ = $E9 then
  begin
    Inc(LongWord(CurInterface));
    CurInterface := Pointer(LongWord(CurInterface) + LongWord(Pointer(CurInterface)^) + 10);
  end
  else
    Inc(LongWord(CurInterface), 1);

  CurInterface := PPointer(PPointer(CurInterface)^)^;
  while CurInterface <> nil do
  begin
    Msg('%s'#10, CurInterface.Name);
    CurInterface := CurInterface.Next;
  end;
end;

procedure Cmd_Int3;
asm
  int 3
end;

procedure Cmd_DumpCmds;
const
  Str: PAnsiChar = '%s'#10;
asm
  push ebx

  mov ebx, [m_pConCommandList]
  mov ebx, [ebx]

@A:
  mov ebx, [ebx + 4]
  test ebx, ebx
  jz @B

   push [ebx + 12]
   push Str
   call [Msg]
   add esp, 8
 jmp @A

@B:
 pop ebx
end;

procedure Cmd_NameNew;
asm
 push edi
 push esi

 mov eax, ebx
 call StrLen
 mov ecx, eax
 mov esi, ebx
 mov edi, [SteamclientName]

 // part of args of next call instruction
 push IniFileName
 push edi

 // cld
 rep movsb
 mov byte [edi], 0

 push IniKeyName
 push IniSectionName
 call WritePrivateProfileStringA

 pop esi
 pop edi

 jmp [Cmd_Name]
end;

procedure Cmd_Test;
type
  TPointerDynArray = array of Pointer;
begin
  GameUI011 := PPointer(PPointer($201A86DD)^)^;
  ThisCall(GameUI011, TPointerDynArray(GameUI011.VTable)[10], 1, 'Hm', 'sas');
end;

procedure RegisterCommands;
begin

end;

end.

