(*======== (C) Copyright 2017-2018, Alexander B. All rights reserved. =========*)
(*                                                                             *)
(* ��� ������:                                                                 *)
(*   Obfuscation-2.inc                                                         *)
(*                                                                             *)
(* ����������:                                                                 *)
(*   ��������� �������������� ����, ������������ ������ ��������� �����       *)
(*   IDA Pro.                                                                  *)
(*=============================================================================*)

{$IFDEF RELEASE}
asm
  test esp, esp
  jnz @A
    pop ebp
    ret
@A:
end;
{$ENDIF}