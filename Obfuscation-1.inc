(*======== (C) Copyright 2017-2018, Alexander B. All rights reserved. =========*)
(*                                                                             *)
(* Имя модуля:                                                                 *)
(*   Obfuscation-1.inc                                                         *)
(*                                                                             *)
(* Назначение:                                                                 *)
(*   Реализует обфускационный приём, затрудняющий анализ программы через       *)
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