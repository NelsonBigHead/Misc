{
        Process Walker DLL Header Unit (Object Pascal)
        NT Low level system helper library

        lib version: 6.0.0.2608 (31 August 2026)

}
unit WalkerNT;

interface

uses Windows, WinNative;

type
  _DllVersionInfo = record
    cbSize: ULONG;
    uMajorVersion: ULONG;
    uMinorVersion: ULONG;
    uBuildNumber: ULONG;
    uSuccessCode: NTSTATUS;
    cDesc: array[0..59] of char;
  end;
  DLLVERSIONINFO = _DllVersionInfo;
  PDLLVERSIONINFO = ^_DllVersionInfo;

  //WalkThreads Data Structure
  _WALKER_THREAD = record
    KernelTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    CreateTime: LARGE_INTEGER;
    UniqueProcess: DWORD;
    UniqueThread: DWORD;
    Priority: KPRIORITY;
    BasePriority: KPRIORITY;
    State: THREAD_STATE;
    WaitReason: integer;
  end;
  WALKER_THREAD = _WALKER_THREAD;
  PWALKER_THREAD = ^_WALKER_THREAD;

  //Walk Handles Data Structure
  _WALKER_HANDLE = record
    ProcessId: cardinal;
    ObjectTypeNumber: UCHAR;
    Flags: UCHAR;
    Handle: smallint;
    ObjectPtr: pointer;
    GrantedAccess: ACCESS_MASK;
  end;
  WALKER_HANDLE = _WALKER_HANDLE;
  PWALKER_HANDLE = ^_WALKER_HANDLE;

  //Walk Drivers Data Structure
  _WALKER_DRIVER = record
    Base: pointer;
    Size: ULONG;
    Flags: ULONG;
    Index: smallint;
    LoadCount: smallint;
    ModuleNameOffset: smallint;
    ImageName: array[0..MAX_PATH] of char;
  end;
  WALKER_DRIVER = _WALKER_DRIVER;
  PWALKER_DRIVER = ^_WALKER_DRIVER;

  _WALKER_OBJECT_INFORMATION = record
    ohi: WALKER_HANDLE;
    obi: OBJECT_BASIC_INFORMATION;
    oti: POBJECT_TYPE_INFORMATION;
    oni: array[0..1023] of char;
  end;
  WALKER_OBJECT_INFORMATION = _WALKER_OBJECT_INFORMATION;
  PWALKER_OBJECT_INFORMATION = ^_WALKER_OBJECT_INFORMATION;

  _WALKER_MODULE = record
    dwSize: ULONG;
    ProccntUsage: ULONG;
    modBaseAddress: pbyte;
    modBaseSize: ULONG;
    hModule: HMODULE;
    ModName: array[0..MAX_PATH] of char;
    ModNameEx: array[0..MAX_PATH] of char; //w/o + NameOffset
  end;
  WALKER_MODULE = _WALKER_MODULE;
  PWALKER_MODULE = ^_WALKER_MODULE;

  _WALKER_MODULE_EX = record
    DllBaseAddress: Pointer; //BaseAddress
    EntryPoint: Pointer;
    SizeOfImage: ULONG; // in bytes
    Flags: ULONG; // LDR_*
    LoadCount: USHORT; //ProccntUsage
    FullDllName: array[0..MAX_PATH] of WCHAR;
  end;
  WALKER_MODULE_EX = _WALKER_MODULE_EX;
  PWALKER_MODULE_EX = ^_WALKER_MODULE_EX;

  _WALKER_HEAP = record
    dwSize: ULONG;
    nw32HeapID: ULONG;
    dwFlags: ULONG;
  end;
  WALKER_HEAP = _WALKER_HEAP;
  PWALKER_HEAP = ^_WALKER_HEAP;

  _WALKER_PERFORMANCE_INFORMATION = record
    CommitTotal: int64;
    CommitLimit: int64;
    CommitPeak: int64;
    PhysicalTotal: int64;
    PhysicalAvailable: int64;
    SystemCache: int64;
    KernelTotal: int64;
    KernelPaged: int64;
    KernelNonpaged: int64;
    PageSize: cardinal;
    HandleCount: cardinal;
    ProcessCount: cardinal;
    ThreadCount: cardinal;
  end;
  WALKER_PERFORMANCE_INFORMATION = _WALKER_PERFORMANCE_INFORMATION;
  PWALKER_PERFORMANCE_INFORMATION = ^_WALKER_PERFORMANCE_INFORMATION;

  TWALKER_CPU_INFORMATION = packed record
    ProcessorFamily: cardinal;
    ProcessorModel: cardinal;
    ProcessorStepping: cardinal;
    FrequencyMHz: int64;
    VendorString: array[0..15] of ansichar;
    BrandString: array[0..63] of ansichar;
    Is64BitCapable: byte;
    IsNXSupported: byte;
    IsFPU: byte;
    IsTSC: byte;
    IsCMOV: byte;
    IsMMX: byte;
    IsSSE: byte;
    IsSSE2: byte;
    IsSSE3: byte;
    IsHTT: byte;
    IsIA64: byte;
    IsAMDMMX: byte;
    Is3DNow: byte;
    Is3DNowExt: byte;
    Reserved: array[0..2] of byte;
  end;

  PWALKER_CPU_INFORMATION = ^TWALKER_CPU_INFORMATION;

  _WALKER_MAPPED_FILE = record
    MPFAddr: Pointer;
    WorkSetId: ULONG_PTR;
    lpFileName: array[0..MAX_PATH] of WCHAR;
  end;
  WALKER_MAPPED_FILE = _WALKER_MAPPED_FILE;
  PWALKER_MAPPED_FILE = ^_WALKER_MAPPED_FILE;

  PWALKER_THREAD_ARRAY = ^TWALKER_THREAD_ARRAY;
  TWALKER_THREAD_ARRAY = array[0..0] of WALKER_THREAD;

  PWALKER_HANDLE_ARRAY = ^TWALKER_HANDLE_ARRAY;
  TWALKER_HANDLE_ARRAY = array[0..0] of WALKER_HANDLE;

  PWALKER_OBJECT_INFORMATION_ARRAY = ^TWALKER_OBJECT_INFORMATION_ARRAY;
  TWALKER_OBJECT_INFORMATION_ARRAY = array[0..0] of WALKER_OBJECT_INFORMATION;
  PWALKER_DRIVER_ARRAY = ^TWALKER_DRIVER_ARRAY;
  TWALKER_DRIVER_ARRAY = array[0..0] of WALKER_DRIVER;
  PWALKER_MODULE_ARRAY = ^TWALKER_MODULE_ARRAY;
  TWALKER_MODULE_ARRAY = array[0..0] of WALKER_MODULE;
  PWALKER_MODULE_EX_ARRAY = ^TWALKER_MODULE_EX_ARRAY;
  TWALKER_MODULE_EX_ARRAY = array[0..0] of WALKER_MODULE_EX;
  PWALKER_HEAP_ARRAY = ^TWALKER_HEAP_ARRAY;
  TWALKER_HEAP_ARRAY = array[0..0] of WALKER_HEAP;
  PULONG_ARRAY = ^TULONG_ARRAY;
  TULONG_ARRAY = array[0..0] of ULONG;
  PWALKER_MAPPED_FILE_ARRAY = ^TWALKER_MAPPED_FILE_ARRAY;
  TWALKER_MAPPED_FILE_ARRAY = array[0..0] of WALKER_MAPPED_FILE;

  _ThreadsEntry = record
    ThreadsCount: integer;
    Threads: PWALKER_THREAD_ARRAY;
  end;
  ThreadsEntry = _ThreadsEntry;
  PThreadsEntry = ^_ThreadsEntry;

  _HandlesEntry = record
    HandlesCount: cardinal;
    Handles: PWALKER_HANDLE_ARRAY;
  end;
  HandlesEntry = _HandlesEntry;
  PHandlesEntry = ^_HandlesEntry;

  _ObjectsEntry = record
    ObjectsCount: cardinal;
    Objects: PWALKER_OBJECT_INFORMATION_ARRAY;
  end;
  ObjectsEntry = _ObjectsEntry;
  PObjectsEntry = ^_ObjectsEntry;

  _DriversEntry = record
    DriversCount: cardinal;
    Drivers: PWALKER_DRIVER_ARRAY;
  end;
  DriversEntry = _DriversEntry;
  PDriversEntry = ^_DriversEntry;

  _ModulesEntry = record
    ModulesCount: cardinal;
    Modules: PWALKER_MODULE_ARRAY;
  end;
  ModulesEntry = _ModulesEntry;
  PModulesEntry = ^_ModulesEntry;

  _ModulesEntryEx = record
    ModulesCount: cardinal;
    Modules: PWALKER_MODULE_EX_ARRAY;
  end;
  ModulesEntryEx = _ModulesEntryEx;
  PModulesEntryEx = ^_ModulesEntryEx;

  _HeapsEntry = record
    HeapsCount: cardinal;
    Heaps: PWALKER_HEAP_ARRAY;
  end;
  HeapsEntry = _HeapsEntry;
  PHeapsEntry = ^_HeapsEntry;

  _HeapsEntryEx = record
    HeapsCount: cardinal;
    Heaps: PULONG_ARRAY;
  end;
  HeapsEntryEx = _HeapsEntryEx;
  PHeapsEntryEx = ^_HeapsEntryEx;

  _MPFEntry = record
    MPFCount: ULONG;
    MPFs: PWALKER_MAPPED_FILE_ARRAY;
  end;
  MPFEntry = _MPFEntry;
  PMPFEntry = ^_MPFEntry;

  _ProcessInformation = record
    ErrorRet: integer;
    ProcInfo: PPROCESS_BASIC_INFORMATION;
    ProcPEB: PVOID;
  end;
  ProcessInformation = _ProcessInformation;
  PProcessInformation = ^_ProcessInformation;

  _ModuleInformation = record
    BaseOfDll: LPVOID;
    SizeOfImage: DWORD;
    EntryPoint: LPVOID;
  end;
  ModuleInformation = _ModuleInformation;
  PModuleInformation = ^_ModuleInformation;

const
  WalkerLib = 'ProcWalker.dll';
  ERROR_NOT_IMPLEMENTED = cardinal(-1);
  ThreadsEntryArray = 10;
  ProcessesEntryArray = 12;
  PageFilesEntryArray = 14;
  HandlesEntryArray = 16;
  DriversEntryArray = 18;
  ObjectsEntryArray = 20;
  ModulesEntryArray = 22;
  HeapsEntryArray = 24;
  ProcessInfoEntry = 48;
  PerformanceInfoEntry = 50;
  PerformanceInfoExEntry = 52;
  MappedFilesArray = 64;

procedure DllGetVersion(DllVersion: PDLLVERSIONINFO); stdcall; external WalkerLib;
function WalkerInit(pInfo: PDLLVERSIONINFO): NTSTATUS; stdcall; external WalkerLib;
function WalkThreads(ProcessID: cardinal; Data: PThreadsEntry): integer; stdcall; external WalkerLib;
function WalkCleanup(Data: pointer; DataType: integer): NTSTATUS; stdcall; external WalkerLib;
function WalkProcesses(): PSYSTEM_PROCESS_INFORMATION; stdcall; external WalkerLib;
function WalkHandles(Data: PHandlesEntry): integer; stdcall; external WalkerLib;
function WalkObjects(ProcessID: cardinal; Data: PObjectsEntry): integer; stdcall; external WalkerLib;
function WalkDrivers(Data: PDriversEntry): integer; stdcall; external WalkerLib;
function WalkPageFiles(): PSYSTEM_PAGEFILE_INFORMATION; stdcall; external WalkerLib;
function WalkModules(ProcessID: cardinal; Data: PModulesEntry): integer; stdcall; external WalkerLib;
function WalkModulesEx(ProcessID: cardinal; dataEx: PModulesEntryEx): integer; stdcall; external WalkerLib;
function WalkHeaps(ProcessID: cardinal; Data: PHeapsEntry): NTSTATUS; stdcall; external WalkerLib;
function WalkHeapsEx(ProcessID: cardinal; Data: PHeapsEntryEx): integer; stdcall; external WalkerLib;
function WalkCPUTime(ProcessorNumber: integer): int64; stdcall; external WalkerLib;
function WalkProcessMappedFiles(ProcessID: cardinal; dwMdArray: PMPFEntry): integer; stdcall; external WalkerLib;

//NtHlpXXX functions
function NtHlpKillProcess(uProcessId: ULONG): BOOL; stdcall; external WalkerLib;
function NtHlpKillProcessTree(uProcessId: ULONG): BOOL; stdcall; external WalkerLib;
function NtHlpInjectLibraryA(uProcessId: ULONG; const lpsName: pansichar): integer; stdcall; external WalkerLib;
function NtHlpInjectLibraryW(uProcessId: ULONG; const lpwName: pwidechar): integer; stdcall; external WalkerLib;
function NtHlpEjectLibraryA(uProcessId: ULONG; const lpsName: pansichar): integer; stdcall; external WalkerLib;
function NtHlpEjectLibraryW(uProcessId: ULONG; const lpwName: pwidechar): integer; stdcall; external WalkerLib;
function NtHlpProcessInformation(uProcessId: ULONG): PProcessInformation; stdcall; external WalkerLib;
function NtHlpThreadInformation(uThreadID: ULONG): PTHREAD_BASIC_INFORMATION; stdcall; external WalkerLib;
function NtHlpEnableIsDebuggerPresent(uProcessId: ULONG; bEnable: BOOL): BOOL; stdcall; external WalkerLib;
function NtHlpReadPEB(uProcessId: ULONG; PebAddress: ULONG): PVOID; stdcall; external WalkerLib;
function NtHlpIsDebugged(uProcessId: ULONG): integer; stdcall; external WalkerLib;
function GetModuleFileNameExA(uProcessId: ULONG; hModule: HMODULE; FileName: LPSTR; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetModuleFileNameExW(uProcessId: ULONG; hModule: HMODULE; FileName: LPWSTR; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetModuleInformation(uProcessId: ULONG; hModule: HMODULE; ModuleInfo: PModuleInformation; cb: ULONG): BOOL;
  stdcall; external WalkerLib;
function GetProcessMemoryInfo(uProcessId: ULONG; Counters: PVM_COUNTERS; cb: ULONG): BOOL; stdcall; external WalkerLib;
function GetProcessCommandLineA(uProcessId: ULONG; CommandLine: pansichar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessCommandLineW(uProcessId: ULONG; CommandLine: pwidechar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessImageFileNameA(uProcessId: ULONG; ImageFileName: pansichar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessImageFileNameW(uProcessId: ULONG; ImageFileName: pwidechar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessCurrentDirectoryA(uProcessId: ULONG; CurrentDir: pansichar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessCurrentDirectoryW(uProcessId: ULONG; CurrentDir: pwidechar; cb: ULONG): ULONG;
  stdcall; external WalkerLib;
function GetProcessEnvironmentA(uProcessId: ULONG; lvEnv: pansichar; uSize: ULONG): ULONG; stdcall; external WalkerLib;
function GetProcessEnvironmentW(uProcessId: ULONG; lvEnv: pwidechar; uSize: ULONG): ULONG; stdcall; external WalkerLib;
function GetPerformanceInfo(): PSYSTEM_PERFORMANCE_INFORMATION; stdcall; external WalkerLib;
function GetPerformanceInfoEx(PerformanceInfo: PWALKER_PERFORMANCE_INFORMATION): NTSTATUS; stdcall; external WalkerLib;
function GetCpuInformation(CpuInfo: PWALKER_CPU_INFORMATION): BOOL; stdcall; external WalkerLib;
function QueryWorkingSet(uProcessId: ULONG; pv: PVOID; cb: ULONG): BOOL; stdcall; external WalkerLib;
function GetMappedFileNameA(uProcessId: ULONG; lpv: LPVOID; lpFilename: LPTSTR; nSize: ULONG): BOOL;
  stdcall; external WalkerLib;
function GetMappedFileNameW(uProcessId: ULONG; lpv: LPVOID; lpFilename: LPWSTR; nSize: ULONG): BOOL;
  stdcall; external WalkerLib;

implementation

end.
