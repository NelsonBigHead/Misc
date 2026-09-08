{

version 2.0

version history
   1.0: 02.02.06 - initial release
   1.1: 03.04.09 - fixed wide monitor drawing bug
   2.0: 28.08.26 - rework to get rid of old legacy code
}

unit Chrono;

{$MODE ObjFPC}
{$H+}
{$R-}

interface

uses
  Windows, Messages, SysUtils, RtlTypes, PWUtils;

function ChronoWindowCreate(hwndParent: HWND; x, y, Width, Height: integer): Pointer;
function ChronoWindowEnableCounter(pObj: Pointer; counternum: integer;
  fEnable: BOOL): BOOL;
function ChronoWindowSetCounterColor(pObj: Pointer; counternum: integer;
  color: DWORD): BOOL;
function ChronoWindowSetCounterValue(pObj: Pointer; counternum: integer;
  value1, value2: single): BOOL;
procedure ChronoWindowStep(pObj: Pointer);
procedure ChronoWindowTitle(pObj: Pointer; counternum: integer; pTitle: pchar);
function ChronoWindowDelete(pObj: Pointer): BOOL;
function ChronoWindowSize(pObj: Pointer; newWidth, newHeight: integer): BOOL;
function ChronoWindowPos(pObj: Pointer; newX, newY: integer): BOOL;
procedure ChronoWindowScale(pObj: Pointer; counternum: integer; newScale: single);
procedure ChronoWindowGridColor(pObj: Pointer; color: DWORD);
procedure ChronoWindowRepaint(pObj: Pointer);

implementation

const
  CHRONOCLASSNAME: pansichar = 'ChronoWindowClass';

type
  _CHRONOOBJECT = record
    windowHandle: HWND;
    wDC, backDC: HDC;
    backBitmap: HBITMAP;
    gridPen, whitePen: HPEN;
    font: HFONT;
    step, Height, Width: integer;
    timehistory: array[0..1023] of FILETIME;
    counters: array[0..15] of record
      title: array[0..15] of ansichar;
      pen: HPEN;
      Enabled: BOOL;
      scale: single;
      history, history2: array[0..1023] of single;
      end;
  end;
  CHRONOOBJECT = _CHRONOOBJECT;
  PCHRONOOBJECT = ^_CHRONOOBJECT;

procedure ChronoWindowTitle(pObj: Pointer; counternum: integer; pTitle: pchar);
begin
  if (counternum > 15) or (counternum < 0) then
    Exit;
  StrLCopy(PCHRONOOBJECT(pObj)^.counters[counternum].title, pTitle, 15);
end;

function ChronoWindowSetCounterColor(pObj: Pointer; counternum: integer;
  color: DWORD): BOOL;
begin
  Result := False;
  if (counternum > 15) or (counternum < 0) then
    Exit;

  with PCHRONOOBJECT(pObj)^.counters[counternum] do
  begin
    if pen <> 0 then
      DeleteObject(pen);
    pen := CreatePen(PS_SOLID, 1, color);
  end;
  Result := True;
end;

procedure ChronoWindowScale(pObj: Pointer; counternum: integer; newScale: single);
begin
  PCHRONOOBJECT(pObj)^.counters[counternum].scale := newScale;
  ChronoWindowRepaint(pObj);
end;

function ChronoWindowSetCounterValue(pObj: Pointer; counternum: integer;
  value1, value2: single): BOOL;
var
  c: integer;
begin
  Result := False;
  if (pObj = nil) or (counternum > 15) or (counternum < 0) then
    Exit;

  with PCHRONOOBJECT(pObj)^.counters[counternum] do
  begin
    for c := 1022 downto 0 do
    begin
      history[c + 1] := history[c];
      history2[c + 1] := history2[c];
    end;
    history[0] := value1;
    history2[0] := value2;
  end;

  Result := True;
end;

function ChronoWindowEnableCounter(pObj: Pointer; counternum: integer;
  fEnable: BOOL): BOOL;
begin
  Result := False;
  if (pObj = nil) or (counternum > 15) or (counternum < 0) then
    Exit;

  PCHRONOOBJECT(pObj)^.counters[counternum].Enabled := fEnable;
  Result := True;
end;

function ChronoWindowSize(pObj: Pointer; newWidth, newHeight: integer): BOOL;
begin
  Result := SetWindowPos(PCHRONOOBJECT(pObj)^.windowHandle, 0, 0, 0,
    newWidth, newHeight, SWP_NOZORDER or SWP_NOMOVE);
  PCHRONOOBJECT(pObj)^.Height := newHeight;
  PCHRONOOBJECT(pObj)^.Width := newWidth;
  ChronoWindowRepaint(pObj);
end;

function ChronoWindowPos(pObj: Pointer; newX, newY: integer): BOOL;
begin
  Result := SetWindowPos(PCHRONOOBJECT(pObj)^.windowHandle, 0, newX,
    newY, 0, 0, SWP_NOZORDER or SWP_NOSIZE);
end;

function ChronoWindowDelete(pObj: Pointer): BOOL;
var
  b1: BOOL;
  c: integer;
begin
  if pObj = nil then
  begin
    Result := False;
    Exit;
  end;

  for c := 0 to 15 do
    if PCHRONOOBJECT(pObj)^.counters[c].Pen <> 0 then
      DeleteObject(PCHRONOOBJECT(pObj)^.counters[c].Pen);

  if PCHRONOOBJECT(pObj)^.gridPen <> 0 then
    DeleteObject(PCHRONOOBJECT(pObj)^.gridPen);
  if PCHRONOOBJECT(pObj)^.whitePen <> 0 then
    DeleteObject(PCHRONOOBJECT(pObj)^.whitePen);
  if PCHRONOOBJECT(pObj)^.font <> 0 then
    DeleteObject(PCHRONOOBJECT(pObj)^.font);
  if PCHRONOOBJECT(pObj)^.backBitmap <> 0 then
    DeleteObject(PCHRONOOBJECT(pObj)^.backBitmap);
  if PCHRONOOBJECT(pObj)^.backDC <> 0 then
    DeleteDC(PCHRONOOBJECT(pObj)^.backDC);

  if PCHRONOOBJECT(pObj)^.wDC <> 0 then
    ReleaseDC(PCHRONOOBJECT(pObj)^.windowHandle, PCHRONOOBJECT(pObj)^.wDC);

  b1 := DestroyWindow(PCHRONOOBJECT(pObj)^.windowHandle);

  supHeapFree(pObj);
  Result := b1;
end;

procedure ChronoWindow_drawinfo(pObj: Pointer; x, y: integer);
var
  textbuf: array[0..63] of ansichar;
  st1: SYSTEMTIME;
  l, c, t, i, w, h: integer;
  ft: FILETIME;
  lpen: LOGPEN;
  sz: SIZE;
  TempStr: string;
  histVal: single;
begin
  w := PCHRONOOBJECT(pObj)^.Width - 4;
  h := PCHRONOOBJECT(pObj)^.Height - 4;

  if (w <= 0) or (h <= 0) then
    Exit;

  if x < 0 then
    x := 0;
  if x > w then
    x := w;

  SelectObject(PCHRONOOBJECT(pObj)^.backDC, PCHRONOOBJECT(pObj)^.whitePen);
  for l := 0 to h div 6 do
  begin
    MoveToEx(PCHRONOOBJECT(pObj)^.backDC, x, l * 6, nil);
    LineTo(PCHRONOOBJECT(pObj)^.backDC, x, l * 6 + 3);
  end;

  SetBkColor(PCHRONOOBJECT(pObj)^.backDC, $000000);
  SetBkMode(PCHRONOOBJECT(pObj)^.backDC, OPAQUE);

  l := (w - x) div 2;

  if l < 0 then
    l := 0;
  if l > 1023 then
    l := 1023;

  ft := PCHRONOOBJECT(pObj)^.timehistory[l];

  if int64(ft) <> 0 then
  begin
    t := 13;
    for c := 0 to 15 do
      with PCHRONOOBJECT(pObj)^.counters[c] do
        if Enabled then
        begin
          histVal := history[l];

          if histVal < 0 then
            histVal := 0;

          TempStr := IntToStr(trunc(histVal)) + '.' + IntToStr(
            (round(histVal * 100.0) mod 100)) + ' ' + string(title);
          StrLCopy(textbuf, PChar(TempStr), SizeOf(textbuf) - 1);

          GetObject(pen, SizeOf(LOGPEN), @lpen);
          SetTextColor(PCHRONOOBJECT(pObj)^.backDC, lpen.lopnColor);

          i := round((h / scale) * histVal);
          if i < 13 then
            t := t + 13;

          GetTextExtentPoint32(PCHRONOOBJECT(pObj)^.backDC, textbuf,
            StrLen(textbuf), sz);
          TextOut(PCHRONOOBJECT(pObj)^.backDC, x - (sz.cx div 2) +
            1, h - t, textbuf, StrLen(textbuf));
          t := t + 13;
        end;

    FileTimeToSystemTime(ft, st1);
    SystemTimeToTzSpecificLocalTime(nil, st1, st1);

    TempStr := Format('%.2d:%.2d:%.2d', [st1.wHour, st1.wMinute, st1.wSecond]);
    StrLCopy(textbuf, PChar(TempStr), SizeOf(textbuf) - 1);

    SetTextColor(PCHRONOOBJECT(pObj)^.backDC, $FFFFFF);
    TextOut(PCHRONOOBJECT(pObj)^.backDC, x - 21, 0, textbuf, StrLen(textbuf));
  end;
end;

procedure ChronoWindowRepaint(pObj: Pointer);
var
  c, t, sh, w, h, yVal: integer;
  pt1: TPOINT;
  r1, clientRect: TRECT;
begin
  if pObj = nil then
    Exit;

  with PCHRONOOBJECT(pObj)^ do
  begin
    // 1. Get actual client rectangle to ensure we always clear the correct area
    GetClientRect(windowHandle, clientRect);
    if (clientRect.Right <= clientRect.Left) or (clientRect.Bottom <=
      clientRect.Top) then
      Exit;

    // Synchronize struct dimensions with actual window size
    Width := clientRect.Right - clientRect.Left;
    Height := clientRect.Bottom - clientRect.Top;

    SelectObject(backDC, gridPen);

    // 2. Clear the ENTIRE actual client area
    FillRect(backDC, clientRect, GetStockObject(BLACK_BRUSH));

    w := Width - 4;
    h := Height - 4;

    if (w <= 0) or (h <= 0) then
    begin
      BitBlt(wDC, 0, 0, clientRect.Right, clientRect.Bottom, backDC, 0, 0, SRCCOPY);
      Exit;
    end;

    sh := (step * 2) mod 12;

    for c := 0 to w div 12 do
    begin
      MoveToEx(backDC, w - c * 12 - sh, 0, nil);
      LineTo(backDC, w - c * 12 - sh, h);
    end;
    for c := 0 to h div 12 do
    begin
      MoveToEx(backDC, 0, h - c * 12, nil);
      LineTo(backDC, w, h - c * 12);
    end;

    for t := 0 to 15 do
      if counters[t].Enabled then
      begin
        SelectObject(backDC, counters[t].pen);

        if counters[t].scale = 0 then
          Continue;

        for c := 0 to (w div 2) + 1 do
        begin
          if (step < (c + 1)) or (c > 1023) then
            Break;

          yVal := h - Round((h / counters[t].scale) *
            counters[t].history[c]);

          if yVal < 0 then
            yVal := 0
          else if yVal > h then
            yVal := h;

          if c = 0 then
            MoveToEx(backDC, w, yVal, nil)
          else
            LineTo(backDC, w - c * 2, yVal);
        end;
      end;

    GetCursorPos(pt1);
    GetWindowRect(windowHandle, r1);
    if (pt1.x >= r1.Left) and (pt1.x < r1.Right - 3) and (pt1.y >= r1.Top) and
      (pt1.y <= r1.Bottom) then
      ChronoWindow_drawinfo(pObj, pt1.x - r1.Left - 1, pt1.y - r1.Top - 1);

    BitBlt(wDC, 0, 0, clientRect.Right, clientRect.Bottom, backDC, 0, 0, SRCCOPY);
  end;
end;

procedure ChronoWindowStep(pObj: Pointer);
var
  c: integer;
begin
  if pObj = nil then
    Exit;

  with PCHRONOOBJECT(pObj)^ do
  begin
    for c := 1022 downto 0 do
      timehistory[c + 1] := timehistory[c];

    GetSystemTimeAsFileTime(timehistory[0]);
  end;

  if PCHRONOOBJECT(pObj)^.step = High(integer) then
    PCHRONOOBJECT(pObj)^.step := 0
  else
    Inc(PCHRONOOBJECT(pObj)^.step);

  ChronoWindowRepaint(pObj);
end;

procedure ChronoWindowGridColor(pObj: Pointer; color: DWORD);
begin
  if pObj = nil then
    Exit;
  DeleteObject(PCHRONOOBJECT(pObj)^.gridPen);
  PCHRONOOBJECT(pObj)^.gridPen := CreatePen(PS_SOLID, 1, color);
  ChronoWindowRepaint(pObj);
end;

function ChronoWindowProc(_hwnd: HWND; uMsg: UINT; wParameter: WParam; lParameter: LParam): LResult; stdcall;
var
  p1: PCHRONOOBJECT;
begin
  p1 := PCHRONOOBJECT(GetWindowLongPtr(_hwnd, GWLP_USERDATA));

  case uMsg of
    WM_PAINT, WM_MOUSEMOVE:
      if p1 <> nil then
        if p1^.windowHandle = _hwnd then
          ChronoWindowRepaint(p1);
  end;
  Result := DefWindowProc(_hwnd, uMsg, wParameter, lParameter);
end;

function ChronoWindowCreate(hwndParent: HWND; x, y, Width, Height: integer): Pointer;
var
  inst: HINST;
  wincls: WNDCLASSEXA;
  cWindow: HWND;
  p1: PCHRONOOBJECT;
  c: integer;
  ScreenWidth, ScreenHeight: integer;
begin
  Result := nil;
  inst := GetModuleHandle(nil);

  if not GetClassInfoEx(inst, CHRONOCLASSNAME, @wincls) then
  begin
    with wincls do
    begin
      cbSize := SizeOf(WNDCLASSEX);
      style := CS_OWNDC;
      lpfnWndProc := @ChronoWindowProc;
      cbClsExtra := 0;
      cbWndExtra := SizeOf(Pointer);
      hInstance := inst;
      hIcon := 0;
      hCursor := LoadCursor(0, IDC_ARROW);
      hbrBackground := GetStockObject(BLACK_BRUSH);
      lpszMenuName := nil;
      lpszClassName := CHRONOCLASSNAME;
      hIconSm := 0;
    end;
    RegisterClassExA(wincls);
  end;

  p1 := supHeapAlloc(SizeOf(CHRONOOBJECT));
  if p1 = nil then
    Exit;

  FillChar(p1^, SizeOf(CHRONOOBJECT), 0);

  cWindow := CreateWindowExA(WS_EX_CLIENTEDGE, CHRONOCLASSNAME, 'chrono',
    WS_VISIBLE or WS_CHILD, x, y, Width, Height, hwndParent, 0, 0, nil);

  if cWindow = 0 then
  begin
    supHeapFree(p1);
    Exit;
  end;

  SetWindowLongPtr(cWindow, GWLP_USERDATA, nativeint(p1));

  ScreenWidth := GetSystemMetrics(SM_CXSCREEN);
  ScreenHeight := GetSystemMetrics(SM_CYSCREEN);

  p1^.font := CreateFontA(-11, 0, 0, 0, FW_NORMAL, 0, 0, 0, DEFAULT_CHARSET,
    OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, PROOF_QUALITY, DEFAULT_PITCH or
    FF_DONTCARE, 'Consolas');

  for c := 0 to 15 do
  begin
    p1^.counters[c].pen := 0;
    p1^.counters[c].Enabled := False;
    p1^.counters[c].scale := 100.0;
  end;

  p1^.Height := Height;
  p1^.Width := Width;
  p1^.windowHandle := cWindow;
  p1^.step := 0;
  p1^.wDC := GetDC(cWindow);
  p1^.backDC := CreateCompatibleDC(p1^.wDC);

  SelectObject(p1^.backDC, p1^.font);
  p1^.gridPen := CreatePen(PS_SOLID, 1, $408000);
  p1^.whitePen := CreatePen(PS_SOLID, 1, $FFFFFF);

  p1^.backBitmap := CreateCompatibleBitmap(p1^.wDC, ScreenWidth, ScreenHeight);
  SelectObject(p1^.backDC, p1^.backBitmap);

  Result := p1;
end;

end.
