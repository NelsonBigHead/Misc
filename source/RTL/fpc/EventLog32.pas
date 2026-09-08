{
  Windows Event Log Unit

  version:: 004 <-increment this if changes has global effect

  Revision History

  001: 24.06.04 First release
  002: 04.05.05 Added EventLog32EventCategory, EventLog32GetText (category parameter)
  003: 30.05.05 Fixes
  004: 27.08.26 Complete rewrite to EVT
}

unit EventLog32;

{$MODE ObjFPC}
{$H+}

interface

uses
  Windows, SysUtils, Classes, RtlTypes, PWUtils;

const
  wevtapi = 'wevtapi.dll';

  // EvtQuery flags
  EvtQueryChannelPath      = $1;
  EvtQueryFilePath         = $2;
  EvtQueryForwardDirection = $100;
  EvtQueryReverseDirection = $200;

  // EvtOpenLog flags
  EvtOpenChannelPath = $1;
  EvtOpenFilePath     = $2;

  // EvtRender flags
  EvtRenderEventValues = 0;
  EvtRenderEventXml    = 1;

  // EvtCreateRenderContext flags
  EvtRenderContextValues = 0;
  EvtRenderContextSystem = 1;
  EvtRenderContextUser   = 2;

  // EVT_SYSTEM_PROPERTY_ID - fixed order returned by EvtRenderContextSystem
  EvtSystemProviderName      = 0;
  EvtSystemProviderGuid      = 1;
  EvtSystemEventID           = 2;
  EvtSystemQualifiers        = 3;
  EvtSystemLevel             = 4;
  EvtSystemTask              = 5;
  EvtSystemOpcode            = 6;
  EvtSystemKeywords          = 7;
  EvtSystemTimeCreated       = 8;
  EvtSystemEventRecordId     = 9;
  EvtSystemActivityID        = 10;
  EvtSystemRelatedActivityID = 11;
  EvtSystemProcessID         = 12;
  EvtSystemThreadID          = 13;
  EvtSystemChannel           = 14;
  EvtSystemComputer          = 15;
  EvtSystemUserID            = 16;
  EvtSystemVersion           = 17;
  EvtSystemPropertyIdEnd     = 18;

  // EVT_VARIANT_TYPE (low byte of VarType)
  EvtVarTypeNull     = 0;
  EvtVarTypeString   = 1;
  EvtVarTypeByte     = 4;
  EvtVarTypeUInt16   = 6;
  EvtVarTypeUInt32   = 8;
  EvtVarTypeUInt64   = 10;
  EvtVarTypeFileTime = 17;
  EvtVarTypeSid      = 19;

  // EVT_LOG_PROPERTY_ID
  EvtLogNumberOfLogRecords = 5;

  // EVT_FORMAT_MESSAGE_FLAGS
  EvtFormatMessageEvent = 1;
  EvtFormatMessageTask  = 3;

  // classic EVENTLOG_* type constants (kept for EventTypeToStr/Index compat)
  EVENTLOG_ERROR_TYPE       = $0001;
  EVENTLOG_WARNING_TYPE     = $0002;
  EVENTLOG_INFORMATION_TYPE = $0004;
  EVENTLOG_AUDIT_SUCCESS    = $0008;
  EVENTLOG_AUDIT_FAILURE    = $0010;
  // Keyword bits used by providers to mark audit events (System/Security logs).
  KEYWORD_AUDIT_FAILURE = $0010000000000000;
  KEYWORD_AUDIT_SUCCESS = $0020000000000000;

type
  // Raw 16-byte EVT_VARIANT: 8 bytes of union payload + Count + VarType.
  TEvtVariant = record
    Data: array[0..7] of Byte;
    Count: DWORD;
    VarType: DWORD;
  end;
  PEvtVariant = ^TEvtVariant;

  PEventLog32 = ^TEventLog32_Struct;
  TEventLog32_Struct = record
    lpSource: AnsiBuffer;
    lpLog: AnsiBuffer;
    RecordNumber: Integer;      // last nIndex successfully delivered, -2 = none yet
    TotalRecords: Int64;

    QueryHandle: THandle;       // EvtQuery result set (reverse direction)
    RenderContext: THandle;     // EvtCreateRenderContext(EvtRenderContextSystem)
    CurrentEvent: THandle;      // handle to the currently-loaded event

    SysValuesBuf: Pointer;      // dynamically (re)allocated by EvtRender's 2-pass sizing
    SysValuesCap: DWORD;        // current allocated size of SysValuesBuf, in bytes

    ComputerBuf: AnsiBuffer;    // scratch: EventLog32EventComputer result storage

    PublisherCache: TStringList; // Name=ProviderName, Objects[i]=EvtHandle (metadata)
  end;

function EvtQuery(Session: THandle; Path: PWideChar; Query: PWideChar; Flags: DWORD): THandle; stdcall; external wevtapi name 'EvtQuery';
function EvtNext(ResultSet: THandle; EventsSize: DWORD; var EventArray: THandle; Timeout: DWORD; Flags: DWORD; var Returned: DWORD): BOOL; stdcall; external wevtapi name 'EvtNext';
function EvtClose(Handle: THandle): BOOL; stdcall; external wevtapi name 'EvtClose';
function EvtCreateRenderContext(ValuePathsCount: DWORD; ValuePaths: Pointer; Flags: DWORD): THandle; stdcall; external wevtapi name 'EvtCreateRenderContext';
function EvtRender(Context: THandle; Fragment: THandle; Flags: DWORD; BufferSize: DWORD; Buffer: Pointer; var BufferUsed: DWORD; var PropertyCount: DWORD): BOOL; stdcall; external wevtapi name 'EvtRender';
function EvtOpenLog(Session: THandle; Path: PWideChar; Flags: DWORD): THandle; stdcall; external wevtapi name 'EvtOpenLog';
function EvtGetLogInfo(Log: THandle; PropertyId: DWORD; BufferSize: DWORD; Buffer: Pointer; var BufferUsed: DWORD): BOOL; stdcall; external wevtapi name 'EvtGetLogInfo';
function EvtOpenPublisherMetadata(Session: THandle; PublisherId: PWideChar; LogFilePath: PWideChar; Locale: DWORD; Flags: DWORD): THandle; stdcall; external wevtapi name 'EvtOpenPublisherMetadata';
function EvtFormatMessage(PublisherMetadata: THandle; Event: THandle; MessageId: DWORD; ValueCount: DWORD; Values: Pointer; Flags: DWORD; BufferSize: DWORD; Buffer: PWideChar; var BufferUsed: DWORD): BOOL; stdcall; external wevtapi name 'EvtFormatMessage';

function EventLog32Create(const source: PChar): Pointer;
function EventLog32Destroy(pevnlgobj: PEventLog32): DWORD;
function EventLog32Count(pevnlgobj: PEventLog32): DWORD;
function EventLog32ReadEvent(pevnlgobj: PEventLog32; nIndex: Integer; readflags: DWORD): BOOL;
function EventLog32GetText(pevnlgobj: PEventLog32; category: Integer): PChar;
function EventLog32GetEventName(pevnlgobj: PEventLog32): AnsiBuffer;
function EventLog32GetEventID(pevnlgobj: PEventLog32): Integer;
function EventLog32GeneratedTime(pevnlgobj: PEventLog32): SYSTEMTIME;
function EventLog32GetSID(pevnlgobj: PEventLog32): PSID;
function EventLog32EventComputer(pevnlgobj: PEventLog32): PChar;
function EventLog32EventType(pevnlgobj: PEventLog32): WORD;
function EventLog32EventCategory(pevnlgobj: PEventLog32): WORD;
function EventLog32EventSource(pevnlgobj: PEventLog32): AnsiBuffer;

implementation

function EvtVarByte(const V: TEvtVariant): Byte;
begin Result := V.Data[0]; end;

function EvtVarUInt16(const V: TEvtVariant): Word;
begin Result := PWord(@V.Data[0])^; end;

function EvtVarUInt32(const V: TEvtVariant): Cardinal; 
begin Result := PCardinal(@V.Data[0])^; end;

function EvtVarUInt64(const V: TEvtVariant): Int64; 
begin Result := PInt64(@V.Data[0])^; end;

function EvtVarFileTime(const V: TEvtVariant): TFileTime; 
begin Result := PFileTime(@V.Data[0])^; end;

function EvtVarString(const V: TEvtVariant): PWideChar; 
begin Result := PPointer(@V.Data[0])^; end;

function EvtVarSid(const V: TEvtVariant): PSID; 
begin Result := PPointer(@V.Data[0])^; end;

function SysVar(pevnlgobj: PEventLog32; id: Integer): TEvtVariant;
begin
  if (pevnlgobj^.SysValuesBuf = nil) or (id < 0) or (id >= EvtSystemPropertyIdEnd) then
    FillChar(Result, SizeOf(Result), 0)
  else
    Result := PEvtVariant(NativeUInt(pevnlgobj^.SysValuesBuf) + NativeUInt(id) * SizeOf(TEvtVariant))^;
end;

function CreateFallbackMessage(pevnlgobj: PEventLog32): PChar;
var
  SourceName: AnsiBuffer;
  Msg: string;
begin
  SourceName := EventLog32EventSource(pevnlgobj);
  if StrIComp(SourceName, 'ftdisk') = 0 then
    Msg := 'Disk'
  else
    Msg := 'Message resource not found';

  Result := PChar(LocalAlloc(LPTR, (Length(Msg) + 1) * SizeOf(Char)));
  if Result <> nil then
    StrCopy(Result, PChar(Msg));
end;

function EventLog32Create(const source: PChar): Pointer;
var
  ChannelName: WideString;
  LogHandle: THandle;
  CountVar: TEvtVariant;
  BufUsed: DWORD;
begin
  Result := nil;
  if source = nil then Exit;
  ChannelName := WideString(source);

  Result := supHeapAlloc(SizeOf(TEventLog32_Struct));
  if Result = nil then Exit;
  FillChar(Result^, SizeOf(TEventLog32_Struct), 0);

  with PEventLog32(Result)^ do
  begin
    StrLCopy(lpSource, source, SizeOf(lpSource) - 1);
    StrLCopy(lpLog, source, SizeOf(lpLog) - 1);
    RecordNumber := -2;

    QueryHandle := EvtQuery(0, PWideChar(ChannelName), nil, EvtQueryChannelPath or EvtQueryReverseDirection);
    if QueryHandle = 0 then
    begin
      OutputDebugString(PChar(Format('EvtQuery failed, GetLastError=%d', [GetLastError])));
      supHeapFree(Result); Result := nil; Exit;
    end;

    TotalRecords := 0;
    LogHandle := EvtOpenLog(0, PWideChar(ChannelName), EvtOpenChannelPath);
    if LogHandle <> 0 then
    begin
      if EvtGetLogInfo(LogHandle, EvtLogNumberOfLogRecords, SizeOf(CountVar), @CountVar, BufUsed) then
        TotalRecords := EvtVarUInt64(CountVar);
      EvtClose(LogHandle);
    end;

    RenderContext := EvtCreateRenderContext(0, nil, EvtRenderContextSystem);
    if RenderContext = 0 then
    begin
      OutputDebugString(PChar(Format('EvtCreateRenderContext failed, GetLastError=%d', [GetLastError])));
      EvtClose(QueryHandle);
      supHeapFree(Result); Result := nil; Exit;
    end;

    CurrentEvent := 0;
    SysValuesCap := EvtSystemPropertyIdEnd * SizeOf(TEvtVariant) + 512;
    GetMem(SysValuesBuf, SysValuesCap);

    PublisherCache := TStringList.Create;
    PublisherCache.Sorted := True;
    PublisherCache.Duplicates := dupIgnore;
    PublisherCache.CaseSensitive := False;
  end;
end;

function EventLog32Destroy(pevnlgobj: PEventLog32): DWORD;
var
  i: Integer;
begin
  Result := 0;
  if pevnlgobj = nil then Exit;
  with pevnlgobj^ do
  begin
    if CurrentEvent <> 0 then EvtClose(CurrentEvent);
    if RenderContext <> 0 then EvtClose(RenderContext);
    if QueryHandle <> 0 then EvtClose(QueryHandle);
    if SysValuesBuf <> nil then FreeMem(SysValuesBuf);
    if PublisherCache <> nil then
    begin
      for i := 0 to PublisherCache.Count - 1 do
        if PublisherCache.Objects[i] <> nil then
          EvtClose(THandle(PublisherCache.Objects[i]));
      PublisherCache.Free;
    end;
  end;
  supHeapFree(pevnlgobj);
  Result := 1;
end;

function EventLog32Count(pevnlgobj: PEventLog32): DWORD;
begin
  Result := 0;
  if pevnlgobj <> nil then
    Result := DWORD(pevnlgobj^.TotalRecords);
end;

function EventLog32ReadEvent(pevnlgobj: PEventLog32; nIndex: Integer; readflags: DWORD): BOOL;
var
  Returned, BufUsed, PropCount: DWORD;
  NewEvent: THandle;
begin
  Result := False;
  if (pevnlgobj = nil) or (pevnlgobj^.QueryHandle = 0) then Exit;
  if nIndex = pevnlgobj^.RecordNumber then begin Result := True; Exit; end;

  if (pevnlgobj^.RecordNumber <> -2) and (nIndex <> pevnlgobj^.RecordNumber - 1) then Exit;

  NewEvent := 0;
  if not EvtNext(pevnlgobj^.QueryHandle, 1, NewEvent, INFINITE, 0, Returned) or (Returned = 0) then
  begin
    OutputDebugString(PChar(Format('EvtNext failed at idx %d, GetLastError=%d', [nIndex, GetLastError])));
    Exit;
  end;

  if pevnlgobj^.CurrentEvent <> 0 then EvtClose(pevnlgobj^.CurrentEvent);
  pevnlgobj^.CurrentEvent := NewEvent;

  BufUsed := 0; PropCount := 0;
  if not EvtRender(pevnlgobj^.RenderContext, NewEvent, EvtRenderEventValues,
       pevnlgobj^.SysValuesCap, pevnlgobj^.SysValuesBuf, BufUsed, PropCount) then
  begin
    if GetLastError = ERROR_INSUFFICIENT_BUFFER then
    begin
      if pevnlgobj^.SysValuesBuf <> nil then FreeMem(pevnlgobj^.SysValuesBuf);
      GetMem(pevnlgobj^.SysValuesBuf, BufUsed);
      pevnlgobj^.SysValuesCap := BufUsed;

      if not EvtRender(pevnlgobj^.RenderContext, NewEvent, EvtRenderEventValues,
           pevnlgobj^.SysValuesCap, pevnlgobj^.SysValuesBuf, BufUsed, PropCount) then
      begin
        OutputDebugString(PChar(Format('EvtRender retry failed at idx %d, GetLastError=%d', [nIndex, GetLastError])));
        FreeMem(pevnlgobj^.SysValuesBuf);
        pevnlgobj^.SysValuesBuf := nil;
        pevnlgobj^.SysValuesCap := 0;
      end;
    end
    else
      OutputDebugString(PChar(Format('EvtRender failed at idx %d, GetLastError=%d', [nIndex, GetLastError])));
  end;

  pevnlgobj^.RecordNumber := nIndex;
  Result := True;
end;

function EventLog32GetEventName(pevnlgobj: PEventLog32): AnsiBuffer;
var
  W: PWideChar;
begin
  FillChar(Result, SizeOf(Result), 0);
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemProviderName) do
  begin
    if VarType = EvtVarTypeNull then Exit;
    W := EvtVarString(SysVar(pevnlgobj, EvtSystemProviderName));
  end;
  if W = nil then Exit;
  StrLCopy(Result, PChar(AnsiString(WideString(W))), SizeOf(Result) - 1);
end;

function EventLog32EventSource(pevnlgobj: PEventLog32): AnsiBuffer;
begin
  Result := EventLog32GetEventName(pevnlgobj);
end;

function EventLog32GetEventID(pevnlgobj: PEventLog32): Integer;
begin
  Result := 0;
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemEventID) do
    if VarType <> EvtVarTypeNull then Result := EvtVarUInt16(SysVar(pevnlgobj, EvtSystemEventID));
end;

function EventLog32GeneratedTime(pevnlgobj: PEventLog32): SYSTEMTIME;
var
  FT: TFileTime;
  UTC: TSystemTime;
begin
  FillChar(Result, SizeOf(Result), 0);
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemTimeCreated) do
  begin
    if VarType = EvtVarTypeNull then Exit;
    FT := EvtVarFileTime(SysVar(pevnlgobj, EvtSystemTimeCreated));
  end;
  if FileTimeToSystemTime(FT, UTC) then
    SystemTimeToTzSpecificLocalTime(nil, UTC, Result);
end;

function EventLog32EventCategory(pevnlgobj: PEventLog32): WORD;
begin
  Result := 0;
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemTask) do
    if VarType <> EvtVarTypeNull then Result := EvtVarUInt16(SysVar(pevnlgobj, EvtSystemTask));
end;

function EventLog32GetSID(pevnlgobj: PEventLog32): PSID;
begin
  Result := nil;
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemUserID) do
    if VarType = EvtVarTypeSid then Result := EvtVarSid(SysVar(pevnlgobj, EvtSystemUserID));
end;

function EventLog32Count_Unused: Integer; // placeholder removed below
begin Result := 0; end;

function EventLog32EventComputer(pevnlgobj: PEventLog32): PChar;
var
  W: PWideChar;
begin
  Result := '';
  if pevnlgobj = nil then Exit;
  with SysVar(pevnlgobj, EvtSystemComputer) do
  begin
    if VarType = EvtVarTypeNull then Exit;
    W := EvtVarString(SysVar(pevnlgobj, EvtSystemComputer));
  end;
  if W = nil then Exit;
  StrLCopy(pevnlgobj^.ComputerBuf, PChar(AnsiString(WideString(W))), SizeOf(pevnlgobj^.ComputerBuf) - 1);
  Result := pevnlgobj^.ComputerBuf;
end;

function EventLog32EventType(pevnlgobj: PEventLog32): WORD;
var
  Level: Byte;
  Keywords: Int64;
begin
  Result := EVENTLOG_INFORMATION_TYPE;
  if pevnlgobj = nil then Exit;

  with SysVar(pevnlgobj, EvtSystemLevel) do
    if VarType <> EvtVarTypeNull then
    begin
      Level := EvtVarByte(SysVar(pevnlgobj, EvtSystemLevel));
      case Level of
        1, 2: Result := EVENTLOG_ERROR_TYPE;   // Critical, Error
        3:    Result := EVENTLOG_WARNING_TYPE; // Warning
      else
        Result := EVENTLOG_INFORMATION_TYPE;   // LogAlways, Information, Verbose
      end;
    end;

  with SysVar(pevnlgobj, EvtSystemKeywords) do
    if VarType <> EvtVarTypeNull then
    begin
      Keywords := EvtVarUInt64(SysVar(pevnlgobj, EvtSystemKeywords));
      if (Keywords and KEYWORD_AUDIT_FAILURE) <> 0 then Result := EVENTLOG_AUDIT_FAILURE
      else if (Keywords and KEYWORD_AUDIT_SUCCESS) <> 0 then Result := EVENTLOG_AUDIT_SUCCESS;
    end;
end;

function EventLog32GetText(pevnlgobj: PEventLog32; category: Integer): PChar;
var
  ProviderName: WideString;
  PubIdx: Integer;
  PubMeta: THandle;
  Buf: array[0..4095] of WideChar;
  BufUsed: DWORD;
  FormatFlag: DWORD;
  Ansi: AnsiString;
  W: PWideChar;
begin
  Result := nil;
  if (pevnlgobj = nil) or (pevnlgobj^.CurrentEvent = 0) then Exit;

  with SysVar(pevnlgobj, EvtSystemProviderName) do
  begin
    if VarType = EvtVarTypeNull then Exit;
    W := EvtVarString(SysVar(pevnlgobj, EvtSystemProviderName));
  end;
  if W = nil then Exit;
  ProviderName := W;

  PubIdx := pevnlgobj^.PublisherCache.IndexOf(UnicodeToString(PWideChar(ProviderName)));
  if PubIdx >= 0 then
    PubMeta := THandle(pevnlgobj^.PublisherCache.Objects[PubIdx])
  else
  begin
    PubMeta := EvtOpenPublisherMetadata(0, PWideChar(ProviderName), nil, 0, 0);
    pevnlgobj^.PublisherCache.AddObject(UnicodeToString(PWideChar(ProviderName)), TObject(PubMeta)); // 0 cached too
  end;

  if PubMeta = 0 then begin Result := CreateFallbackMessage(pevnlgobj); Exit; end;

  if category = -1 then FormatFlag := EvtFormatMessageEvent
  else FormatFlag := EvtFormatMessageTask;

  BufUsed := 0;
  if EvtFormatMessage(PubMeta, pevnlgobj^.CurrentEvent, 0, 0, nil, FormatFlag,
       SizeOf(Buf) div SizeOf(WideChar), Buf, BufUsed) then
  begin
    Ansi := AnsiString(WideString(Buf));
    Result := PChar(LocalAlloc(LPTR, (Length(Ansi) + 1) * SizeOf(AnsiChar)));
    if Result <> nil then StrCopy(Result, PChar(Ansi));
  end
  else
    Result := CreateFallbackMessage(pevnlgobj);
end;

end.
