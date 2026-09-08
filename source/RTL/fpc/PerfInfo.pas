unit PerfInfo;

interface

{$MODE ObjFPC}
{$H+}

uses
  Windows, SysUtils, PWUtils;

procedure InitializeCpuCounters();
procedure CollectCPUData();
function GetCPUCount(): integer;
function GetCPUUsage(Index: integer): double;
function GetTotalCPUUsage(): double;
procedure ReleaseCpuCounters();
function CpuCountersInitialized(): boolean;

implementation

type
  PDH_HQUERY   = NativeUInt;
  PDH_HCOUNTER = NativeUInt;
  PDH_STATUS   = DWORD;

const
  PDHDLL = 'pdh.dll';

  PDH_CSTATUS_VALID_DATA = DWORD($00000000);
  PDH_CSTATUS_NEW_DATA   = DWORD($00000001);
  PDH_MORE_DATA          = DWORD($800007D2);
  PDH_NO_DATA            = DWORD($800007D5);

  PDH_FMT_DOUBLE   = $00000200;
  PDH_FMT_NOCAP100 = $00008000;

type
  PDH_FMT_COUNTERVALUE = record
    CStatus: DWORD;
    case integer of
      0: (longValue: longint);
      1: (doubleValue: double);
      2: (largeValue: int64);
      3: (AnsiStringValue: PAnsiChar);
      4: (WideStringValue: PWideChar);
  end;
  PPDH_FMT_COUNTERVALUE = ^PDH_FMT_COUNTERVALUE;

  PDH_FMT_COUNTERVALUE_ITEM_W = record
    szName: LPWSTR;
    FmtValue: PDH_FMT_COUNTERVALUE;
  end;
  PPDH_FMT_COUNTERVALUE_ITEM_W = ^PDH_FMT_COUNTERVALUE_ITEM_W;

function PdhOpenQueryW(szDataSource: LPCWSTR; dwUserData: PtrUInt;
  var phQuery: PDH_HQUERY): PDH_STATUS; stdcall; external PDHDLL name 'PdhOpenQueryW';

function PdhAddEnglishCounterW(hQuery: PDH_HQUERY; szFullCounterPath: LPCWSTR;
  dwUserData: PtrUInt; var phCounter: PDH_HCOUNTER): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhAddEnglishCounterW';

function PdhAddCounterW(hQuery: PDH_HQUERY; szFullCounterPath: LPCWSTR;
  dwUserData: PtrUInt; var phCounter: PDH_HCOUNTER): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhAddCounterW';

function PdhCollectQueryData(hQuery: PDH_HQUERY): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhCollectQueryData';

function PdhGetFormattedCounterValue(hCounter: PDH_HCOUNTER; dwFormat: DWORD;
  lpdwType: PDWORD; var pValue: PDH_FMT_COUNTERVALUE): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhGetFormattedCounterValue';

function PdhGetFormattedCounterArrayW(hCounter: PDH_HCOUNTER; dwFormat: DWORD;
  var lpdwBufferSize: DWORD; var lpdwItemCount: DWORD;
  ItemBuffer: PPDH_FMT_COUNTERVALUE_ITEM_W): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhGetFormattedCounterArrayW';

function PdhRemoveCounter(hCounter: PDH_HCOUNTER): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhRemoveCounter';

function PdhCloseQuery(hQuery: PDH_HQUERY): PDH_STATUS; stdcall;
  external PDHDLL name 'PdhCloseQuery';

{ ===================== module state ===================== }

var
  QueryHandle: PDH_HQUERY = 0;
  CounterTotal: PDH_HCOUNTER = 0;
  CounterPerCore: PDH_HCOUNTER = 0;
  Initialized: boolean = False;

  PerCoreValues: array of double;
  PerCoreValid: array of boolean;
  CoreCount: integer = 0;
  TotalValue: double = 0.0;
  TotalValid: boolean = False;

{ ===================== helpers ===================== }

function CpuCountersInitialized(): boolean;
begin
  Result := Initialized;
end;

procedure ReleaseCpuCounters();
begin
  if CounterTotal <> 0 then
  begin
    PdhRemoveCounter(CounterTotal);
    CounterTotal := 0;
  end;
  if CounterPerCore <> 0 then
  begin
    PdhRemoveCounter(CounterPerCore);
    CounterPerCore := 0;
  end;
  if QueryHandle <> 0 then
  begin
    PdhCloseQuery(QueryHandle);
    QueryHandle := 0;
  end;
  SetLength(PerCoreValues, 0);
  SetLength(PerCoreValid, 0);
  CoreCount := 0;
  TotalValue := 0.0;
  TotalValid := False;
  Initialized := False;
end;

procedure InitializeCpuCounters();
var
  Status: PDH_STATUS;
begin
  ReleaseCpuCounters();

  Status := PdhOpenQueryW(nil, 0, QueryHandle);
  if Status <> ERROR_SUCCESS then
  begin
    QueryHandle := 0;
    Exit;
  end;

  Status := PdhAddEnglishCounterW(QueryHandle, '\Processor(_Total)\% Processor Time', 0, CounterTotal);
  if Status <> ERROR_SUCCESS then
  begin
    Status := PdhAddCounterW(QueryHandle, '\Processor(_Total)\% Processor Time', 0, CounterTotal);
    if Status <> ERROR_SUCCESS then
    begin
      PdhCloseQuery(QueryHandle);
      QueryHandle := 0;
      CounterTotal := 0;
      Exit;
    end;
  end;

  Status := PdhAddEnglishCounterW(QueryHandle, '\Processor(*)\% Processor Time', 0, CounterPerCore);
  if Status <> ERROR_SUCCESS then
    Status := PdhAddCounterW(QueryHandle, '\Processor(*)\% Processor Time', 0, CounterPerCore);
  if Status <> ERROR_SUCCESS then
  begin
    PdhRemoveCounter(CounterTotal);
    PdhCloseQuery(QueryHandle);
    QueryHandle := 0;
    CounterTotal := 0;
    CounterPerCore := 0;
    Exit;
  end;

  PdhCollectQueryData(QueryHandle);
  Initialized := True;
end;

procedure CollectCPUData();
var
  Status: PDH_STATUS;
  Value: PDH_FMT_COUNTERVALUE;
  BufferSize, ItemCount: DWORD;
  Buffer: PPDH_FMT_COUNTERVALUE_ITEM_W;
  Items: array of PDH_FMT_COUNTERVALUE_ITEM_W;
  i, Idx, MaxIdx: integer;
  NameStr: string;
begin
  TotalValid := False;
  if not Initialized then
    Exit;

  Status := PdhCollectQueryData(QueryHandle);
  if Status <> ERROR_SUCCESS then
    Exit;

  FillChar(Value, SizeOf(Value), 0);
  Status := PdhGetFormattedCounterValue(CounterTotal, PDH_FMT_DOUBLE, nil, Value);
  if (Status = ERROR_SUCCESS) and (Value.CStatus = PDH_CSTATUS_VALID_DATA) then
  begin
    TotalValue := Value.doubleValue;
    TotalValid := True;
  end;

  BufferSize := 0;
  ItemCount := 0;
  Status := PdhGetFormattedCounterArrayW(CounterPerCore, PDH_FMT_DOUBLE, BufferSize, ItemCount, nil);
  if (Status <> PDH_MORE_DATA) or (BufferSize = 0) then
    Exit;

  Buffer := PPDH_FMT_COUNTERVALUE_ITEM_W(GetMem(BufferSize));
  try
    Status := PdhGetFormattedCounterArrayW(CounterPerCore, PDH_FMT_DOUBLE, BufferSize, ItemCount, Buffer);
    if Status <> ERROR_SUCCESS then
      Exit;

    Initialize(Items);
    SetLength(Items, ItemCount);
    Move(Buffer^, Items[0], ItemCount * SizeOf(PDH_FMT_COUNTERVALUE_ITEM_W));

    MaxIdx := -1;
    for i := 0 to ItemCount - 1 do
    begin
      NameStr := UnicodeToString(Items[i].szName);
      if NameStr = '_Total' then
        Continue;
      Idx := StrToIntDef(NameStr, -1);
      if Idx > MaxIdx then
        MaxIdx := Idx;
    end;

    if MaxIdx < 0 then
      Exit;

    if Length(PerCoreValues) <> MaxIdx + 1 then
    begin
      SetLength(PerCoreValues, MaxIdx + 1);
      SetLength(PerCoreValid, MaxIdx + 1);
    end;
    for i := 0 to High(PerCoreValid) do
      PerCoreValid[i] := False;

    for i := 0 to ItemCount - 1 do
    begin
      NameStr := UnicodeToString(Items[i].szName);
      if NameStr = '_Total' then
        Continue;
      Idx := StrToIntDef(NameStr, -1);
      if (Idx < 0) or (Idx > MaxIdx) then
        Continue;
      if Items[i].FmtValue.CStatus = PDH_CSTATUS_VALID_DATA then
      begin
        PerCoreValues[Idx] := Items[i].FmtValue.doubleValue;
        PerCoreValid[Idx] := True;
      end;
    end;

    CoreCount := MaxIdx + 1;
  finally
    FreeMem(Buffer);
  end;
end;

function GetCPUCount(): integer;
begin
  Result := CoreCount;
end;

function GetCPUUsage(Index: integer): double;
begin
  Result := 0.0;
  if (Index < 0) or (Index >= Length(PerCoreValues)) then
    Exit;
  if not PerCoreValid[Index] then
    Exit;
  Result := PerCoreValues[Index] / 100.0; // keep 0..1 range, like the original GetCPUUsage
  if Result < 0 then
    Result := 0
  else if Result > 1 then
    Result := 1;
end;

function GetTotalCPUUsage(): double;
begin
  Result := 0.0;
  if not TotalValid then
    Exit;
  Result := TotalValue / 100.0; // original also returned 0..1, caller does *100.0
  if Result < 0 then
    Result := 0
  else if Result > 1 then
    Result := 1;
end;

end.
