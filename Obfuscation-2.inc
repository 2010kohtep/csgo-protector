(*======== (C) Copyright 2017-2018, Alexander B. All rights reserved. =========*)
(*                                                                             *)
(* Имя модуля:                                                                 *)
(*   Obfuscation-2.inc                                                         *)
(*                                                                             *)
(* Назначение:                                                                 *)
(*   Реализует обфускационный приём, затрудняющий анализ программы через       *)
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