unit WebsiteAnalytics.DiagnosticsForm;

interface

uses
  System.SysUtils,
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
  FMX.Memo,
  FMX.Memo.Types,
  FMX.ScrollBox,
  FMX.Objects,
  FMX.Controls.Presentation;

type
  TfrmDiagnostics = class(TForm)
    RootLayout: TLayout;
    HeaderCard: TRectangle;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    StatusCard: TRectangle;
    lblAuthenticationTitle: TLabel;
    lblAuthenticationValue: TLabel;
    lblGA4Title: TLabel;
    lblGA4Value: TLabel;
    lblStorageTitle: TLabel;
    lblStorageValue: TLabel;
    MemoDiagnostics: TMemo;
    btnRunSelfTest: TButton;
    btnClose: TButton;
    procedure FormShow(Sender: TObject);
    procedure btnRunSelfTestClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  end;

var
  frmDiagnostics: TfrmDiagnostics;

implementation

{$R *.fmx}

uses
  WebsiteAnalytics.AnalyticsMemoryDataModule,
  WebsiteAnalytics.AuthenticationDataModule,
  WebsiteAnalytics.GA4DataModule;

procedure TfrmDiagnostics.FormShow(Sender: TObject);
begin
  if dmAuthentication.Authenticated then
    lblAuthenticationValue.Text := 'Connected for this app session'
  else
    lblAuthenticationValue.Text := 'Not connected';
  lblGA4Value.Text := dmGA4.LastStatus;
  MemoDiagnostics.Lines.Add('Diagnostics opened.');
end;

procedure TfrmDiagnostics.btnCloseClick(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TfrmDiagnostics.btnRunSelfTestClick(Sender: TObject);
const
  SampleTrendJson =
    '{"rows":[{"dimensionValues":[{"value":"20260718"}],"metricValues":' +
    '[{"value":"42"},{"value":"51"},{"value":"88"},{"value":"0.64"},{"value":"103"}]}]}';
var
  ReportKind: TGA4ReportKind;
  RequestJson: string;
begin
  MemoDiagnostics.Lines.Add('Running GA4 plumbing self-test...');
  for ReportKind in [grkOverview, grkWeeklyUsers, grkGeography, grkContent,
    grkAcquisition, grkDevices, grkRealtime] do
  begin
    RequestJson := dmGA4.BuildRunReportRequest('7daysAgo', 'today', ReportKind);
    MemoDiagnostics.Lines.Add('Prepared request kind ' + IntToStr(Ord(ReportKind)) +
      ': ' + IntToStr(Length(RequestJson)) + ' bytes');
  end;

  dmAnalyticsMemory.CurrentSnapshot.Clear;
  dmGA4.ParseReportResponse(grkWeeklyUsers, SampleTrendJson,
    dmAnalyticsMemory.CurrentSnapshot);
  MemoDiagnostics.Lines.Add('Parsed trend points: ' +
    IntToStr(dmAnalyticsMemory.CurrentSnapshot.TrendPoints.Count));
  lblGA4Value.Text := dmGA4.LastStatus;
  MemoDiagnostics.Lines.Add('Self-test complete. No Google request was made.');
end;

end.
