unit Protector.Engine.Search;

{$I Default.inc}

interface

uses
  System.SySUtils,

  Winapi.Windows,

  Xander.Memory,
  Xander.MsgAPI,
  Xander.CPUID,
  Xander.Console,

  Steam.API,

  Protector.Engine.Routines,
  Protector.Emulator,
  Protector.Global;

function FindEngineModule: Boolean;
function FindClientModule: Boolean;
function FindLauncherModule: Boolean;
function FindTier0Module: Boolean;
function FindGameUIModule: Boolean;
function FindSteamclientModule: Boolean;
function FindServerBrowserModule: Boolean;
function FindSteamClient: Boolean;
function FindWinSock2: Boolean;

procedure FindModules;

implementation

function FindEngineModule: Boolean;
begin
  EngineBase := Pointer(GetModuleHandle('engine.dll'));
  EngineSize := GetModuleSize(HMODULE(EngineBase));
  Result := EngineBase <> nil;
end;

function FindClientModule: Boolean;
begin
  ClientBase := Pointer(GetModuleHandle('client.dll'));

  if ClientBase = nil then
    ClientBase := Pointer(GetModuleHandle('client_panorama.dll'));

  ClientSize := GetModuleSize(HMODULE(ClientBase));
  Result := ClientBase <> nil;
end;

function FindLauncherModule: Boolean;
begin
  LauncherBase := Pointer(GetModuleHandle('launcher.dll'));
  LauncherSize := GetModuleSize(HMODULE(LauncherBase));
  Result := LauncherBase <> nil;
end;

function FindTier0Module: Boolean;
begin
  Tier0Base := Pointer(GetModuleHandle('tier0.dll'));
  Tier0Size := GetModuleSize(HMODULE(Tier0Base));
  Result := Tier0Base <> nil;
end;

function FindGameUIModule: Boolean;
begin
  GameUIBase := Pointer(GetModuleHandle('vgui2.dll'));
  GameUISize := GetModuleSize(HMODULE(GameUIBase));
  Result := GameUIBase <> nil;
end;

function FindSteamclientModule: Boolean;
begin
  SCBase := Pointer(GetModuleHandle('steamclient.dll'));
  SCSize := GetModuleSize(HMODULE(SCBase));
  Result := SCBase <> nil;
end;

function FindServerBrowserModule: Boolean;
begin
  SBBase := Pointer(GetModuleHandle('serverbrowser.dll'));
  SBSize := GetModuleSize(HMODULE(SBBase));
  Result := SBBase <> nil;
end;

function FindSteamClient: Boolean;
begin
  SCBase := Pointer(GetModuleHandle('steamclient.dll'));
  SCSize := GetModuleSize(HMODULE(SCBase));
  Result := SCBase <> nil;
end;

function FindWinSock2: Boolean;
begin
  WSBase := Pointer(GetModuleHandle('ws2_32.dll'));
  WSSize := GetModuleSize(HMODULE(WSBase));
  Result := WSBase <> nil;
end;

procedure FindModules;
begin
  while not FindWinSock2 do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('WinSock2 found: %.8X', [Cardinal(WSBase)]);
{$ENDIF}

  Hook_WS2_32;

  while not FindSteamClient do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('SteamClient found: %.8X', [Cardinal(SCBase)]);
{$ENDIF}

  {$I Obfuscation-2.inc}

  while not FindEngineModule do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('Engine found: %.8X', [Cardinal(EngineBase)]);
{$ENDIF}

  while not FindClientModule do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('Client found: %.8X', [Cardinal(ClientBase)]);
{$ENDIF}

  while not FindLauncherModule do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('Launcher found: %.8X', [Cardinal(LauncherBase)]);
{$ENDIF}

  while not FindTier0Module do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('Tier0 found: %.8X', [Cardinal(Tier0Base)]);
{$ENDIF}

  while not FindGameUIModule do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('GameUI found: %.8X', [Cardinal(GameUIBase)]);
{$ENDIF}

  while not FindServerBrowserModule do
    Sleep(50);

{$IFDEF DEBUG}
  TConsole.Important('ServerBrowser found: %.8X', [Cardinal(SBBase)]);
{$ENDIF}
end;

end.
