program WebsiteAnalytics;

uses
  System.StartUpCopy,
  FMX.Forms,
  WebsiteAnalytics.MainForm in 'WebsiteAnalytics.MainForm.pas' {frmMainDashboard},
  WebsiteAnalytics.PropertyManagerForm in 'WebsiteAnalytics.PropertyManagerForm.pas' {frmPropertyManager},
  WebsiteAnalytics.SettingsForm in 'WebsiteAnalytics.SettingsForm.pas' {frmSettings},
  WebsiteAnalytics.DiagnosticsForm in 'WebsiteAnalytics.DiagnosticsForm.pas' {frmDiagnostics},
  WebsiteAnalytics.Models in 'WebsiteAnalytics.Models.pas',
  WebsiteAnalytics.AnalyticsMemoryDataModule in 'WebsiteAnalytics.AnalyticsMemoryDataModule.pas' {dmAnalyticsMemory: TDataModule},
  WebsiteAnalytics.SettingsDataModule in 'WebsiteAnalytics.SettingsDataModule.pas' {dmSettings: TDataModule},
  WebsiteAnalytics.AuthenticationDataModule in 'WebsiteAnalytics.AuthenticationDataModule.pas' {dmAuthentication: TDataModule},
  WebsiteAnalytics.GA4DataModule in 'WebsiteAnalytics.GA4DataModule.pas' {dmGA4: TDataModule};

{$R *.res}

begin
  Application.Initialize;
  dmAnalyticsMemory := TdmAnalyticsMemory.Create(Application);
  dmSettings := TdmSettings.Create(Application);
  dmSettings.Initialize;
  dmSettings.LoadPropertiesIntoMemory(dmAnalyticsMemory);
  dmAuthentication := TdmAuthentication.Create(Application);
  dmGA4 := TdmGA4.Create(Application);
  Application.CreateForm(TfrmMainDashboard, frmMainDashboard);
  Application.CreateForm(TfrmPropertyManager, frmPropertyManager);
  Application.CreateForm(TfrmSettings, frmSettings);
  Application.CreateForm(TfrmDiagnostics, frmDiagnostics);
  Application.Run;
end.
