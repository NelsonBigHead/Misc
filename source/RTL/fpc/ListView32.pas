{
 Revision History:
 001, 07.06.04 - first release
 002, 05.07.04 - improved memory managment, fixed possible memory leaks
 003, 22.07.04 - fixed one memory leak
 004, 07.07.05 - selalways added, can be overrided by SetWindowLong call
 005, 21.05.06 - fixed "Runtime error" bug
 006, 28.05.06 - unicode conversion
 007, 18.07.06 - support for data field
 008, 15.12.06 - fixed few bugs
 -||- this is for Unicode version of Listview32, listview32w.pas
 009, 22.12.06 - Full Unicode version
 010, 10.01.07 - CheckBoxes Selection added ;)
 011, 24.01.07 - Flashes and sparks added ;)
 090, 27.08.26 - Get rid of non portable stuff.
 100, 31.08.26 - ObjFPC x86-32/x64 conversion.
}
unit ListView32;

{$MODE ObjFPC}
{$H+}

interface

uses
  Windows, CommCtrl, SysUtils, Classes, RtlTypes, PWUtils;

const
  LVS_EX_DOUBLEBUFFER = $00010000;

type
  TListViewData = record
    Window: HWND;
    Style: longint;
    ExStyle: longint;
    ColumnCount: integer;
    ItemCount: integer;
    Items: TList;
    Initialized: boolean;
  end;
  PListViewData = ^TListViewData;

  TListViewItemData = record
    Text: TStringList;
    ItemIndex: integer;
    Data: Pointer;
  end;
  PListViewItemData = ^TListViewItemData;

function LView_InitListView(var ListViewData: TListViewData; const ParentWnd: HWND;
  const ResourceId: integer): boolean;
procedure LView_Uninit(var ListViewData: TListViewData; CleanData: boolean);
function LView_ItemCount(var LVData: TListViewData): integer;
procedure LView_ClearAll(var LVData: TListViewData);
procedure LView_AddItem(var LVData: TListViewData; const ItemIndex: integer; const LastColumnIndex: integer;
  const ItemTexts: TStringList; const Data: Pointer = nil);
procedure LView_AddColumn(var LVData: TListViewData; TextAlign: integer; Width: integer; const Caption: pchar);
function LView_GetItemText(var LVData: TListViewData; ItemIndex, SubItemIndex: integer): string;
procedure LView_ClearColumns(var LVData: TListViewData);
procedure LView_DeleteColumn(var LVData: TListViewData; ColumnIndex: integer);
procedure LView_DeleteItem(var LVData: TListViewData; ItemIndex: integer);
function LView_ChangeItem(var LVData: TListViewData; ItemIndex: integer; const LastColumnIndex: integer;
  const NewItemTexts: TStringList; const Data: Pointer = nil): boolean;
function LView_GetItemData(var LVData: TListViewData; ItemIndex: integer): Pointer;
function LView_CompareListItem(Data1, Data2: LPARAM; SortColumn: integer): integer; stdcall;
function LView_SortItems(var LData: TListViewData; ItemIndex: TWParam; SortCallback: TLParam): TLResult;

implementation

function LView_InitListView(var ListViewData: TListViewData; const ParentWnd: HWND;
  const ResourceId: integer): boolean;
begin
  ListViewData.Window := GetDlgItem(ParentWnd, ResourceId);
  if ListViewData.Window = 0 then
  begin
    ListViewData.Initialized := False;
    Result := False;
    Exit;
  end;
  SetWindowLongPtr(ListViewData.Window, GWL_STYLE, GetWindowLongPtr(ListViewData.Window, GWL_STYLE) or
    ListViewData.Style);
  if ListViewData.ExStyle = 0 then
    SendMessageA(ListViewData.Window, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, LVS_EX_FULLROWSELECT or
      LVS_EX_GRIDLINES or LVS_EX_INFOTIP or LVS_EX_DOUBLEBUFFER)
  else
    SendMessageA(ListViewData.Window, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, ListViewData.ExStyle);

  ListViewData.Items := TList.Create;
  ListViewData.Initialized := True;
  Result := True;
end;

procedure LView_Uninit(var ListViewData: TListViewData; CleanData: boolean);
var
  i: integer;
  ItemData: PListViewItemData;
begin
  if (ListViewData.Initialized = False) then
    Exit;
  if CleanData then
    for i := 0 to ListViewData.Items.Count - 1 do
    begin
      ItemData := PListViewItemData(ListViewData.Items[i]);
      if ItemData = nil then
        Continue;
      if ItemData^.Text <> nil then
        ItemData^.Text.Free;
      if ItemData^.Data <> nil then
        supHeapFree(ItemData^.Data);
      supHeapFree(ItemData);
    end
  else
    for i := 0 to ListViewData.Items.Count - 1 do
    begin
      ItemData := PListViewItemData(ListViewData.Items[i]);
      if ItemData <> nil then
        supHeapFree(ItemData);
    end;
  ListViewData.Items.Free;
  ListViewData.Items := nil;
  if ListViewData.Window <> 0 then
    SendMessageA(ListViewData.Window, LVM_DELETEALLITEMS, 0, 0);
  FillChar(ListViewData, SizeOf(TListViewData), 0);
end;

function LView_SortItems(var LData: TListViewData; ItemIndex: TWParam; SortCallback: TLParam): TLResult;
begin
  Result := SendMessageA(LData.Window, LVM_SORTITEMS, ItemIndex, SortCallback);
end;

function LView_ItemCount(var LVData: TListViewData): integer;
begin
  Result := 0;
  if (LVData.Initialized = False) then
    Exit;
  Result := SendMessageA(LVData.Window, LVM_GETITEMCOUNT, 0, 0);
end;

procedure LView_AddColumn(var LVData: TListViewData; TextAlign: integer; Width: integer; const Caption: pchar);
var
  Column: TLVColumn;
begin
  if LVData.Initialized = False then
    Exit;

  FillChar(Column, SizeOf(Column), 0);
  Column.mask := LVCF_TEXT or LVCF_FMT or LVCF_WIDTH or LVCF_SUBITEM;
  Column.fmt := TextAlign;
  Column.cx := Width;
  Column.pszText := Caption;
  if Caption <> nil then
    Column.cchTextMax := StrLen(Caption)
  else
    Column.cchTextMax := 0;
  if SendMessageA(LVData.Window, LVM_INSERTCOLUMN, LVData.ColumnCount, TLParam(@Column)) >= 0 then
    Inc(LVData.ColumnCount);
end;

procedure LView_ClearColumns(var LVData: TListViewData);
begin
  if LVData.Initialized = False then
    Exit;
  while LVData.ColumnCount > 0 do
    LView_DeleteColumn(LVData, 0);
end;

procedure LView_DeleteColumn(var LVData: TListViewData; ColumnIndex: integer);
begin
  if (LVData.Initialized = False) or (ColumnIndex < 0) or (ColumnIndex >= LVData.ColumnCount) then
    Exit;
  if SendMessageA(LVData.Window, LVM_DELETECOLUMN, ColumnIndex, 0) <> 0 then
    Dec(LVData.ColumnCount);
end;

procedure LView_DeleteItem(var LVData: TListViewData; ItemIndex: integer);
var
  ItemData: PListViewItemData;
begin
  if (LVData.Initialized = False) or (LVData.Items = nil) then
    Exit;
  if (ItemIndex < 0) or (ItemIndex >= LVData.Items.Count) then
    Exit;
  ItemData := PListViewItemData(LVData.Items[ItemIndex]);
  if SendMessageA(LVData.Window, LVM_DELETEITEM, ItemIndex, 0) = 0 then
    Exit;
  if ItemData <> nil then
  begin
    if ItemData^.Text <> nil then
      ItemData^.Text.Free;
    if ItemData^.Data <> nil then
      supHeapFree(ItemData^.Data);
    supHeapFree(ItemData);
  end;
  LVData.Items.Delete(ItemIndex);
  if LVData.ItemCount > 0 then
    Dec(LVData.ItemCount);
end;

procedure LView_AddItem(var LVData: TListViewData; const ItemIndex: integer; const LastColumnIndex: integer;
  const ItemTexts: TStringList; const Data: Pointer = nil);
var
  ListItem: TLVItem;
  ColumnIndex: integer;
  ItemData: PListViewItemData;
  InsertedIndex: integer;
begin
  if LVData.Initialized = False then
    Exit;
  if (LVData.Items = nil) or (LVData.Window = 0) or (ItemTexts = nil) then
    Exit;
  if (ItemIndex < 0) or (LastColumnIndex < 0) or (ItemTexts.Count <= LastColumnIndex) then
    Exit;

  ItemData := supHeapAlloc(SizeOf(TListViewItemData));
  if ItemData = nil then
    Exit;
  ItemData^.Text := TStringList.Create;
  if ItemData^.Text = nil then
  begin
    supHeapFree(ItemData);
    Exit;
  end;
  for ColumnIndex := 0 to LastColumnIndex do
    ItemData^.Text.Add(ItemTexts[ColumnIndex]);

  ItemData^.ItemIndex := ItemIndex;
  ItemData^.Data := Data;

  FillChar(ListItem, SizeOf(ListItem), 0);
  ListItem.mask := LVIF_TEXT or LVIF_PARAM;
  ListItem.iItem := ItemIndex;
  ListItem.pszText := PChar(ItemData^.Text[0]);
  ListItem.cchTextMax := Length(ItemData^.Text[0]);
  ListItem.lParam := TLParam(ItemData);

  InsertedIndex := SendMessageA(LVData.Window, LVM_INSERTITEM, 0, TLParam(@ListItem));
  if InsertedIndex < 0 then
  begin
    ItemData^.Text.Free;
    supHeapFree(ItemData);
    Exit;
  end;
  ItemData^.ItemIndex := InsertedIndex;

  LVData.Items.Insert(InsertedIndex, ItemData);
  for ColumnIndex := 1 to LastColumnIndex do
  begin
    FillChar(ListItem, SizeOf(ListItem), 0);
    ListItem.mask := LVIF_TEXT;
    ListItem.iItem := InsertedIndex;
    ListItem.iSubItem := ColumnIndex;
    ListItem.pszText := PChar(ItemData^.Text[ColumnIndex]);
    ListItem.cchTextMax := Length(ItemData^.Text[ColumnIndex]);
    SendMessageA(LVData.Window, LVM_SETITEM, 0, TLParam(@ListItem));
  end;
  LVData.ItemCount := LVData.Items.Count;
end;

procedure LView_ClearAll(var LVData: TListViewData);
var
  i: integer;
  ItemData: PListViewItemData;
begin
  if LVData.Initialized = False then
    Exit;
  for i := 0 to LVData.Items.Count - 1 do
  begin
    ItemData := PListViewItemData(LVData.Items[i]);
    if ItemData = nil then
      Continue;
    if ItemData^.Text <> nil then
      ItemData^.Text.Free;
    if ItemData^.Data <> nil then
      supHeapFree(ItemData^.Data);
    supHeapFree(ItemData);
  end;
  LVData.Items.Clear;
  if LVData.Window <> 0 then
    SendMessageA(LVData.Window, LVM_DELETEALLITEMS, 0, 0);
  LVData.ItemCount := 0;
end;

function LView_ChangeItem(var LVData: TListViewData; ItemIndex: integer; const LastColumnIndex: integer;
  const NewItemTexts: TStringList; const Data: Pointer = nil): boolean;
var
  ListItem: TLVItem;
  ColumnIndex: integer;
  ItemData: PListViewItemData;
begin
  Result := False;
  if (LVData.Initialized = False) or (LVData.Items = nil) or (NewItemTexts = nil) then
    Exit;
  if (LastColumnIndex < 0) or (NewItemTexts.Count <= LastColumnIndex) then
    Exit;
  if ItemIndex = -1 then
  begin
    ItemIndex := SendMessageA(LVData.Window, LVM_GETNEXTITEM, -1, LVNI_SELECTED or LVNI_FOCUSED);
    if ItemIndex = -1 then
      Exit;
  end;
  if (ItemIndex < 0) or (ItemIndex >= LVData.Items.Count) then
    Exit;
  ItemData := PListViewItemData(LVData.Items[ItemIndex]);
  if ItemData = nil then
    Exit;
  ItemData^.Text.Clear;
  if ItemData^.Data <> nil then
    supHeapFree(ItemData^.Data);
  ItemData^.Data := Data;
  for ColumnIndex := 0 to LastColumnIndex do
    ItemData^.Text.Add(NewItemTexts[ColumnIndex]);

  FillChar(ListItem, SizeOf(ListItem), 0);
  ListItem.mask := LVIF_TEXT or LVIF_PARAM;
  ListItem.iItem := ItemIndex;
  ListItem.lParam := TLParam(ItemData);
  ListItem.pszText := PChar(ItemData^.Text[0]);
  ListItem.cchTextMax := Length(ItemData^.Text[0]);
  SendMessageA(LVData.Window, LVM_SETITEM, 0, TLParam(@ListItem));
  for ColumnIndex := 1 to LastColumnIndex do
  begin
    FillChar(ListItem, SizeOf(ListItem), 0);
    ListItem.mask := LVIF_TEXT;
    ListItem.iItem := ItemIndex;
    ListItem.iSubItem := ColumnIndex;
    ListItem.pszText := PChar(ItemData^.Text[ColumnIndex]);
    ListItem.cchTextMax := Length(ItemData^.Text[ColumnIndex]);
    SendMessageA(LVData.Window, LVM_SETITEM, 0, TLParam(@ListItem));
  end;
  ItemData^.ItemIndex := ItemIndex;
  Result := True;
end;

function LView_CompareListItem(Data1, Data2: LPARAM; SortColumn: integer): integer; stdcall;
var
  ItemData1, ItemData2: PListViewItemData;
begin
  Result := 0;
  if SortColumn < 0 then
    Exit;
  ItemData1 := PListViewItemData(Data1);
  ItemData2 := PListViewItemData(Data2);
  if (ItemData1 = nil) or (ItemData2 = nil) then
    Exit;
  if (ItemData1^.Text = nil) or (ItemData2^.Text = nil) then
    Exit;
  if (SortColumn >= ItemData1^.Text.Count) or (SortColumn >= ItemData2^.Text.Count) then
    Exit;
  Result := CompareText(ItemData1^.Text[SortColumn], ItemData2^.Text[SortColumn]);
end;

function LView_GetItemText(var LVData: TListViewData; ItemIndex, SubItemIndex: integer): string;
var
  ListItem: TLVItem;
  Buffer: array[0..MAX_PATH - 1] of char;
begin
  Result := '';
  if (LVData.Initialized = False) or (ItemIndex < 0) or (SubItemIndex < 0) then
    Exit;

  FillChar(Buffer, SizeOf(Buffer), 0);
  FillChar(ListItem, SizeOf(ListItem), 0);
  ListItem.mask := LVIF_TEXT;
  ListItem.iItem := ItemIndex;
  ListItem.iSubItem := SubItemIndex;
  ListItem.pszText := Buffer;
  ListItem.cchTextMax := SizeOf(Buffer);
  if SendMessageA(LVData.Window, LVM_GETITEM, 0, TLParam(@ListItem)) <> 0 then
    Result := Buffer;
end;

function LView_GetItemData(var LVData: TListViewData; ItemIndex: integer): Pointer;
var
  ItemData: PListViewItemData;
begin
  Result := nil;
  if (LVData.Initialized = False) or (LVData.Items = nil) or (ItemIndex < 0) or (ItemIndex >= LVData.Items.Count) then
    Exit;
  ItemData := PListViewItemData(LVData.Items[ItemIndex]);
  if ItemData <> nil then
    Result := ItemData^.Data;
end;

end.
