(*======== (C) Copyright 2017-2018, Alexander B. All rights reserved. =========*)
(*                                                                             *)
(* ��� ������:                                                                 *)
(*   Obfuscation-1.inc                                                         *)
(*                                                                             *)
(* ����������:                                                                 *)
(*   ��������� �������������� ����, ������������ ������ ��������� �����       *)
(*   IDA Pro.                                                                  *)
(*=============================================================================*)

{$IFDEF RELEASE}
asm
  test esp, esp
  jnz @A
    mov eax, esp
    mov esp, $10001888
    sub esp, $11993000
    mov esp, eax
@A:
end;
{$ENDIF}