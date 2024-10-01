unit Xander.CPUID;

{$I Default.inc}
{$Z4}

interface

uses
  System.SysUtils,
  System.AnsiStrings,

  System.IOUtils,
  Winapi.Windows;

function GetVolumeId: AnsiString;
function GetCPUName: AnsiString;
function GetHDDID: AnsiString;

type
  STORAGE_PROPERTY_ID = (StorageDeviceProperty = 0);
  STORAGE_QUERY_TYPE = (PropertyStandardQuery = 0, PropertyExistsQuery, PropertyMaskQuery, PropertyQueryMaxDefined);

type
  STORAGE_PROPERTY_QUERY = record
    PropertyId: STORAGE_PROPERTY_ID;
    QueryType: STORAGE_QUERY_TYPE;
    AdditionalParameters: array[0..3] of Byte;
  end;
  PStoragePropertyQuery = ^TStoragePropertyQuery;
  TStoragePropertyQuery = STORAGE_PROPERTY_QUERY;

  STORAGE_DEVICE_DESCRIPTOR = packed record
    Version: LongWord;
    Size: LongWord;
    DeviceType: Byte;
    DeviceTypeModifier: Byte;
    RemovableMedia: Boolean;
    CommandQueueing: Boolean;
    VendorIdOffset: LongWord;
    ProductIdOffset: LongWord;
    ProductRevisionOffset: LongWord;
    SerialNumberOffset: LongWord;
    STORAGE_BUS_TYPE: LongWord;
    RawPropertiesLength: LongWord;
    RawDeviceProperties: array[0..511] of Byte;
  end;
  PStorageDeviceDescriptor = ^TStorageDeviceDescriptor;
  TStorageDeviceDescriptor = STORAGE_DEVICE_DESCRIPTOR;

  STORAGE_DESCRIPTOR_HEADER = record
    Version: LongWord;
    Size: LongWord;
  end;
  PStorageDescroptorHeader = ^TStorageDescroptorHeader;
  TStorageDescroptorHeader = STORAGE_DESCRIPTOR_HEADER;

implementation

function GetCPUName: AnsiString;
var
  CPURet: TCPUIDRec;
begin
  SetLength(Result, SizeOf(TCPUIDRec) * 3);

  CPURet := GetCPUID($80000002);
  System.Move(CPURet, Result[1], SizeOf(TCPUIDRec));

  CPURet := GetCPUID($80000003);
  System.Move(CPURet, Result[17], SizeOf(TCPUIDRec));

  CPURet := GetCPUID($80000004);
  System.Move(CPURet, Result[33], SizeOf(TCPUIDRec));

  SetLength(Result, System.AnsiStrings.StrLen(PAnsiChar(Result)));
end;

function GetVolumeId: AnsiString;
var
  VolumeId: LongWord;
begin
  if GetVolumeInformation('C:\', nil, 0, @VolumeId, PCardinal(nil)^, PCardinal(nil)^, nil, 0) then
    Result := VolumeId.ToString
  else
  begin
    Result := '';
  end;
end;

function GetHDDID: AnsiString;

  function GetSystemDrive: string;
  var
    Temp: string;
  begin
    Temp := TPath.GetTempPath;
    if Temp <> '' then
      Result := Format('\\.\%s:', [Temp[1]])
    else
      Result := '';
  end;

var
  DriveName: string;
  Device: THandle;

  SPQ: TStoragePropertyQuery;
  SDH: TStorageDescroptorHeader;

  BytesReturned: Cardinal;
  OutBufSize: Integer;
  OutBuf: Pointer;

  DeviceDescriptor: PStorageDeviceDescriptor;
  SerialNumberOffset: Integer;

  HDDID: PAnsiChar;
begin
  DriveName := GetSystemDrive;
  if DriveName = '' then
    Exit('');

  Device := CreateFile(Pointer(DriveName), 0, FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
  if Device = INVALID_HANDLE_VALUE then
    Exit('');

  FillChar(SPQ, SizeOf(SPQ), 0);
  SPQ.PropertyId := StorageDeviceProperty;
  SPQ.QueryType := PropertyStandardQuery;

  FillChar(SDH, SizeOf(SDH), 0);

  BytesReturned := 0;
  if not DeviceIoControl(Device, IOCTL_STORAGE_QUERY_PROPERTY, @SPQ, SizeOf(SPQ), @SDH, SizeOf(SDH), BytesReturned, nil) then
  begin
    CloseHandle(Device);
    Exit('');
  end;

  OutBufSize := SDH.Size;
  OutBuf := GetMemory(OutBufSize);
  FillChar(OutBuf^, OutBufSize, 0);

  if not DeviceIoControl(Device, IOCTL_STORAGE_QUERY_PROPERTY, @SPQ, SizeOf(SPQ), OutBuf, OutBufSize, BytesReturned, nil) then
  begin
    FreeMemory(OutBuf);
    CloseHandle(Device);
    Exit('');
  end;

  DeviceDescriptor := PStorageDeviceDescriptor(OutBuf);
  SerialNumberOffset := DeviceDescriptor.SerialNumberOffset;

  if SerialNumberOffset <> 0 then
  begin
    HDDID := @PByte(OutBuf)[SerialNumberOffset];
    Result := HDDID;

    SetLength(Result, System.AnsiStrings.StrLen(HDDID));
  end;

  FreeMemory(OutBuf);
  CloseHandle(Device);
end;

end.
