unit WebsiteAnalytics.SettingsForm;

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
  TfrmSettings = class(TForm)
    RootLayout: TLayout;
    HeaderCard: TRectangle;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    SettingsCard: TRectangle;
    lblDefaultWebsite: TLabel;
    cmbDefaultWebsite: TComboBox;
    lblDefaultRange: TLabel;
    cmbDefaultRange: TComboBox;
    chkRefreshAtStartup: TCheckBox;
    chkPreviousPeriod: TCheckBox;
    lblGA4Setup: TLabel;
    lblOAuthClientId: TLabel;
    edtOAuthClientId: TEdit;
    lblOAuthClientSecret: TLabel;
    edtOAuthClientSecret: TEdit;
    btnToggleOAuthSecret: TButton;
    lblOAuthRedirectPort: TLabel;
    edtOAuthRedirectPort: TEdit;
    lblOAuthRedirectUri: TLabel;
    lblOAuthSetupHelp: TLabel;
    btnConnectGoogle: TButton;
    btnDisconnectGoogle: TButton;
    lblOAuthStatus: TLabel;
    lblThemeNotice: TLabel;
    lblStorageNotice: TLabel;
    btnClose: TButton;
    OAuthStatusTimer: TTimer;
    procedure FormShow(Sender: TObject);
    procedure btnConnectGoogleClick(Sender: TObject);
    procedure btnDisconnectGoogleClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
    procedure btnToggleOAuthSecretClick(Sender: TObject);
    procedure edtOAuthRedirectPortChange(Sender: TObject);
    procedure OAuthStatusTimerTimer(Sender: TObject);
  private
    FSecretVisible: Boolean;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure RefreshOAuthStatus;
    procedure UpdateSecretVisibility;
  end;

var
  frmSettings: TfrmSettings;

implementation

{$R *.fmx}

uses
  WebsiteAnalytics.AnalyticsMemoryDataModule,
  WebsiteAnalytics.AuthenticationDataModule,
  WebsiteAnalytics.SettingsDataModule;

procedure TfrmSettings.FormShow(Sender: TObject);
begin
  FSecretVisible := False;
  LoadSettings;
  UpdateSecretVisibility;
  RefreshOAuthStatus;
  OAuthStatusTimer.Enabled := True;
end;

procedure TfrmSettings.LoadSettings;
var
  PropertyIndex: Integer;
begin
  cmbDefaultWebsite.BeginUpdate;
  try
    cmbDefaultWebsite.Clear;
    cmbDefaultWebsite.Items.Add('All websites');
    for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
      cmbDefaultWebsite.Items.Add(dmAnalyticsMemory[PropertyIndex].DisplayName);
  finally
    cmbDefaultWebsite.EndUpdate;
  end;

  cmbDefaultWebsite.ItemIndex := StrToIntDef(
    dmSettings.ReadSetting('default_website_index', '0'), 0);
  if cmbDefaultWebsite.Items.Count > 0 then
    cmbDefaultWebsite.ItemIndex := EnsureRange(cmbDefaultWebsite.ItemIndex, 0,
      cmbDefaultWebsite.Items.Count - 1);
  cmbDefaultRange.ItemIndex := StrToIntDef(
    dmSettings.ReadSetting('default_date_range_index', '2'), 2);
  cmbDefaultRange.ItemIndex := EnsureRange(cmbDefaultRange.ItemIndex, 0,
    cmbDefaultRange.Items.Count - 1);
  chkRefreshAtStartup.IsChecked :=
    dmSettings.ReadSetting('refresh_at_startup', '1') = '1';
  chkPreviousPeriod.IsChecked :=
    dmSettings.ReadSetting('compare_previous_period', '1') = '1';
  edtOAuthClientId.Text := dmSettings.ReadSetting('ga4_oauth_client_id', '');
  edtOAuthClientSecret.Text := dmSettings.ReadSetting('ga4_oauth_client_secret',
    '');
  edtOAuthRedirectPort.Text := dmSettings.ReadSetting('ga4_oauth_redirect_port',
    '53682');
  RefreshOAuthStatus;
end;

procedure TfrmSettings.SaveSettings;
begin
  dmSettings.WriteSetting('default_website_index',
    IntToStr(cmbDefaultWebsite.ItemIndex), 'dashboard',
    'Default selected website, where 0 means all websites');
  dmSettings.WriteSetting('default_date_range_index',
    IntToStr(cmbDefaultRange.ItemIndex), 'dashboard',
    'Default date range selection');
  if chkRefreshAtStartup.IsChecked then
    dmSettings.WriteSetting('refresh_at_startup', '1', 'dashboard',
      'Retrieve GA4 data when the program opens after authentication is configured')
  else
    dmSettings.WriteSetting('refresh_at_startup', '0', 'dashboard',
      'Retrieve GA4 data when the program opens after authentication is configured');
  if chkPreviousPeriod.IsChecked then
    dmSettings.WriteSetting('compare_previous_period', '1', 'dashboard',
      'Compare the selected period with the previous period')
  else
    dmSettings.WriteSetting('compare_previous_period', '0', 'dashboard',
      'Compare the selected period with the previous period');
  dmSettings.WriteSetting('ga4_oauth_client_id', Trim(edtOAuthClientId.Text),
    'ga4', 'Google Cloud desktop OAuth client ID');
  dmSettings.WriteSetting('ga4_oauth_client_secret',
    Trim(edtOAuthClientSecret.Text), 'ga4',
    'Google Cloud desktop OAuth client secret for token exchange when required');
  dmSettings.WriteSetting('ga4_oauth_redirect_port',
    Trim(edtOAuthRedirectPort.Text), 'ga4',
    'Local loopback port used for Google OAuth desktop sign-in');
end;

procedure TfrmSettings.btnConnectGoogleClick(Sender: TObject);
begin
  SaveSettings;
  if dmAuthentication.StartDesktopOAuth(Trim(edtOAuthClientId.Text),
    Trim(edtOAuthClientSecret.Text),
    Trim(edtOAuthRedirectPort.Text)) then
    lblOAuthStatus.Text := 'Google sign-in opened in your browser'
  else
    RefreshOAuthStatus;
end;

procedure TfrmSettings.btnCloseClick(Sender: TObject);
begin
  OAuthStatusTimer.Enabled := False;
  SaveSettings;
  ModalResult := mrOk;
end;

procedure TfrmSettings.btnDisconnectGoogleClick(Sender: TObject);
begin
  dmAuthentication.ClearAccessToken;
  dmAuthentication.ClearSavedRefreshToken;
  RefreshOAuthStatus;
end;

procedure TfrmSettings.btnToggleOAuthSecretClick(Sender: TObject);
begin
  FSecretVisible := not FSecretVisible;
  UpdateSecretVisibility;
end;

procedure TfrmSettings.edtOAuthRedirectPortChange(Sender: TObject);
begin
  RefreshOAuthStatus;
end;

procedure TfrmSettings.OAuthStatusTimerTimer(Sender: TObject);
begin
  RefreshOAuthStatus;
end;

procedure TfrmSettings.RefreshOAuthStatus;
begin
  lblOAuthRedirectUri.Text := 'Redirect URI: ' +
    dmAuthentication.DesktopRedirectUri(Trim(edtOAuthRedirectPort.Text));

  if dmAuthentication.Authenticated then
  begin
    btnConnectGoogle.Enabled := False;
    btnDisconnectGoogle.Enabled := True;
    lblOAuthStatus.Text := 'Connected. Click Save and Close.'
  end
  else if Trim(edtOAuthClientId.Text) = '' then
  begin
    btnConnectGoogle.Enabled := True;
    btnDisconnectGoogle.Enabled := False;
    lblOAuthStatus.Text := 'Enter the OAuth desktop client ID, then use Connect Google'
  end
  else if dmAuthentication.LastStatus <> '' then
  begin
    btnConnectGoogle.Enabled := True;
    btnDisconnectGoogle.Enabled := True;
    lblOAuthStatus.Text := dmAuthentication.LastStatus
  end
  else
  begin
    btnConnectGoogle.Enabled := True;
    btnDisconnectGoogle.Enabled := True;
    lblOAuthStatus.Text := 'Not connected';
  end;
end;

procedure TfrmSettings.UpdateSecretVisibility;
begin
  edtOAuthClientSecret.Password := not FSecretVisible;
  if FSecretVisible then
    btnToggleOAuthSecret.Text := 'Hide'
  else
    btnToggleOAuthSecret.Text := 'Show';
end;

end.
