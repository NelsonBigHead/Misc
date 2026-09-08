unit TrayIconEx2;

interface

uses
  Windows, Messages, ShellAPI, SysUtils, Graphics, Forms, Classes;

type
  TTrayIcon = class
  private
    FData: TNotifyIconData;
    FVisible: Boolean;
    FIcon: TIcon;
    FHint: string;
    FOnDblClick: TNotifyEvent;
    FOnContextMenu: TNotifyEvent;
    procedure SetVisible(const Value: Boolean);
    procedure SetIcon(const Value: TIcon);
    procedure SetHint(const Value: string);
  public
    constructor Create(AOwner: TForm; ACallbackMsg: UINT; AIconID: Cardinal);
    destructor Destroy; override;
    procedure HandleResponse(var Msg: TMessage);
    procedure SetIconFromHandle(AIconHandle: HICON);
    property Visible: Boolean read FVisible write SetVisible;
    property Icon: TIcon read FIcon write SetIcon;
    property Hint: string read FHint write SetHint;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnContextMenu: TNotifyEvent read FOnContextMenu write FOnContextMenu;
  end;

implementation

constructor TTrayIcon.Create(AOwner: TForm; ACallbackMsg: UINT; AIconID: Cardinal);
begin
  inherited Create;
  FIcon := TIcon.Create;
  
  FillChar(FData, SizeOf(FData), 0);
  FData.cbSize := SizeOf(FData);
  FData.hWnd := AOwner.Handle;
  FData.uID := AIconID;
  FData.uFlags := NIF_MESSAGE;
  FData.uCallbackMessage := ACallbackMsg;
  FVisible := False;
end;

destructor TTrayIcon.Destroy;
begin
  Visible := False;
  FIcon.Free;
  inherited Destroy;
end;

procedure TTrayIcon.HandleResponse(var Msg: TMessage);
begin
  case Msg.LParam of
    WM_RBUTTONUP:
      if Assigned(FOnContextMenu) then FOnContextMenu(Self);
    WM_LBUTTONDBLCLK:
      if Assigned(FOnDblClick) then FOnDblClick(Self);
  end;
end;

procedure TTrayIcon.SetIconFromHandle(AIconHandle: HICON);
begin
  FData.hIcon := AIconHandle;
  
  if AIconHandle <> 0 then
    FIcon.Handle := AIconHandle;

  if FVisible then
  begin
    FData.uFlags := FData.uFlags or NIF_ICON;
    Shell_NotifyIconA(NIM_MODIFY, @FData);
  end;
end;

procedure TTrayIcon.SetHint(const Value: string);
begin
  FHint := Value;
  StrLCopy(FData.szTip, PChar(Value), SizeOf(FData.szTip) - 1);
  if FVisible then
  begin
    FData.uFlags := FData.uFlags or NIF_TIP;
    Shell_NotifyIconA(NIM_MODIFY, @FData);
  end;
end;

procedure TTrayIcon.SetIcon(const Value: TIcon);
begin
  FIcon.Assign(Value);
  FData.hIcon := FIcon.Handle;
  if FVisible then
  begin
    FData.uFlags := FData.uFlags or NIF_ICON;
    Shell_NotifyIconA(NIM_MODIFY, @FData);
  end;
end;

procedure TTrayIcon.SetVisible(const Value: Boolean);
begin
  if FVisible <> Value then
  begin
    FVisible := Value;
    FData.uFlags := NIF_MESSAGE;
    
    if FData.hIcon <> 0 then
      FData.uFlags := FData.uFlags or NIF_ICON;
    if FHint <> '' then
      FData.uFlags := FData.uFlags or NIF_TIP;

    if FVisible then
      Shell_NotifyIconA(NIM_ADD, @FData)
    else
      Shell_NotifyIconA(NIM_DELETE, @FData);
  end;
end;

end.

