unit WebsiteAnalytics.PropertyManagerForm;

interface

uses
  System.SysUtils,
  System.Math,
  System.Types,
  System.UITypes,
  System.Classes,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Edit,
  FMX.Objects,
  FMX.Controls.Presentation;

type
  TfrmPropertyManager = class(TForm)
    RootLayout: TLayout;
    HeaderCard: TRectangle;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    BodyLayout: TLayout;
    PropertyListCard: TRectangle;
    lblPropertyListTitle: TLabel;
    lstProperties: TListBox;
    btnAddProperty: TButton;
    btnRemoveProperty: TButton;
    EditorCard: TRectangle;
    lblEditorTitle: TLabel;
    lblDisplayName: TLabel;
    edtDisplayName: TEdit;
    lblWebsiteAddress: TLabel;
    edtWebsiteAddress: TEdit;
    lblPropertyId: TLabel;
    edtPropertyId: TEdit;
    lblColor: TLabel;
    cmbColor: TComboBox;
    chkEnabled: TCheckBox;
    lblStorageNotice: TLabel;
    btnSaveProperty: TButton;
    btnClose: TButton;
    procedure FormShow(Sender: TObject);
    procedure lstPropertiesChange(Sender: TObject);
    procedure btnAddPropertyClick(Sender: TObject);
    procedure btnRemovePropertyClick(Sender: TObject);
    procedure btnSavePropertyClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    procedure LoadSelectedProperty;
    procedure ReloadPropertyList(const SelectedIndex: Integer = 0);
    function SelectedDisplayColor: TAlphaColor;
    procedure SelectColor(const Color: TAlphaColor);
  end;

var
  frmPropertyManager: TfrmPropertyManager;

implementation

{$R *.fmx}

uses
  FMX.DialogService.Sync,
  WebsiteAnalytics.AnalyticsMemoryDataModule,
  WebsiteAnalytics.SettingsDataModule,
  WebsiteAnalytics.Models;

procedure TfrmPropertyManager.FormShow(Sender: TObject);
begin
  ReloadPropertyList;
end;

procedure TfrmPropertyManager.ReloadPropertyList(const SelectedIndex: Integer);
var
  PropertyIndex: Integer;
begin
  lstProperties.BeginUpdate;
  try
    lstProperties.Clear;
    for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
      lstProperties.Items.Add(dmAnalyticsMemory[PropertyIndex].DisplayName);
    if dmAnalyticsMemory.PropertyCount > 0 then
      lstProperties.ItemIndex := EnsureRange(SelectedIndex, 0,
        dmAnalyticsMemory.PropertyCount - 1)
    else
      lstProperties.ItemIndex := -1;
  finally
    lstProperties.EndUpdate;
  end;
  LoadSelectedProperty;
end;

procedure TfrmPropertyManager.LoadSelectedProperty;
var
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  if (lstProperties.ItemIndex < 0) or
     (lstProperties.ItemIndex >= dmAnalyticsMemory.PropertyCount) then
  begin
    edtDisplayName.Text := '';
    edtWebsiteAddress.Text := '';
    edtPropertyId.Text := '';
    chkEnabled.IsChecked := False;
    Exit;
  end;
  WebsiteProperty := dmAnalyticsMemory[lstProperties.ItemIndex];
  edtDisplayName.Text := WebsiteProperty.DisplayName;
  edtWebsiteAddress.Text := WebsiteProperty.WebsiteAddress;
  edtPropertyId.Text := WebsiteProperty.PropertyId;
  chkEnabled.IsChecked := WebsiteProperty.Enabled;
  SelectColor(WebsiteProperty.DisplayColor);
end;

procedure TfrmPropertyManager.lstPropertiesChange(Sender: TObject);
begin
  LoadSelectedProperty;
end;

function TfrmPropertyManager.SelectedDisplayColor: TAlphaColor;
begin
  case cmbColor.ItemIndex of
    0: Result := $FFB7791F;
    1: Result := $FF1974DF;
    2: Result := $FF168C8C;
  else
    Result := $FF365674;
  end;
end;

procedure TfrmPropertyManager.SelectColor(const Color: TAlphaColor);
begin
  case Color of
    $FFB7791F: cmbColor.ItemIndex := 0;
    $FF1974DF: cmbColor.ItemIndex := 1;
    $FF168C8C: cmbColor.ItemIndex := 2;
  else
    cmbColor.ItemIndex := 3;
  end;
end;

procedure TfrmPropertyManager.btnAddPropertyClick(Sender: TObject);
var
  NewPropertyIndex: Integer;
begin
  NewPropertyIndex := dmAnalyticsMemory.AddProperty('New Website', 'https://',
    '', $FF365674, True);
  dmSettings.SavePropertiesFromMemory(dmAnalyticsMemory);
  ReloadPropertyList(NewPropertyIndex);
  edtDisplayName.SetFocus;
end;

procedure TfrmPropertyManager.btnRemovePropertyClick(Sender: TObject);
var
  SelectedIndex: Integer;
begin
  SelectedIndex := lstProperties.ItemIndex;
  if SelectedIndex < 0 then
    Exit;
  if TDialogServiceSync.MessageDialog(
    'Remove the selected property from this session?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,
    0) = mrYes then
  begin
    dmAnalyticsMemory.DeleteProperty(SelectedIndex);
    dmSettings.SavePropertiesFromMemory(dmAnalyticsMemory);
    ReloadPropertyList(SelectedIndex - 1);
  end;
end;

procedure TfrmPropertyManager.btnSavePropertyClick(Sender: TObject);
var
  SelectedIndex: Integer;
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  SelectedIndex := lstProperties.ItemIndex;
  if (SelectedIndex < 0) or (Trim(edtDisplayName.Text) = '') then
    Exit;
  WebsiteProperty := dmAnalyticsMemory[SelectedIndex];
  WebsiteProperty.DisplayName := Trim(edtDisplayName.Text);
  WebsiteProperty.WebsiteAddress := Trim(edtWebsiteAddress.Text);
  WebsiteProperty.PropertyId := Trim(edtPropertyId.Text);
  WebsiteProperty.DisplayColor := SelectedDisplayColor;
  WebsiteProperty.Enabled := chkEnabled.IsChecked;
  dmSettings.SavePropertiesFromMemory(dmAnalyticsMemory);
  ReloadPropertyList(SelectedIndex);
end;

procedure TfrmPropertyManager.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

end.
