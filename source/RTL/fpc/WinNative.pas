unit WinNative;

interface

{$MODE ObjFPC}

uses
  Windows;

type
  CCHAR = shortint;
  UCHAR = byte;
  USHORT = word;
  ULONG = longword;
  LONG = longint;

  { Pointer-sized types }
  ULONG_PTR = nativeuint;
  LONG_PTR = nativeint;
  SIZE_T = nativeuint;
  SSIZE_T = nativeint;
  UINT_PTR = nativeuint;
  INT_PTR = nativeint;

  { NT kernel types }
  KPRIORITY = LONG;
  KAFFINITY = ULONG_PTR;

  { Handles / pointers }
  PVOID = Pointer;
  PPVOID = ^PVOID;
  LPVOID = Pointer;

  { Pointer types }
  PULONG = ^ULONG;
  PLONG = ^LONG;
  PUCHAR = ^UCHAR;
  PUSHORT = ^USHORT;
  PKAFFINITY = ^KAFFINITY;
  PSIZE_T = ^SIZE_T;

  { Const pointer types }
  PCUCHAR = ^UCHAR;
  PCUSHORT = ^USHORT;
  PCULONG = ^ULONG;

  { Strings }
  PSTR = pansichar;
  PCSTR = pansichar;
  PWSTR = pwidechar;
  PCWSTR = pwidechar;

  PPSTR = ^PSTR;
  PPWSTR = ^PWSTR;

  { 64-bit integer types }
  ULONG64 = uint64;
  DWORD64 = uint64;
  DWORDLONG = uint64;

  PDWORD64 = ^DWORD64;

  { Other NT types }
  DEVICE_TYPE = ULONG;
  POBJECT = Pointer;

  { Spin lock }
  KSPIN_LOCK = ULONG_PTR;

  { NTSTATUS }
  NTSTATUS = LONG;

  { Security descriptor }
  PISECURITY_DESCRIPTOR = ^SECURITY_DESCRIPTOR;

  { Large integer }
  PLARGE_INTEGER = ^LARGE_INTEGER;

const
  NtCurrentProcess = DWORD(-1);
  NtCurrentThread = DWORD(-2);

  ntdll = 'ntdll.dll';
  STATUS_SUCCESS = $00000000;
  DUPLICATE_SAME_ATTRIBUTES = $00000003;

  {NtSuspendProcess, NtResumeProcess NtOpenProcess flag}
  PROCESS_SUSPEND_RESUME = $0800;

const
  OBJ_INHERIT = $00000002;
  OBJ_PERMANENT = $00000010;
  OBJ_EXCLUSIVE = $00000020;
  OBJ_CASE_INSENSITIVE = $00000040;
  OBJ_OPENIF = $00000080;
  OBJ_OPENLINK = $00000100;
  OBJ_KERNEL_HANDLE = $00000200;
  OBJ_FORCE_ACCESS_CHECK = $00000400;
  OBJ_IGNORE_IMPERSONATED_DEVICEMAP = $00000800;

type
  PROCESSINFOCLASS = (
    ProcessBasicInformation = 0,
    ProcessQuotaLimits,
    ProcessIoCounters,
    ProcessVmCounters,
    ProcessTimes,
    ProcessBasePriority,
    ProcessRaisePriority,
    ProcessDebugPort,
    ProcessExceptionPort,
    ProcessAccessToken,
    ProcessLdtInformation,
    ProcessLdtSize,
    ProcessDefaultHardErrorMode,
    ProcessIoPortHandlers,
    ProcessPooledUsageAndLimits,
    ProcessWorkingSetWatch,
    ProcessUserModeIOPL,
    ProcessEnableAlignmentFaultFixup,
    ProcessPriorityClass,
    ProcessWx86Information,
    ProcessHandleCount,
    ProcessAffinityMask,
    ProcessPriorityBoost,
    ProcessDeviceMap,
    ProcessSessionInformation,
    ProcessForegroundInformation,
    ProcessWow64Information,
    ProcessImageFileName,
    ProcessLUIDDeviceMapsEnabled,
    ProcessBreakOnTermination,
    ProcessDebugObjectHandle,
    ProcessDebugFlags,
    ProcessHandleTracing,
    ProcessIoPriority,
    ProcessExecuteFlags,
    ProcessTlsInformation,
    ProcessCookie,
    ProcessImageInformation,
    ProcessCycleTime,
    ProcessPagePriority,
    ProcessInstrumentationCallback,
    ProcessThreadStackAllocation,
    ProcessWorkingSetWatchEx,
    ProcessImageFileNameWin32,
    ProcessImageFileMapping,
    ProcessAffinityUpdateMode,
    ProcessMemoryAllocationMode,
    ProcessGroupInformation,
    ProcessTokenVirtualizationEnabled,
    ProcessConsoleHostProcess,
    ProcessWindowInformation,
    ProcessHandleInformation,
    ProcessMitigationPolicy,
    ProcessDynamicFunctionTableInformation,
    ProcessHandleCheckingMode,
    ProcessKeepAliveCount,
    ProcessRevokeFileHandles,
    ProcessWorkingSetControl,
    ProcessHandleTable,
    ProcessCheckStackExtentsMode,
    ProcessCommandLineInformation,
    ProcessProtectionInformation,
    ProcessMemoryExhaustion,
    ProcessFaultInformation,
    ProcessTelemetryIdInformation,
    ProcessCommitReleaseInformation,
    ProcessDefaultCpuSetsInformation,
    ProcessAllowedCpuSetsInformation,
    ProcessSubsystemProcess,
    ProcessJobMemoryInformation,
    ProcessInPrivate,
    ProcessRaiseUMExceptionOnInvalidHandleClose,
    ProcessIumChallengeResponse,
    ProcessChildProcessInformation,
    ProcessHighGraphicsPriorityInformation,
    ProcessSubsystemInformation,
    ProcessEnergyValues,
    ProcessActivityThrottleState,
    ProcessActivityThrottlePolicy,
    ProcessWin32kSyscallFilterInformation,
    ProcessDisableSystemAllowedCpuSets,
    ProcessWakeInformation,
    ProcessEnergyTrackingState,
    ProcessManageWritesToExecutableMemory,
    ProcessCaptureTrustletLiveDump,
    ProcessTelemetryCoverage,
    ProcessEnclaveInformation,
    ProcessEnableReadWriteVmLogging,
    ProcessUptimeInformation,
    ProcessImageSection,
    ProcessDebugAuthInformation,
    ProcessSystemResourceManagement,
    ProcessSequenceNumber,
    ProcessLoaderDetour,
    ProcessSecurityDomainInformation,
    ProcessCombineSecurityDomainsInformation,
    ProcessEnableLogging,
    ProcessLeapSecondInformation,
    ProcessFiberShadowStackAllocation,
    ProcessFreeFiberShadowStackAllocation,
    ProcessAltSystemCallInformation,
    ProcessDynamicEHContinuationTargets,
    ProcessDynamicEnforcedCetCompatibleRanges,
    ProcessCreateStateChange,
    ProcessApplyStateChange,
    ProcessEnableOptionalXStateFeatures,
    ProcessAltPrefetchParam,
    ProcessAssignCpuPartitions,
    ProcessPriorityClassEx,
    ProcessMembershipInformation,
    ProcessEffectiveIoPriority,
    ProcessEffectivePagePriority,
    ProcessSchedulerSharedData,
    ProcessSlistRollbackInformation,
    ProcessNetworkIoCounters,
    ProcessFindFirstThreadByTebValue,
    ProcessEnclaveAddressSpaceRestriction,
    ProcessAvailableCpus,
    MaxProcessInfoClass
    );

type
  KWAIT_REASON = (
    Executive,
    FreePage,
    PageIn,
    PoolAllocation,
    DelayExecution,
    Suspended,
    UserRequest,
    WrExecutive,
    WrFreePage,
    WrPageIn,
    WrPoolAllocation,
    WrDelayExecution,
    WrSuspended,
    WrUserRequest,
    WrEventPair,
    WrQueue,
    WrLpcReceive,
    WrLpcReply,
    WrVirtualMemory,
    WrPageOut,
    WrRendezvous,
    WrKeyedEvent,
    WrTerminated,
    WrProcessInSwap,
    WrCpuRateControl,
    WrCalloutStack,
    WrKernel,
    WrResource,
    WrPushLock,
    WrMutex,
    WrQuantumEnd,
    WrDispatchInt,
    WrPreempted,
    WrYieldExecution,
    WrFastMutex,
    WrGuardedMutex,
    WrRundown,
    WrAlertByThreadId,
    WrDeferredPreempt,
    WrPhysicalFault,
    WrIoRing,
    WrMdlCache,
    WrRcu,
    MaximumWaitReason
    );
  PKWAIT_REASON = ^KWAIT_REASON;

  _ANSI_STRING = record
    Length: word;
    MaximumLength: word;
    Buffer: pansichar;
  end;
  ANSI_STRING = _ANSI_STRING;
  PANSI_STRING = ^_ANSI_STRING;

  _UNICODE_STRING = record
    Length: word;
    MaximumLength: word;
    Buffer: pwidechar;
  end;
  UNICODE_STRING = _UNICODE_STRING;
  PUNICODE_STRING = ^_UNICODE_STRING;
  PCUNICODE_STRING = ^_UNICODE_STRING;

  _CLIENT_ID = packed record
    UniqueProcess: DWORD;
    UniqueThread: DWORD;
  end;
  CLIENT_ID = _CLIENT_ID;
  PCLIENT_ID = ^_CLIENT_ID;

  _THREAD_STATE = (
    Initialized,
    Ready,
    Running,
    Standby,
    Terminated,
    Waiting,
    Transition,
    DeferredReady,
    GateWait
    );
  THREAD_STATE = _THREAD_STATE;

  _SYSTEM_THREADS = record //for ntdll api
    KernelTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    CreateTime: LARGE_INTEGER;
    WaitTime: ULONG;
    StartAddress: pointer;
    ClientId: CLIENT_ID;
    Priority: KPRIORITY;
    BasePriority: KPRIORITY;
    ContextSwitchCount: ULONG;
    State: THREAD_STATE;
    WaitReason: integer;
  end;
  SYSTEM_THREAD_INFORMATION = _SYSTEM_THREADS;
  PSYSTEM_THREADS = ^_SYSTEM_THREADS;
  PSYSTEM_THREAD_INFORMATION = ^_SYSTEM_THREADS;

type
  _IO_COUNTERS = record
    ReadOperationCount: LARGE_INTEGER;
    WriteOperationCount: LARGE_INTEGER;
    OtherOperationCount: LARGE_INTEGER;
    ReadTransferCount: LARGE_INTEGER;
    WriteTransferCount: LARGE_INTEGER;
    OtherTransferCount: LARGE_INTEGER;
  end;
  IO_COUNTERS = _IO_COUNTERS;
  PIO_COUNTERS = ^_IO_COUNTERS;

  _VM_COUNTERS = record
    PeakVirtualSize: nativeuint;
    VirtualSize: nativeuint;
    PageFaultCount: cardinal;        // ULONG is always 32-bit, even on x64
    PeakWorkingSetSize: nativeuint;
    WorkingSetSize: nativeuint;
    QuotaPeakPagedPoolUsage: nativeuint;
    QuotaPagedPoolUsage: nativeuint;
    QuotaPeakNonPagedPoolUsage: nativeuint;
    QuotaNonPagedPoolUsage: nativeuint;
    PagefileUsage: nativeuint;
    PeakPagefileUsage: nativeuint;
  end;
  VM_COUNTERS = _VM_COUNTERS;
  PVM_COUNTERS = ^_VM_COUNTERS;

  {$IFDEF CPU32}
type
  _SYSTEM_PROCESS_INFORMATION = record
    NextEntryOffset: ULONG;
    NumberOfThreads: ULONG;
    Reserved1: array[0..5] of ULONG;
    CreateTime: LARGE_INTEGER;
    UserTime: LARGE_INTEGER;
    KernelTime: LARGE_INTEGER;
    ImageName: UNICODE_STRING;
    BasePriority: KPRIORITY;
    UniqueProcessId: ULONG;
    InheritedFromUniqueProcessId: ULONG;
    HandleCount: ULONG;
    Reserved2: array[0..1] of ULONG;
    VmCounters: VM_COUNTERS;
    PrivatePageCount: SIZE_T;
    IoCounters: IO_COUNTERS;
    Threads: array[0..0] of SYSTEM_THREAD_INFORMATION;
  end;
  {$ENDIF}

  {$IFDEF CPU64}
  type
    _SYSTEM_PROCESS_INFORMATION = record
      NextEntryOffset: ULONG;
      NumberOfThreads: ULONG;

      WorkingSetPrivateSize: LARGE_INTEGER;
      HardFaultCount: ULONG;
      NumberOfThreadsHighWatermark: ULONG;
      CycleTime: ULONGLONG;

      CreateTime: LARGE_INTEGER;
      UserTime: LARGE_INTEGER;
      KernelTime: LARGE_INTEGER;

      ImageName: UNICODE_STRING;
      BasePriority: KPRIORITY;

      UniqueProcessId: THandle;
      InheritedFromUniqueProcessId: THandle;

      HandleCount: ULONG;
      SessionId: ULONG;
      UniqueProcessKey: ULONG_PTR;

      PeakVirtualSize: SIZE_T;
      VirtualSize: SIZE_T;
      PageFaultCount: ULONG;
      PeakWorkingSetSize: SIZE_T;
      WorkingSetSize: SIZE_T;

      QuotaPeakPagedPoolUsage: SIZE_T;
      QuotaPagedPoolUsage: SIZE_T;
      QuotaPeakNonPagedPoolUsage: SIZE_T;
      QuotaNonPagedPoolUsage: SIZE_T;

      PagefileUsage: SIZE_T;
      PeakPagefileUsage: SIZE_T;

      PrivatePageCount: SIZE_T;

      ReadOperationCount: LARGE_INTEGER;
      WriteOperationCount: LARGE_INTEGER;
      OtherOperationCount: LARGE_INTEGER;

      ReadTransferCount: LARGE_INTEGER;
      WriteTransferCount: LARGE_INTEGER;
      OtherTransferCount: LARGE_INTEGER;

      Threads: array[0..0] of SYSTEM_THREAD_INFORMATION;
    end;
  {$ENDIF}
  SYSTEM_PROCESS_INFORMATION = _SYSTEM_PROCESS_INFORMATION;
  PSYSTEM_PROCESS_INFORMATION = ^_SYSTEM_PROCESS_INFORMATION;

type
  _SYSTEM_INFORMATION_CLASS = (
    SystemBasicInformation = 0,
    SystemProcessorInformation = 1,
    SystemPerformanceInformation = 2,
    SystemTimeOfDayInformation = 3,
    SystemPathInformation = 4,
    SystemProcessInformation = 5,
    SystemCallCountInformation = 6,
    SystemDeviceInformation = 7,
    SystemProcessorPerformanceInformation = 8,
    SystemFlagsInformation = 9,
    SystemCallTimeInformation = 10,
    SystemModuleInformation = 11,
    SystemLocksInformation = 12,
    SystemStackTraceInformation = 13,
    SystemPagedPoolInformation = 14,
    SystemNonPagedPoolInformation = 15,
    SystemHandleInformation = 16,
    SystemObjectInformation = 17,
    SystemPageFileInformation = 18,
    SystemVdmInstemulInformation = 19,
    SystemVdmBopInformation = 20,
    SystemFileCacheInformation = 21,
    SystemPoolTagInformation = 22,
    SystemInterruptInformation = 23,
    SystemDpcBehaviorInformation = 24,
    SystemFullMemoryInformation = 25,
    SystemLoadGdiDriverInformation = 26,
    SystemUnloadGdiDriverInformation = 27,
    SystemTimeAdjustmentInformation = 28,
    SystemSummaryMemoryInformation = 29,
    SystemMirrorMemoryInformation = 30,
    SystemPerformanceTraceInformation = 31,
    SystemObsolete0 = 32,
    SystemExceptionInformation = 33,
    SystemCrashDumpStateInformation = 34,
    SystemKernelDebuggerInformation = 35,
    SystemContextSwitchInformation = 36,
    SystemRegistryQuotaInformation = 37,
    SystemExtendServiceTableInformation = 38,
    SystemPrioritySeperation = 39,
    SystemVerifierAddDriverInformation = 40,
    SystemVerifierRemoveDriverInformation = 41,
    SystemProcessorIdleInformation = 42,
    SystemLegacyDriverInformation = 43,
    SystemCurrentTimeZoneInformation = 44,
    SystemLookasideInformation = 45,
    SystemTimeSlipNotification = 46,
    SystemSessionCreate = 47,
    SystemSessionDetach = 48,
    SystemSessionInformation = 49,
    SystemRangeStartInformation = 50,
    SystemVerifierInformation = 51,
    SystemVerifierThunkExtend = 52,
    SystemSessionProcessInformation = 53,
    SystemLoadGdiDriverInSystemSpace = 54,
    SystemNumaProcessorMap = 55,
    SystemPrefetcherInformation = 56,
    SystemExtendedProcessInformation = 57,
    SystemRecommendedSharedDataAlignment = 58,
    SystemComPlusPackage = 59,
    SystemNumaAvailableMemory = 60,
    SystemProcessorPowerInformation = 61,
    SystemEmulationBasicInformation = 62,
    SystemEmulationProcessorInformation = 63,
    SystemExtendedHandleInformation = 64,
    SystemLostDelayedWriteInformation = 65,
    SystemBigPoolInformation = 66,
    SystemSessionPoolTagInformation = 67,
    SystemSessionMappedViewInformation = 68,
    SystemHotpatchInformation = 69,
    SystemObjectSecurityMode = 70,
    SystemWatchdogTimerHandler = 71,
    SystemWatchdogTimerInformation = 72,
    SystemLogicalProcessorInformation = 73,
    SystemWow64SharedInformationObsolete = 74,
    SystemRegisterFirmwareTableInformationHandler = 75,
    SystemFirmwareTableInformation = 76,
    SystemModuleInformationEx = 77,
    SystemVerifierTriageInformation = 78,
    SystemSuperfetchInformation = 79,
    SystemMemoryListInformation = 80,
    SystemFileCacheInformationEx = 81,
    SystemThreadPriorityClientIdInformation = 82,
    SystemProcessorIdleCycleTimeInformation = 83,
    SystemVerifierCancellationInformation = 84,
    SystemProcessorPowerInformationEx = 85,
    SystemRefTraceInformation = 86,
    SystemSpecialPoolInformation = 87,
    SystemProcessIdInformation = 88,
    SystemErrorPortInformation = 89,
    SystemBootEnvironmentInformation = 90,
    SystemHypervisorInformation = 91,
    SystemVerifierInformationEx = 92,
    SystemTimeZoneInformation = 93,
    SystemImageFileExecutionOptionsInformation = 94,
    SystemCoverageInformation = 95,
    SystemPrefetchPatchInformation = 96,
    SystemVerifierFaultsInformation = 97,
    SystemSystemPartitionInformation = 98,
    SystemSystemDiskInformation = 99,
    SystemProcessorPerformanceDistribution = 100,
    SystemNumaProximityNodeInformation = 101,
    SystemDynamicTimeZoneInformation = 102,
    SystemCodeIntegrityInformation = 103,
    SystemProcessorMicrocodeUpdateInformation = 104,
    SystemProcessorBrandString = 105,
    SystemVirtualAddressInformation = 106,
    SystemLogicalProcessorAndGroupInformation = 107,
    SystemProcessorCycleTimeInformation = 108,
    SystemStoreInformation = 109,
    SystemRegistryAppendString = 110,
    SystemAitSamplingValue = 111,
    SystemVhdBootInformation = 112,
    SystemCpuQuotaInformation = 113,
    SystemNativeBasicInformation = 114,
    SystemErrorPortTimeouts = 115,
    SystemLowPriorityIoInformation = 116,
    SystemBootEntropyInformation = 117,
    SystemVerifierCountersInformation = 118,
    SystemPagedPoolInformationEx = 119,
    SystemSystemPtesInformationEx = 120,
    SystemNodeDistanceInformation = 121,
    SystemAcpiAuditInformation = 122,
    SystemBasicPerformanceInformation = 123,
    SystemQueryPerformanceCounterInformation = 124,
    SystemSessionBigPoolInformation = 125,
    SystemBootGraphicsInformation = 126,
    SystemScrubPhysicalMemoryInformation = 127,
    SystemBadPageInformation = 128,
    SystemProcessorProfileControlArea = 129,
    SystemCombinePhysicalMemoryInformation = 130,
    SystemEntropyInterruptTimingInformation = 131,
    SystemConsoleInformation = 132,
    SystemPlatformBinaryInformation = 133,
    SystemPolicyInformation = 134,
    SystemHypervisorProcessorCountInformation = 135,
    SystemDeviceDataInformation = 136,
    SystemDeviceDataEnumerationInformation = 137,
    SystemMemoryTopologyInformation = 138,
    SystemMemoryChannelInformation = 139,
    SystemBootLogoInformation = 140,
    SystemProcessorPerformanceInformationEx = 141,
    SystemSpare0 = 142,
    SystemSecureBootPolicyInformation = 143,
    SystemPageFileInformationEx = 144,
    SystemSecureBootInformation = 145,
    SystemEntropyInterruptTimingRawInformation = 146,
    SystemPortableWorkspaceEfiLauncherInformation = 147,
    SystemFullProcessInformation = 148,
    SystemKernelDebuggerInformationEx = 149,
    SystemBootMetadataInformation = 150,
    SystemSoftRebootInformation = 151,
    SystemElamCertificateInformation = 152,
    SystemOfflineDumpConfigInformation = 153,
    SystemProcessorFeaturesInformation = 154,
    SystemRegistryReconciliationInformation = 155,
    SystemEdidInformation = 156,
    SystemManufacturingInformation = 157,
    SystemEnergyEstimationConfigInformation = 158,
    SystemHypervisorDetailInformation = 159,
    SystemProcessorCycleStatsInformation = 160,
    SystemVmGenerationCountInformation = 161,
    SystemTrustedPlatformModuleInformation = 162,
    SystemKernelDebuggerFlags = 163,
    SystemCodeIntegrityPolicyInformation = 164,
    SystemIsolatedUserModeInformation = 165,
    SystemHardwareSecurityTestInterfaceResultsInformation = 166,
    SystemSingleModuleInformation = 167,
    SystemAllowedCpuSetsInformation = 168,
    SystemVsmProtectionInformation = 169, //ex SystemDmaProtectionInformation
    SystemInterruptCpuSetsInformation = 170,
    SystemSecureBootPolicyFullInformation = 171,
    SystemCodeIntegrityPolicyFullInformation = 172,
    SystemAffinitizedInterruptProcessorInformation = 173,
    SystemRootSiloInformation = 174,
    SystemCpuSetInformation = 175,
    SystemCpuSetTagInformation = 176,
    SystemWin32WerStartCallout = 177,
    SystemSecureKernelProfileInformation = 178,
    SystemCodeIntegrityPlatformManifestInformation = 179,
    SystemInterruptSteeringInformation = 180,
    SystemSupportedProcessorArchitectures = 181,
    SystemMemoryUsageInformation = 182,
    SystemCodeIntegrityCertificateInformation = 183,
    SystemPhysicalMemoryInformation = 184,
    SystemControlFlowTransition = 185,
    SystemKernelDebuggingAllowed = 186,
    SystemActivityModerationExeState = 187,
    SystemActivityModerationUserSettings = 188,
    SystemCodeIntegrityPoliciesFullInformation = 189,
    SystemCodeIntegrityUnlockInformation = 190,
    SystemIntegrityQuotaInformation = 191,
    SystemFlushInformation = 192,
    SystemProcessorIdleMaskInformation = 193,
    SystemSecureDumpEncryptionInformation = 194,
    SystemWriteConstraintInformation = 195,
    SystemKernelVaShadowInformation = 196,
    SystemHypervisorSharedPageInformation = 197,
    SystemFirmwareBootPerformanceInformation = 198,
    SystemCodeIntegrityVerificationInformation = 199,
    SystemFirmwarePartitionInformation = 200,
    SystemSpeculationControlInformation = 201,
    SystemDmaGuardPolicyInformation = 202,
    SystemEnclaveLaunchControlInformation = 203,
    SystemWorkloadAllowedCpuSetsInformation = 204,
    SystemCodeIntegrityUnlockModeInformation = 205,
    SystemLeapSecondInformation = 206,
    SystemFlags2Information = 207,
    SystemSecurityModelInformation = 208,
    SystemCodeIntegritySyntheticCacheInformation = 209,
    SystemFeatureConfigurationInformation = 210,
    SystemFeatureConfigurationSectionInformation = 211,
    SystemFeatureUsageSubscriptionInformation = 212,
    SystemSecureSpeculationControlInformation = 213,
    SystemSpacesBootInformation = 214,
    SystemFwRamdiskInformation = 215,
    SystemWheaIpmiHardwareInformation = 216,
    SystemDifSetRuleClassInformation = 217,
    SystemDifClearRuleClassInformation = 218,
    SystemDifApplyPluginVerificationOnDriver = 219,
    SystemDifRemovePluginVerificationOnDriver = 220,
    SystemShadowStackInformation = 221,
    SystemBuildVersionInformation = 222,
    SystemPoolLimitInformation = 223,
    SystemCodeIntegrityAddDynamicStore = 224,
    SystemCodeIntegrityClearDynamicStores = 225,
    SystemDifPoolTrackingInformation = 226,
    SystemPoolZeroingInformation = 227,
    SystemDpcWatchdogInformation = 228,
    SystemDpcWatchdogInformation2 = 229,
    SystemSupportedProcessorArchitectures2 = 230,
    SystemSingleProcessorRelationshipInformation = 231,
    SystemXfgCheckFailureInformation = 232,
    MaxSystemInfoClass);
  SYSTEM_INFORMATION_CLASS = _SYSTEM_INFORMATION_CLASS;
  PSYSTEM_INFORMATION_CLASS = ^_SYSTEM_INFORMATION_CLASS;

type
  THREADINFOCLASS = (
    ThreadBasicInformation,
    ThreadTimes,
    ThreadPriority,
    ThreadBasePriority,
    ThreadAffinityMask,
    ThreadImpersonationToken,
    ThreadDescriptorTableEntry,
    ThreadEnableAlignmentFaultFixup,
    ThreadEventPair,
    ThreadQuerySetWin32StartAddress,
    ThreadZeroTlsCell,
    ThreadPerformanceCount,
    ThreadAmILastThread,
    ThreadIdealProcessor,
    ThreadPriorityBoost,
    ThreadSetTlsArrayAddress,
    ThreadIsIoPending,
    ThreadHideFromDebugger,
    ThreadBreakOnTermination,
    ThreadSwitchLegacyState,
    ThreadIsTerminated,
    ThreadLastSystemCall,
    ThreadIoPriority,
    ThreadCycleTime,
    ThreadPagePriority,
    ThreadActualBasePriority,
    ThreadTebInformation,
    ThreadCSwitchMon,
    ThreadCSwitchPmu,
    ThreadWow64Context,
    ThreadGroupInformation,
    ThreadUmsInformation,
    ThreadCounterProfiling,
    ThreadIdealProcessorEx,
    ThreadCpuAccountingInformation,
    ThreadSuspendCount,
    ThreadHeterogeneousCpuPolicy,
    ThreadContainerId,
    ThreadNameInformation,
    ThreadSelectedCpuSets,
    ThreadSystemThreadInformation,
    ThreadActualGroupAffinity,
    ThreadDynamicCodePolicyInfo,
    ThreadExplicitCaseSensitivity,
    ThreadWorkOnBehalfTicket,
    ThreadSubsystemInformation,
    ThreadDbgkWerReportActive,
    ThreadAttachContainer,
    ThreadManageWritesToExecutableMemory,
    ThreadPowerThrottlingState,
    ThreadWorkloadClass,
    ThreadCreateStateChange,
    ThreadApplyStateChange,
    ThreadStrongerBadHandleChecks,
    ThreadEffectiveIoPriority,
    ThreadEffectivePagePriority,
    ThreadUpdateLockOwnership,
    ThreadSchedulerSharedDataSlot,
    ThreadTebInformationAtomic,
    ThreadIndexInformation,
    MaxThreadInfoClass
    );

type
  _SYSTEM_PAGEFILE_INFORMATION = record
    NextEntryOffset: ULONG;
    CurrentSize: ULONG;
    TotalUsed: ULONG;
    PeakUsed: ULONG;
    FileName: UNICODE_STRING;
  end;
  SYSTEM_PAGEFILE_INFORMATION = _SYSTEM_PAGEFILE_INFORMATION;
  PSYSTEM_PAGEFILE_INFORMATION = ^_SYSTEM_PAGEFILE_INFORMATION;

  _SYSTEM_HANDLE_TABLE_ENTRY_INFO = record
    UniqueProcessId: USHORT;
    CreatorBackTraceIndex: USHORT;
    ObjectTypeIndex: UCHAR;
    HandleAttributes: UCHAR;
    HandleValue: USHORT;
    _Object: PVOID;
    GrantedAccess: ACCESS_MASK;
  end;
  SYSTEM_HANDLE_TABLE_ENTRY_INFO = _SYSTEM_HANDLE_TABLE_ENTRY_INFO;
  PSYSTEM_HANDLE_TABLE_ENTRY_INFO = ^_SYSTEM_HANDLE_TABLE_ENTRY_INFO;

  _SYSTEM_HANDLE_INFORMATION = record
    NumberOfHandles: ULONG;
    Handles: array[0..0] of SYSTEM_HANDLE_TABLE_ENTRY_INFO;
  end;
  SYSTEM_HANDLE_INFORMATION = _SYSTEM_HANDLE_INFORMATION;
  PSYSTEM_HANDLE_INFORMATION = ^_SYSTEM_HANDLE_INFORMATION;

  _OBJECT_INFORMATION_CLASS = (
    ObjectBasicInformation,
    ObjectNameInformation,
    ObjectTypeInformation,
    ObjectAllTypesInformation,
    ObjectHandleInformation
    );
  OBJECT_INFORMATION_CLASS = _OBJECT_INFORMATION_CLASS;
  POBJECT_INFORMATION_CLASS = ^OBJECT_INFORMATION_CLASS;

  _OBJECT_NAME_INFORMATION = record
    Name: UNICODE_STRING;
  end;
  OBJECT_NAME_INFORMATION = _OBJECT_NAME_INFORMATION;
  POBJECT_NAME_INFORMATION = ^_OBJECT_NAME_INFORMATION;

  OBJECT_BASIC_INFORMATION = record
    Attributes: ULONG;
    GrantedAccess: ACCESS_MASK;
    HandleCount: ULONG;
    PointerCount: ULONG;
    PagedPoolCharge: ULONG;
    NonPagedPoolCharge: ULONG;
    Reserved: array[0..2] of ULONG;
    NameInfoSize: ULONG;
    TypeInfoSize: ULONG;
    SecurityDescriptorSize: ULONG;
    CreationTime: LARGE_INTEGER;
  end;
  POBJECT_BASIC_INFORMATION = ^OBJECT_BASIC_INFORMATION;

  _POOL_TYPE = (
    NonPagedPool = 0,
    PagedPool = 1,
    NonPagedPoolMustSucceed = 2,
    DontUseThisType = 3,
    NonPagedPoolCacheAligned = 4,
    PagedPoolCacheAligned = 5,
    NonPagedPoolCacheAlignedMustS = 6,
    NonPagedPoolSession = 32,
    PagedPoolSession = 33,
    NonPagedPoolMustSucceedSession = 34,
    DontUseThisTypeSession = 35,
    NonPagedPoolCacheAlignedSession = 36,
    PagedPoolCacheAlignedSession = 37,
    NonPagedPoolCacheAlignedMustSSession = 38,
    NonPagedPoolNx = 512,
    PagedPoolNx = 513,
    NonPagedPoolNxCacheAligned = 516,
    PagedPoolNxCacheAligned = 517,
    NonPagedPoolSessionNx = 544,
    PagedPoolSessionNx = 545,
    NonPagedPoolNxCacheAlignedSession = 548,
    PagedPoolNxCacheAlignedSession = 549,
    NonPagedPoolBase = 0,
    NonPagedPoolBaseMustSucceed = 2,
    NonPagedPoolBaseCacheAligned = 4,
    NonPagedPoolBaseCacheAlignedMustS = 6,
    NonPagedPoolBaseSession = 32,
    NonPagedPoolBaseMustSucceedSession = 34,
    NonPagedPoolBaseCacheAlignedSession = 36,
    NonPagedPoolBaseCacheAlignedMustSSession = 38,
    NonPagedPoolBaseNx = 512,
    NonPagedPoolBaseNxCacheAligned = 516,
    NonPagedPoolBaseSessionNx = 544,
    NonPagedPoolBaseNxCacheAlignedSession = 548,
    MaxPoolType = 512
    );
  POOL_TYPE = _POOL_TYPE;
  PPOOL_TYPE = ^POOL_TYPE;

  _RTL_PROCESS_MODULE_INFORMATION = record
    Section: THANDLE;
    MappedBase: PVOID;
    ImageBase: PVOID;
    ImageSize: ULONG;
    Flags: ULONG;
    LoadOrderIndex: USHORT;
    InitOrderIndex: USHORT;
    LoadCount: USHORT;
    OffsetToFileName: USHORT;
    FullPathName: array[0..255] of UCHAR;
  end;
  RTL_PROCESS_MODULE_INFORMATION = _RTL_PROCESS_MODULE_INFORMATION;
  PRTL_PROCESS_MODULE_INFORMATION = ^_RTL_PROCESS_MODULE_INFORMATION;

  _RTL_PROCESS_MODULES = record
    NumberOfModules: ULONG;
    Modules: array[0..0] of RTL_PROCESS_MODULE_INFORMATION;
  end;
  RTL_PROCESS_MODULES = _RTL_PROCESS_MODULES;
  PRTL_PROCESS_MODULES = ^_RTL_PROCESS_MODULES;

  _OBJECT_TYPE_INFORMATION = record
    Name: UNICODE_STRING;
    ObjectCount: ULONG;
    HandleCount: ULONG;
    TotalPagedPoolUsage: ULONG;
    TotalNonPagedPoolUsage: ULONG;
    TotalNamePoolUsage: ULONG;
    TotalHandleTableUsage: ULONG;
    HighWaterNumberOfObjects: ULONG;
    HighWaterNumberOfHandles: ULONG;

    HighWaterPagedPoolUsage: ULONG;
    HighWaterNonPagedPoolUsage: ULONG;
    HighWaterNamePoolUsage: ULONG;
    HighWaterHandleTableUsage: ULONG;

    InvalidAttributes: ULONG;
    GenericMapping: GENERIC_MAPPING;
    ValidAccessMask: ACCESS_MASK;
    SecurityRequired: boolean;
    MaintainHandleCount: boolean;
    TypeIndex: UCHAR;
    ReservedByte: UCHAR;
    PoolType: POOL_TYPE;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
  end;
  OBJECT_TYPE_INFORMATION = _OBJECT_TYPE_INFORMATION;
  POBJECT_TYPE_INFORMATION = ^_OBJECT_TYPE_INFORMATION;

  _SYSTEM_PERFORMANCE_INFORMATION = record //Information Class 2
    IdleTime: LARGE_INTEGER;
    ReadTransferCount: LARGE_INTEGER;
    WriteTransferCount: LARGE_INTEGER;
    OtherTransferCount: LARGE_INTEGER;
    ReadOperationCount: ULONG;
    WriteOperationCount: ULONG;
    OtherOperationCount: ULONG;
    AvailablePages: ULONG;
    TotalCommittedPages: ULONG;
    TotalCommitLimit: ULONG;
    PeakCommitment: ULONG;
    PageFaults: ULONG;
    WriteCopyFaults: ULONG;
    TransitionFaults: ULONG;
    Reserved1: ULONG;
    DemandZeroFaults: ULONG;
    PagesRead: ULONG;
    PageReadIos: ULONG;
    Reserved2: array[0..1] of ULONG;
    PagefilePagesWritten: ULONG;
    PagefilePageWriteIos: ULONG;
    MappedFilePagesWritten: ULONG;
    MappedFilePageWriteIos: ULONG;
    PagedPoolUsage: ULONG;
    NonPagedPoolUsage: ULONG;
    PagedPoolAllocs: ULONG;
    PagedPoolFrees: ULONG;
    NonPagedPoolAllocs: ULONG;
    NonPagedPoolFrees: ULONG;
    TotalFreeSystemPtes: ULONG;
    SystemCodePage: ULONG;
    TotalSystemDriverPages: ULONG;
    TotalSystemCodePages: ULONG;
    SmallNonPagedLookasideListAllocateHits: ULONG;
    SmallPagedLookasideListAllocateHits: ULONG;
    Reserved3: ULONG;
    MmSystemCachePage: ULONG;
    PagedPoolPage: ULONG;
    SystemDriverPage: ULONG;
    FastReadNoWait: ULONG;
    FastReadWait: ULONG;
    FastReadResourceMiss: ULONG;
    FastReadNotPossible: ULONG;
    FastMdlReadNoWait: ULONG;
    FastMdlReadWait: ULONG;
    FastMdlReadResourceMiss: ULONG;
    FastMdlReadNotPossible: ULONG;
    MapDataNoWait: ULONG;
    MapDataWait: ULONG;
    MapDataNoWaitMiss: ULONG;
    MapDataWaitMiss: ULONG;
    PinMappedDataCount: ULONG;
    PinReadNoWait: ULONG;
    PinReadWait: ULONG;
    PinReadNoWaitMiss: ULONG;
    PinReadWaitMiss: ULONG;
    CopyReadNoWait: ULONG;
    CopyReadWait: ULONG;
    CopyReadNoWaitMiss: ULONG;
    CopyReadWaitMiss: ULONG;
    MdlReadNoWait: ULONG;
    MdlReadWait: ULONG;
    MdlReadNoWaitMiss: ULONG;
    MdlReadWaitMiss: ULONG;
    ReadAheadIos: ULONG;
    LazyWriteIos: ULONG;
    LazyWritePages: ULONG;
    DataFlushes: ULONG;
    DataPages: ULONG;
    ContextSwitches: ULONG;
    FirstLevelTbFills: ULONG;
    SecondLevelTbFills: ULONG;
    SystemCalls: ULONG;
  end;
  SYSTEM_PERFORMANCE_INFORMATION = _SYSTEM_PERFORMANCE_INFORMATION;
  PSYSTEM_PERFORMANCE_INFORMATION = ^_SYSTEM_PERFORMANCE_INFORMATION;

  _SYSTEM_BASIC_INFORMATION = record
    Unknown: ULONG;
    MaximumIncrement: ULONG;
    PhysicalPageSize: ULONG;
    NumberOfPhysicalPages: ULONG;
    LowestPhysicalPage: ULONG;
    HighestPhysicalPage: ULONG;
    AllocationGranularity: ULONG;
    LowestUserAddress: ULONG;
    HighestUserAddress: ULONG;
    ActiveProcessors: ULONG;
    NumberProcessors: UCHAR;
  end;
  SYSTEM_BASIC_INFORMATION = _SYSTEM_BASIC_INFORMATION;
  PSYSTEM_BASIC_INFORMATION = ^_SYSTEM_BASIC_INFORMATION;

  _PROCESS_BASIC_INFORMATION = record
    ExitStatus: NTSTATUS;
    PebBaseAddress: PVOID; //PEB struct address
    AffinityMask: KAFFINITY;
    BasePriority: KPRIORITY;
    UniqueProcessId: ULONG;
    InheritedFromUniqueProcessId: ULONG;
  end;
  PROCESS_BASIC_INFORMATION = _PROCESS_BASIC_INFORMATION;
  PPROCESS_BASIC_INFORMATION = ^_PROCESS_BASIC_INFORMATION;

  _THREAD_BASIC_INFORMATION = record
    ExitStatus: NTSTATUS;
    TebBaseAddress: PVOID;
    ClientId: CLIENT_ID;
    AffinityMask: KAFFINITY;
    Priority: KPRIORITY;
    BasePriority: KPRIORITY;
  end;
  THREAD_BASIC_INFORMATION = _THREAD_BASIC_INFORMATION;
  PTHREAD_BASIC_INFORMATION = ^_THREAD_BASIC_INFORMATION;

type
  _PROCESS_HANDLE_TABLE_ENTRY_INFO = record
    HandleValue: HANDLE;
    HandleCount: ULONG_PTR;
    PointerCount: ULONG_PTR;
    GrantedAccess: ULONG;
    ObjectTypeIndex: ULONG;
    HandleAttributes: ULONG;
    Reserved: ULONG;
  end;
  PROCESS_HANDLE_TABLE_ENTRY_INFO = _PROCESS_HANDLE_TABLE_ENTRY_INFO;
  PPROCESS_HANDLE_TABLE_ENTRY_INFO = ^_PROCESS_HANDLE_TABLE_ENTRY_INFO;

  _PROCESS_HANDLE_SNAPSHOT_INFORMATION = record
    NumberOfHandles: ULONG_PTR;
    Reserved: ULONG_PTR;
    Handles: array[0..0] of PROCESS_HANDLE_TABLE_ENTRY_INFO;
  end;
  PROCESS_HANDLE_SNAPSHOT_INFORMATION = _PROCESS_HANDLE_SNAPSHOT_INFORMATION;
  PPROCESS_HANDLE_SNAPSHOT_INFORMATION = ^_PROCESS_HANDLE_SNAPSHOT_INFORMATION;

function NtQueryInformationProcess(
  {IN}ProcessHandle: THANDLE;
  {IN}ProcessInformationClass: PROCESSINFOCLASS;
  {OUT}ProcessInformation: Pointer;
  {IN}ProcessInformationLength: ULONG;
  {OUT}ReturnLength: Pointer): NTSTATUS; stdcall; external ntdll;

function NtQueryInformationThread(
  {IN}ThreadHandle: THANDLE;
  {IN}ThreadInformationClass: THREADINFOCLASS;
  {OUT}ThreadInformation: Pointer;
  {IN}ThreadInformationLength: ULONG;
  {OUT}var ReturnLength: ULONG): NTSTATUS; stdcall; external ntdll;

function NtSuspendProcess(
  {IN}ProcessHandle: THandle): NTSTATUS; stdcall; external ntdll;

function NtResumeProcess(
  {IN}ProcessHandle: THandle): NTSTATUS; stdcall; external ntdll;

function RtlCompareUnicodeString(
  {IN} String1: PUNICODE_STRING;
  {IN} String2: PUNICODE_STRING;
  {IN} CaseInSensitive: boolean): LONG; stdcall; external ntdll;

function RtlEqualUnicodeString(
  {IN} String1: PUNICODE_STRING;
  {IN} String2: PUNICODE_STRING;
  {IN} CaseInSensitive: boolean): boolean; stdcall; external ntdll;

function NT_SUCCESS(Status: NTSTATUS): boolean; register;

implementation

function NT_SUCCESS(Status: NTSTATUS): boolean; register;
begin
  Result := Status >= 0;
end;

end.
