(*=========== (C) Copyright 2019, Alexander B. All rights reserved. ===========*)
(*                                                                             *)
(*  Имя модуля:                                                                *)
(*   Xander.RevFix                                                             *)
(*                                                                             *)
(*  Описание:                                                                  *)
(*    Универсальный модуль, исправляющий проблемы эмулятора RevEmu и           *)
(*    описывающий шаги исправления, чтобы в будущем не запутаться.             *)
(*=============================================================================*)

unit Xander.RevFix;

{$I Default.inc}

interface

uses
  System.SysUtils, System.Types, Winapi.Windows, Xander.Memory;

(* Функция инициализации модуля. Должна быть вызвана в главном потоке во время
   старта программы. Возвращает RF-коды. *)
function Init: Integer;

(* Ошибки, возможные при выполнении исправления. *)
const
  RF_NO_ERROR = 0;                           (* Нет ошибок. *)
  RF_ERROR_STEAMCLIENT_NOT_FOUND = -1;       (* Не удалось найти эмулятор. *)
  RF_ERROR_HWID_NOT_FOUND = -2;              (* Не удалось найти указатель на HWID хранилище. *)
  RF_ERROR_VOLUME_RETRIEVE_FAILED = -3;      (* Не удалось получить метку системного тома. *)
  RF_ERROR_WINAPI_NOT_HOOKED = -4;           (* Функция GetVersionExW не была перехвачена. *)
  RF_ERROR_WINAPI_KERNEL_NOT_FOUND = -5;     (* kernel32 библиотека не была найдена. *)
  RF_ERROR_WINAPI_GETVERSION_NOT_FOUND = -6; (* Функция GetVersionExW не найдена. *)

type
  TRFOnError = procedure(Code: Integer); cdecl;
  TRFOnBegin = function: Boolean; cdecl;

var
  (* Функция, вызывающаяся, если не удалось установить HWID. Аргумент Code
     содержит RF-код ошибки. *)
  RFOnError: TRFOnError = nil;
  (* Функция, вызывающаяся, когда процесс установки HWID начинается. Возвращает
     True, если исправление нужно продолжить, и False, если прервать. *)
  RFOnBegin: TRFOnBegin = nil;

(* Функция установки события, которое произойдёт при ошибке установки HWID.
   Возвращает предыдущий обработчик или nil, если аргумент Func равняется nil. *)
function SetOnError(Func: TRFOnError): TRFOnError;
(* Функция установки события, которое произойдёт при старте установки HWID.
   Возвращает предыдущий обработчик или nil, если аргумент Func равняется nil. *)
function SetOnBegin(Func: TRFOnBegin): TRFOnBegin;

implementation

var
  (* steamclient.dll база и её размер. Обычно подобные переменные я храню
     в Global.pas файле, но чтобы сделать модуль более кросспроектным, я перемещу
     их сюда. *)
  SCBase: Pointer;
  SCSize: Cardinal;

var
  (* Хранилище HDD/SSD ключа (HWID). Любая записанная сюда информация до вызова
     перехваченной GetVersionExW функции будет преобразована в SteamID. *)
  HardwareID: PAnsiChar;

function GetModuleNameFromAddr(Addr: Pointer): string;
var
  Module: HMODULE;
begin
  Module := GetAddressBase(Addr);
  Result := GetModuleName(Module);
  Result := ExtractFileName(Result);
  Result := ChangeFileExt(Result, '');
  Result := LowerCase(Result);
end;

type
  TGetVersionExW = function(var lpVersionInformation: TOSVersionInfoW): BOOL; stdcall;

var
  (* Функция-трамплин, вызывающая оригинальную GetVersionExW. Перед вызовом функция
     также выполняет байты, которые были 'украдены' и заменены прыжком. *)
  orgGetVersionExW: TGetVersionExW;

function PerformEmulatorModification: Integer;
var
  VolumeId: Cardinal;
begin
  (* Получаем указатели на базу эмулятора, а также её размер. *)
  SCBase := Ptr(GetModuleHandle('steamclient.dll'));

  if SCBase = nil then
  begin
    (* Не удалось получить базу эмулятора. Скорее всего инициализация выполнена
       неправильно (рано/не в том месте), либо эмулятор скрыт. *)

    Exit(RF_ERROR_STEAMCLIENT_NOT_FOUND);
  end;

  SCSize := GetModuleSize(Cardinal(SCBase));

  (* Получаем указатель на переменную, хранящую HWID. *)
  HardwareID := FindPushString(SCBase, SCSize, PAnsiChar('%32.32s'));
  if HardwareID = nil then
  begin
    (* Строка правил форматирования ключа не найдена. Вероятность этого низка,
       но лучше перестраховаться и сделать обработчик этой ситуации. *)

    Exit(RF_ERROR_HWID_NOT_FOUND);
  end;

  HardwareID := Transpose(HardwareID, -4);
  HardwareID := PPointer(HardwareID)^;

  if not IsValidMemory(HardwareID) then
  begin
    (* Разыменование привело к указателю на некорректную память. *)

    Exit(RF_ERROR_HWID_NOT_FOUND);
  end;

  (* Получить метку тома системного диска. Метод работает на любой операцинной
     системе и не вызывает проблем, присущие методу эмулятора. *)
  if not GetVolumeInformation('C:\', nil, 0, @VolumeId, PCardinal(nil)^, PCardinal(nil)^, nil, 0) then
  begin
    (* Что-то пошло не так. *)

    Exit(RF_ERROR_VOLUME_RETRIEVE_FAILED);
  end;

  (* Записать полученную метку в хранилище HWID. *)
  StrCopy(HardwareID, PAnsiChar(AnsiString(IntToStr(VolumeId))));

  Exit(RF_NO_ERROR);
end;

function GetVersionExW(var lpVersionInformation: TOSVersionInfoW): BOOL; stdcall;
var
  RetAddr: Pointer;
  Name: string;

  P: Pointer;
  Jump: Cardinal;

  Code: Integer;
begin
  (* Получить адрес возврата из функции. Нужно, чтобы определить место вызова. *)
  RetAddr := ReturnAddress;

  (* Получить имя модуля, который вызвал функцию. *)
  Name := GetModuleNameFromAddr(RetAddr);

  (* Проверить, произошел ли вызов из функция эмулятора, получающий HWID. *)
  if CheckWord(RetAddr, $D6FF, -2) and (CheckByte(RetAddr, $85) or CheckByte(RetAddr, $3B)) and SameStr(Name, 'steamclient') then
  begin
    if @RFOnBegin <> nil then
    begin
      (* Событие OnBegin вернуло False, исправление не требуется. *)
      if not RFOnBegin then
      begin
        Result := orgGetVersionExW(lpVersionInformation);
        Exit;
      end;
    end;

    (* Ищем место, которое проверяет работу некоторой функции. Место, которое
       её вызывает, проверяет её результат и если он равняется 0, то вызывающая
       функция завершает работу, возвращая 0. Нас почти всё устраивает, поэтому
       вместо 'test eax, eax' проверки мы записываем 'xor eax, eax', который
       установит флаг ZF в 1, что заставит выполнить переход в конец функции,
       чтобы восстановить регистры и стек и завершить функцию. *)
    P := FindWordPtr(RetAddr, 64, $840F, -2);
    P := WriteWord(P, $C031); // xor eax, eax

    (* Заблокировать вызов кое-какой другой функции, на всякий случай *)
    WriteNOPs(Transpose(P, -7), 5);

    (* Чтобы быстро определить место, куда будет совершен прыжок, мы получаем
       смещение из jz опкода, который его выполняет. С его помощью мы сделаем
       безопасный и быстрый переход к этому участку. Мы также сохраним это значение на
       будущее. *)
    Jump := PCardinal(Transpose(P, 2))^;

    (* Так как функция возвращает 0, то SteamID не будет сгенерирован, так как
       эмулятор будет считать, что функция завершилась с ошибкой. Возвращение
       0 происходит благодаря 'xor eax, eax', который выполняется сразу после
       того самого прыжка. Мы заменим эту инструкцию на 'mov al, 1', что заставит
       функцию говорить эмулятору, что всё в порядке, ключ получен, можно продолжать
       генерацию. *)
    P := Transpose(P, 6);
    P := Transpose(P, Jump);
    WriteWord(P, $01B0);

    (* Теперь мы можем установить своё значение HWID. *)
    Code := PerformEmulatorModification;

    if Code <> RF_NO_ERROR then
    begin
      (* Не удалось установить значение. Так как мы не можем предугадать, когда
         будет вызвана наша GetVersionExW функция, мы должны сделать событие, которое
         вызовет наш обработчик, который обработает возникшую ошибку, или просто
         уведомит пользователя о проблеме. *)

      if @RFOnError <> nil then
        RFOnError(Code);
    end;
  end;

  Result := orgGetVersionExW(lpVersionInformation);
end;

function SetOnError(Func: TRFOnError): TRFOnError;
begin
  if @Func = nil then
    Exit(nil);

  Result := @RFOnError;
  @RFOnError := @Func;
end;

function SetOnBegin(Func: TRFOnBegin): TRFOnBegin;
begin
  if @Func = nil then
    Exit(nil);

  Result := @RFOnBegin;
  @RFOnBegin := @Func;
end;


function Init: Integer;
var
  H: HMODULE;
  P: Pointer;
begin
  (*
    Здесь начинается самое интересное.

    Функция эмулятора, которая получает хардвар ключ, в самом начале своей работы
    вызывает функцию GetVersionExW. Зачем это сделано я до конца не понимаю,
    поскольку полученные данные нигде не используются, если верить IDA Pro,
    однако это поможет нам создать обработчик события, когда мы можем записать
    свой HWID. Мы могли бы ждать подгрузки и инициализации steamclient.dll в
    отдельном потоке, но это способно породить состояние гонки, что приведет к тому,
    что в некоторых случаях поток не будет успевать выполнять патч, и эмулятор
    будет выполнять инициализацию первым. Это случалось крайне редко (я бы даже
    сказал никогда), но в последнее время я стал замечать симптомы такого состояния
    и чтобы перестраховаться изменил работу патчера. Именно поэтому важно вызывать функцию
    инициализации собственного модуля в главном потоке при загрузке библиотеки,
    когда мы точно уверены, что эмулятор ещё не загружен, и внедрять собственную
    функцию в GetVersionExW, которая будет искать нужные переменные и записывать
    свой HWID.

    После вызова GetVersionExW функция начинает получать ключи дисков. В подробности
    работы я не буду вдаваться, но на некоторых версиях эмулятора или SSD функция
    не получает ключ правильно и падает. С помощью патча мы будем блокировать получение
    ключа эмулятором, и вместо этого будем давать ему свой, когда будет вызвана
    GetVersionExW.
  *)

  H := GetModuleHandle('kernel32.dll');
  if H = 0 then
  begin
    (* kernel32.dll библиотека не найдена. Это весьма и весьма неожиданный
       сценарий, поскольку эта библиотека есть в каждом процессе. Скорее всего
       мы имеем дело с какими-то механизмами защиты из других модулей. *)

    Exit(RF_ERROR_WINAPI_KERNEL_NOT_FOUND);
  end;

  P := GetProcAddress(H, 'GetVersionExW');
  if P = nil then
  begin
    (* GetVersionExW функция не найдена. Тоже очень странная ситуация,
       по странности аналогичная неудаче в попытке найти kernel32.dll. *)

    Exit(RF_ERROR_WINAPI_GETVERSION_NOT_FOUND);
  end;

  @orgGetVersionExW := HookWinAPI(P, @GetVersionExW);

  if @orgGetVersionExW = nil then
  begin
    (* Не удалось выполнить перехват функции GetVersionExW. Наибольшая вероятность -
       модификация пролога функции GetVersionExW и поэтому HookWinAPI отвергла перехват,
       поскольку требует, чтобы первая инструкция функции была 'mov edi, edi'. *)

    Exit(RF_ERROR_WINAPI_NOT_HOOKED);
  end;

  Exit(RF_NO_ERROR);
end;

end.
