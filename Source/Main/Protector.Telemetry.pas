(*========= (C) Copyright 2017-2018, Alexander B. All rights reserved. ========*)
(*                                                                             *)
(*  Имя модуля:                                                                *)
(*    Protector.Telemetry                                                      *)
(*                                                                             *)
(*  Назначение:                                                                *)
(*    Сбор информации о системе, игре и исключающих ситуациях.                 *)
(*=============================================================================*)

unit Protector.Telemetry;

{$I Default.inc}

interface

uses
  System.SysUtils,
  System.DateUtils,
  System.JSON,
  System.IOUtils,
  System.Win.ComObj,
  System.Variants,

  HLSDK,

  Xander.Helpers,
  Xander.Git.Info,

  Winapi.Windows,
  Winapi.ActiveX,

  Protector.Notificator,
  Protector.Global;

function GetProjectBuild: Integer;

type
  TArchitectureHelper = record helper for TOSVersion.TArchitecture
  public
    function ToString: string;
  end;

type
  TJSONObjectHelper = class helper for TJSONObject
  private
    function GetThis: TJSONObject; inline;
  public
    property This: TJSONObject read GetThis;
  end;

type
  TTelemetry = class
  private
    class var FProjectStartUnixTime: Int64;
    class var FProjectStartDateTime: TDateTime;

    class var FTotalRAM: UInt64;
    class var FCPUName: string;
  private
    class function GetRAMInfo(out Info: TMemoryStatusEx): Boolean; static;
    class function GetUsedRAM: Integer; static;
    class function GetTotalRAM: UInt64; static;
    class function GetCPUName: string; static;
  private
    (* class конструктор, вызывается при старте протектора. *)
    class constructor Create;
  public
    class property TotalRAM: UInt64 read FTotalRAM;
    class property UsedRAM: Integer read GetUsedRAM;
    class property CPUName: string read FCPUName;

    (* Получить результат функции ToJSONObject в виде строки. *)
    class function ToJSON: string; static;

    (* Собрать всю информацию о системе, игре и протекторе и вернуть в формате JSON. *)
    class function ToJSONObject: TJSONObject; static;

    class function GetWindowsInfo: string; static;
  end;

implementation

{ TTelemetry }

class constructor TTelemetry.Create;
begin
  FProjectStartUnixTime := 1444867200; // 19.10.2015
  FProjectStartDateTime := System.DateUtils.UnixToDateTime(FProjectStartUnixTime);

  FTotalRAM := GetTotalRAM;
  FCPUName := GetCPUName;
end;

function GetProjectBuild: Integer;
var
  BuildDate: TDateTime;
  NT: PImageNtHeaders;
begin
  NT := Ptr(HInstance + Cardinal(PImageDosHeader(HInstance)^._lfanew));
  BuildDate := NT^.FileHeader.TimeDateStamp / SecsPerDay + UnixDateDelta;

  Result := Round(BuildDate - TTelemetry.FProjectStartDateTime);
end;

class function TTelemetry.GetCPUName: string;
var
  CPURet: TCPUIDRec;
  StrRet: array[0..47] of AnsiChar;
begin
  CPURet := GetCPUID($80000002); Move(CPURet, StrRet[0], SizeOf(CPURet));
  CPURet := GetCPUID($80000003); Move(CPURet, StrRet[16], SizeOf(CPURet));
  CPURet := GetCPUID($80000004); Move(CPURet, StrRet[32], SizeOf(CPURet));

  Result := StrRet;
end;

class function TTelemetry.GetRAMInfo(out Info: TMemoryStatusEx): Boolean;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.dwLength := SizeOf(Info);
  Result := GlobalMemoryStatusEx(Info);
end;

class function TTelemetry.GetUsedRAM: Integer;
var
  Info: TMemoryStatusEx;
begin
  if GetRAMInfo(Info) then
    Result := Info.dwMemoryLoad
  else
    Result := 0;
end;

class function TTelemetry.GetTotalRAM: UInt64;
var
  Info: TMemoryStatusEx;
begin
  if GetRAMInfo(Info) then
    Result := Info.ullTotalPhys
  else
    Result := 0;
end;

class function TTelemetry.GetWindowsInfo: string;
begin
  Result := Format('%s,%s,%d,%d.%d',
    [TOSVersion.Name, TOSVersion.Architecture.ToString, TOSVersion.Build, TOSVersion.Major, TOSVersion.Minor]);
end;

class function TTelemetry.ToJSON: string;
var
  JSON: TJSONObject;
begin
  JSON := TTelemetry.ToJSONObject;

  if JSON <> nil then
  begin
    Result := TTelemetry.ToJSONObject.ToJSON;
    JSON.Free;
  end
  else
    Result := EmptyStr;
end;

class function TTelemetry.ToJSONObject: TJSONObject;
var
  Elements: TJSONObject absolute Result;
begin
  try
    Elements := TJSONObject.Create;

    with TJSONObject.Create do
    begin
      AddPair('Name',    TOSVersion.Name);
      AddPair('Arch',    TOSVersion.Architecture.ToString);
      AddPair('Build',   TOSVersion.Build.ToString);
      AddPair('Version', TOSVersion.Major.ToString + '.' + TOSVersion.Minor.ToString);

      Elements.AddPair('System', This);
    end;

    with TJSONObject.Create do
    begin
      AddPair('CPU', GetCPUName);
      AddPair('RAM Total', (GetTotalRAM div 1024 div 1024).ToString + ' MB');
      AddPair('RAM Usage', GetUsedRAM.ToString + '%');

      Elements.AddPair('Hardware', This);    
    end;
    
    with TJSONObject.Create do
    begin
      AddPair('Library',   Protector.Global.HLName);
      AddPair('Build',     Protector.Global.BuildNumber.ToString);
      AddPair('Directory', Protector.Global.Engine.GetGameDirectory);
      AddPair('ID',        Protector.Global.Engine.GetGameID.ToString);

      AddPair('Server', LastGameServer);

      if CState <> nil then
        AddPair('State', CState^.ToString);

      Elements.AddPair('Engine', This);
    end;

    with TJSONObject.Create do
    begin
      AddPair('Build', GetProjectBuild.ToString);
      AddPair('Commit', BUILD_COMMIT_SHA);

      Elements.AddPair('Protector', This);
    end;
  except
    Elements := nil;
  end;
end;

{ TArchitectureHelper }

function TArchitectureHelper.ToString: string;
begin
  case Self of
    arIntelX86: Exit('Intel x86');
    arIntelX64: Exit('Intel x64');
    arARM32: Exit('ARM x32');
    arARM64: Exit('ARM x64');
  else
    Result := 'Unknown';
  end;
end;

{ TJSONObjectHelper }

function TJSONObjectHelper.GetThis: TJSONObject;
begin
  Result := Self;
end;

end.
