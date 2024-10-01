unit Winapi.Native;

interface

uses
  Winapi.Windows;

type
  UNICODE_STRING = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer: PWideChar;
  end;
  PUnicodeString = ^TUnicodeString;
  TUnicodeString = UNICODE_STRING;

  PListEntry = ^TListEntry;
  _LIST_ENTRY = record
    Flink: PListEntry;
    Blink: PListEntry;
  end;
  TListEntry = _LIST_ENTRY;
  LIST_ENTRY = _LIST_ENTRY;

  PLdrModule = ^TLdrModule;
  TLdrModule = packed record
    InLoadOrderModuleList: TListEntry;
    InMemoryOrderModuleList: TListEntry;
    InInitializationOrderModuleList: TListEntry;
    BaseAddress: Pointer;
    EntryPoint: Pointer;
    SizeOfImage: Cardinal;
    FullDllName: TUnicodeString;
    BaseDllName: TUnicodeString;
    Flags: Cardinal;
    LoadCount: Word;
    TlsIndex: Word;
    HashTableEntry: TListEntry;
    TimeDataStamp: Cardinal;
  end;

  _PEB_LDR_DATA = record
    Length: Cardinal;
    Initialized: Boolean;
    SsHandle: Pointer;
    InLoadOrderModuleList: TListEntry;
    InMemoryOrderModuleList: TListEntry;
    InInitializationOrderModuleList: TListEntry;
    EntryInProgress: Pointer;
  end;
  PPebLdrData = ^TPebLdrData;
  TPebLdrData = _PEB_LDR_DATA;

  RTL_DRIVE_LETTER_CURDIR = record
    Flags: Word;
    Length: Word;
    TimeStamp: Cardinal;
    DosPath: UNICODE_STRING;
  end;

  PRTL_USER_PROCESS_PARAMETERS = ^RTL_USER_PROCESS_PARAMETERS;
  RTL_USER_PROCESS_PARAMETERS = record
    MaximumLength: Cardinal;
    Length: Cardinal;
    Flags: Cardinal;
    DebugFlags: Cardinal;
    ConsoleHandle: Pointer;
    ConsoleFlags: Cardinal;
    StdInputHandle: Cardinal;
    StdOutputHandle: Cardinal;
    StdErrorHandle: Cardinal;
    CurrentDirectoryPath: UNICODE_STRING;
    CurrentDirectoryHandle: Cardinal;
    DllPath: UNICODE_STRING;
    ImagePathName: UNICODE_STRING;
    CommandLine: UNICODE_STRING;
    Environment: Pointer;
    StartingPositionLeft: Cardinal;
    StartingPositionTop: Cardinal;
    Width: Cardinal;
    Height: Cardinal;
    CharWidth: Cardinal;
    CharHeight: Cardinal;
    ConsoleTextAttributes: Cardinal;
    WindowFlags: Cardinal;
    ShowWindowFlags: Cardinal;
    WindowTitle: UNICODE_STRING;
    DesktopName: UNICODE_STRING;
    ShellInfo: UNICODE_STRING;
    RuntimeData: UNICODE_STRING;
    DLCurrentDirectory: array [0..$1F] of RTL_DRIVE_LETTER_CURDIR;
  end;

  PRTL_CRITICAL_SECTION = ^RTL_CRITICAL_SECTION;
  RTL_CRITICAL_SECTION = record
    DebugInfo: Pointer;
    LockCount: LONG;
    RecursionCount: LONG;
    OwningThread: Pointer;
    LockSemaphore: Pointer;
    SpinCount: ULONG;
  end;

  _PEB = packed record
    InheritedAddressSpace: Boolean;
    ReadImageFileExecOptions: Boolean;
    BeingDebugged: Boolean;
    BitField: Boolean;
    Mutant: Pointer;
    ImageBaseAddress: Pointer;
    Ldr: PPebLdrData;
    ProcessParameters: PRTL_USER_PROCESS_PARAMETERS;
    SubSystemData: Pointer;
    ProcessHeap: Pointer;
    FastPebLock: PRTL_CRITICAL_SECTION;
    AtlThunkSListPtr: Pointer;
    IFEOKey: Pointer;
    CrossProcessFlags: Cardinal;
    ProcessInJob: Cardinal;
    KernelCallbackTable: Pointer;
    SystemReserved: array [0..0] of Cardinal;
    SpareUlong: Cardinal;
    FreeList: Pointer;
    TlsExpansionCounter: Cardinal;
    TlsBitmap: Pointer;
    TlsBitmapBits: array [0..1] of Cardinal;
    ReadOnlySharedMemoryBase: Pointer;
    HotpatchInformation: Pointer;
    ReadOnlyStaticServerData: PPointer;
    AnsiCodePageData: Pointer;
    OemCodePageData: Pointer;
    UnicodeCaseTableData: Pointer;
    NumberOfProcessors: Cardinal;
    NtGlobalFlag: Cardinal;
    CriticalSectionTimeout: Int64;
    HeapSegmentReserve: Cardinal;
    HeapSegmentCommit: Cardinal;
    HeapDeCommitTotalFreeThreshold: Cardinal;
    HeapDeCommitFreeBlockThreshold: Cardinal;
    NumberOfHeaps: Cardinal;
    MaximumNumberOfHeaps: Cardinal;
    ProcessHeaps: PPointer;
    GdiSharedHandleTable: Pointer;
    ProcessStarterHelper: Pointer;
    GdiDCAttributeList: Cardinal;
    LoaderLock: PRTL_CRITICAL_SECTION;
    OSMajorVersion: Cardinal;
    OSMinorVersion: Cardinal;
    OSBuildNumber: Word;
    OSCSDVersion: Word;
    OSPlatformId: Cardinal;
    ImageSubsystem: Cardinal;
    ImageSubsystemMajorVersion: Cardinal;
    ImageSubsystemMinorVersion: Cardinal;
    GdiHandleBuffer: array [0..33] of Cardinal;
    PostProcessInitRoutine: Pointer;
    TlsExpansionBitmap: Pointer;
    TlsExpansionBitmapBits: array [0..31] of Cardinal;
    SessionId: Cardinal;
    AppCompatFlags: Int64;
    AppCompatFlagsUser: Int64;
    pShimData: Pointer;
    AppCompatInfo: Pointer;
    CSDVersion: UNICODE_STRING;
    ActivationContextData: Pointer;
    ProcessAssemblyStorageMap: Pointer;
    SystemDefaultActivationContextData: Pointer;
    SystemAssemblyStorageMap: Pointer;
    MinimumStackCommit: Cardinal;
    FlsCallback: Pointer;
    FlsListHead: LIST_ENTRY;
    FlsBitmap: Pointer;
    FlsBitmapBits: Cardinal;
    FlsHighIndex: Cardinal;
    WerRegistrationData: Pointer;
    WerShipAssertPtr: Pointer;
  end;
  PPeb = ^TPeb;
  TPeb = _PEB;

implementation

end.
