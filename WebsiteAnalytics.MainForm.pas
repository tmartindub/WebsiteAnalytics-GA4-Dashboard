unit WebsiteAnalytics.MainForm;

interface

uses
  System.SysUtils,
  System.Math,
  System.Types,
  System.UITypes,
  System.Classes,
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.IOUtils,
  FMX.Types,
  FMX.Controls,
  FMX.Forms,
  FMX.Graphics,
  FMX.Dialogs,
  FMX.StdCtrls,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Grid,
  FMX.Grid.Style,
  FMX.TabControl,
  FMX.DateTimeCtrls,
  FMX.Objects,
  FMX.Controls.Presentation,
  Winapi.Windows,
  Winapi.ShellAPI,
  WebsiteAnalytics.Models, System.Rtti, FMX.ScrollBox, FMX.BehaviorManager;

type
  TLocationListMode = (llmAllLocations, llmUnitedStates, llmInternational);
  TContentListMode = (clmAllRows, clmPagesOnly, clmDownloadsOnly, clmActionsOnly);
  TTrendMetricKind = (tmkUsers, tmkSessions, tmkViews, tmkEngagement, tmkEvents);

  TfrmMainDashboard = class(TForm)
    RootLayout: TLayout;
    HeroCard: TRectangle;
    imgAppLogo: TImage;
    lblApplicationTitle: TLabel;
    lblApplicationSubtitle: TLabel;
    lblConnectionCaption: TLabel;
    lblConnectionStatus: TLabel;
    HeroControlPanel: TRectangle;
    HeroToolsLayout: TLayout;
    btnUpdate: TButton;
    btnHelp: TButton;
    btnTopManageProperties: TButton;
    btnTopSettings: TButton;
    btnTopDiagnostics: TButton;
    BodyLayout: TLayout;
    NavigationPanel: TRectangle;
    lblNavigationTitle: TLabel;
    btnOverview: TButton;
    btnComparison: TButton;
    btnAcquisition: TButton;
    btnContent: TButton;
    btnEngagement: TButton;
    btnAudience: TButton;
    btnRealtime: TButton;
    btnDiagnosticsSection: TButton;
    NavigationSpacer: TLayout;
    btnManageProperties: TButton;
    btnSettings: TButton;
    btnDiagnostics: TButton;
    ContentLayout: TLayout;
    RoundedTabsBar: TFlowLayout;
    rtabUSA: TRectangle;
    lblRtabUSA: TLabel;
    rtabSessionsByDate: TRectangle;
    lblRtabSessionsByDate: TLabel;
    rtabDownloads: TRectangle;
    lblRtabDownloads: TLabel;
    rtabSources: TRectangle;
    lblRtabSources: TLabel;
    rtabDevices: TRectangle;
    lblRtabDevices: TLabel;
    rtabLanguages: TRectangle;
    lblRtabLanguages: TLabel;
    rtabCountries: TRectangle;
    lblRtabCountries: TLabel;
    rtabRealtime: TRectangle;
    lblRtabRealtime: TLabel;
    rtabProperties: TRectangle;
    lblRtabProperties: TLabel;
    rtabSettings: TRectangle;
    lblRtabSettings: TLabel;
    rtabDiagnostics: TRectangle;
    lblRtabDiagnostics: TLabel;
    DashboardTabs: TTabControl;
    tabGeography: TTabItem;
    tabSessionsByDate: TTabItem;
    tabDownloads: TTabItem;
    tabSources: TTabItem;
    tabDevices: TTabItem;
    tabLanguages: TTabItem;
    tabCountries: TTabItem;
    tabRealtime: TTabItem;
    tabProperties: TTabItem;
    tabSettings: TTabItem;
    tabDiagnostics: TTabItem;
    FilterCard: TRectangle;
    lblWebsiteCaption: TLabel;
    cmbWebsite: TComboBox;
    lblDateRangeCaption: TLabel;
    cmbDateRange: TComboBox;
    chkComparePrevious: TCheckBox;
    chkAutoUpdate: TCheckBox;
    lblRefreshStatus: TLabel;
    DashboardPanel: TRectangle;
    KpiFlow: TFlowLayout;
    KpiUsersCard: TRectangle;
    lblUsersTitle: TLabel;
    lblUsersValue: TLabel;
    lblUsersDelta: TLabel;
    KpiSessionsCard: TRectangle;
    lblSessionsTitle: TLabel;
    lblSessionsValue: TLabel;
    lblSessionsDelta: TLabel;
    KpiViewsCard: TRectangle;
    lblViewsTitle: TLabel;
    lblViewsValue: TLabel;
    lblViewsDelta: TLabel;
    KpiEngagementCard: TRectangle;
    lblEngagementTitle: TLabel;
    lblEngagementValue: TLabel;
    lblEngagementDelta: TLabel;
    EmptyStateCard: TRectangle;
    AnalyticsPreviewLayout: TLayout;
    RightQuadrantsLayout: TLayout;
    TileSummaryCard: TRectangle;
    TileSummaryFlow: TFlowLayout;
    TileUsersTodayCard: TRectangle;
    lblTileUsersTodayTitle: TLabel;
    lblTileUsersTodayValue: TLabel;
    TileUsersRangeCard: TRectangle;
    lblTileUsersRangeTitle: TLabel;
    lblTileUsersRangeValue: TLabel;
    TileViewsTodayCard: TRectangle;
    lblTileViewsTodayTitle: TLabel;
    lblTileViewsTodayValue: TLabel;
    TileDownloadsTodayCard: TRectangle;
    lblTileDownloadsTodayTitle: TLabel;
    lblTileDownloadsTodayValue: TLabel;
    TileActiveNowCard: TRectangle;
    lblTileActiveNowTitle: TLabel;
    lblTileActiveNowValue: TLabel;
    TileLastLocationCard: TRectangle;
    lblTileLastLocationTitle: TLabel;
    lblTileLastLocationValue: TLabel;
    TileTopPageCard: TRectangle;
    lblTileTopPageTitle: TLabel;
    lblTileTopPageValue: TLabel;
    TileRealtimeViewsCard: TRectangle;
    lblTileRealtimeViewsTitle: TLabel;
    lblTileRealtimeViewsValue: TLabel;
    WeeklyUsersChartCard: TRectangle;
    lblWeeklyUsersTitle: TLabel;
    cmbChartMetric: TComboBox;
    pbWeeklyUsers: TPaintBox;
    TrendTooltip: TRectangle;
    lblTrendTooltip: TLabel;
    RightInsightsLayout: TLayout;
    GeographyPreviewCard: TRectangle;
    lblGeographyTitle: TLabel;
    lblGeographyRows: TLabel;
    lblSessionsByDatePicker: TLabel;
    dtSessionsByDate: TDateEdit;
    btnSessionsByDateRefresh: TButton;
    grdGeographyRows: TStringGrid;
    colGeographyCountry: TStringColumn;
    colGeographyRegion: TStringColumn;
    colGeographyCity: TStringColumn;
    colGeographyUsers: TStringColumn;
    colGeographySessions: TStringColumn;
    colGeographyEngagement: TStringColumn;
    ContentPreviewCard: TRectangle;
    lblContentTitle: TLabel;
    lblContentRows: TLabel;
    cmbContentFilter: TComboBox;
    grdContentRows: TStringGrid;
    colContentTitle: TStringColumn;
    colContentPath: TStringColumn;
    colContentAction: TStringColumn;
    colContentViews: TStringColumn;
    colContentUsers: TStringColumn;
    colContentEvents: TStringColumn;
    colContentEngagement: TStringColumn;
    pbTopPagesDownloads: TPaintBox;
    TopPagesTooltip: TRectangle;
    lblTopPagesTooltip: TLabel;
    RealtimePreviewCard: TRectangle;
    lblRealtimeTitle: TLabel;
    lblRealtimeActiveCaption: TLabel;
    lblRealtimeActiveValue: TLabel;
    lblRealtimeActivity: TLabel;
    lblMemoryOnlyNotice: TLabel;
    StatusBar: TRectangle;
    lblStatusBar: TLabel;
    AuthStartupTimer: TTimer;
    AutoUpdateTimer: TTimer;
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure AuthStartupTimerTimer(Sender: TObject);
    procedure AutoUpdateTimerTimer(Sender: TObject);
    procedure btnUpdateClick(Sender: TObject);
    procedure btnHelpClick(Sender: TObject);
    procedure NavigationButtonClick(Sender: TObject);
    procedure btnManagePropertiesClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure btnDiagnosticsClick(Sender: TObject);
    procedure DashboardTabsChange(Sender: TObject);
    procedure pbWeeklyUsersPaint(Sender: TObject; Canvas: TCanvas);
    procedure pbWeeklyUsersMouseLeave(Sender: TObject);
    procedure pbWeeklyUsersMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure pbTopPagesDownloadsPaint(Sender: TObject; Canvas: TCanvas);
    procedure pbTopPagesDownloadsMouseLeave(Sender: TObject);
    procedure pbTopPagesDownloadsMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure RoundedTabClick(Sender: TObject);
    procedure chkAutoUpdateChange(Sender: TObject);
    procedure chkComparePreviousChange(Sender: TObject);
    procedure cmbDateRangeChange(Sender: TObject);
    procedure cmbWebsiteChange(Sender: TObject);
    procedure cmbChartMetricChange(Sender: TObject);
    procedure cmbContentFilterChange(Sender: TObject);
    procedure dtSessionsByDateChange(Sender: TObject);
    procedure btnSessionsByDateRefreshClick(Sender: TObject);
    procedure GridColumnResize(Sender: TObject);
  private
    FStartupAuthStarted: Boolean;
    FStartupUpdateDone: Boolean;
    FLastReportTabIndex: Integer;
    FLocationListMode: TLocationListMode;
    FContentListMode: TContentListMode;
    FGridColumnWidthSavingEnabled: Boolean;
    FSelectorChangeEnabled: Boolean;
    FLoadingGridColumnWidths: Boolean;
    FLastRealtimeActivityText: string;
    FLastLocationTileText: string;
    function CompareAcquisitionRowsAlphabetically(const Left, Right: TGA4AcquisitionRow): Integer;
    function CompareContentRowsAlphabetically(const Left, Right: TGA4ContentRow): Integer;
    function CompareDeviceRowsAlphabetically(const Left, Right: TGA4DeviceRow): Integer;
    function CompareGeographyRowsAlphabetically(const Left, Right: TGA4GeographyRow): Integer;
    function CompareLanguageRowsAlphabetically(const Left, Right: TGA4LanguageRow): Integer;
    function CompareSessionsByDateRowsAlphabetically(const Left, Right: TGA4SessionsByDateRow): Integer;
    function CleanLocationText(const Value, FallbackText: string): string;
    function ContentActionText(const ContentRow: TGA4ContentRow): string;
    function ContentRowMatchesView(const ContentRow: TGA4ContentRow): Boolean;
    function FindHelpIndexPath: string;
    function FormatTrendScaleValue(const Value: Double): string;
    function FormatTrendTooltipValue(const Value: Double): string;
    function FormatComparisonDelta(const CurrentValue, PreviousValue: Double;
      const IsRate: Boolean): string;
    function ComparisonDeltaColor(const CurrentValue, PreviousValue: Double): TAlphaColor;
    function DateToGA4String(const Value: TDateTime): string;
    function IsTokenRefreshableError(const ErrorText: string): Boolean;
    function IsAllWebsitesSelected: Boolean;
    function LocationRowMatchesView(const GeographyRow: TGA4GeographyRow): Boolean;
    function SelectedWebsiteDisplayName: string;
    function GridColumnWidthSettingName(const Column: TColumn): string;
    function SelectedDateRangeCaption: string;
    function SelectedTrendCaption: string;
    function SelectedTrendValue(const TrendPoint: TGA4TrendPoint): Double;
    procedure AdjustQuadrantProportions;
    procedure BuildTrendChartData(const PaintBox: TPaintBox; out ChartRect: TRectF;
      out Points: TArray<TPointF>; out Values: TArray<Double>;
      out Labels: TArray<string>; out ScaleMax: Double);
    procedure BuildTopPagesChartData(const PaintBox: TPaintBox; out ChartRect: TRectF;
      out Labels: TArray<string>; out Values: TArray<Double>;
      out ScaleMax: Double);
    procedure HideTrendTooltip;
    procedure HideTopPagesTooltip;
    procedure LoadGridColumnWidth(const Column: TColumn);
    procedure LoadGridColumnWidths;
    procedure ConfigureGeographyGridColumns(const FirstHeader, SecondHeader,
      ThirdHeader, FourthHeader, FifthHeader, SixthHeader: string);
    procedure PopulateAcquisitionRows(const Snapshot: TGA4ReportSnapshot);
    procedure PopulateContentRows(const Snapshot: TGA4ReportSnapshot);
    procedure PopulateDeviceRows(const Snapshot: TGA4ReportSnapshot);
    procedure PopulateGeographyRows(const Snapshot: TGA4ReportSnapshot);
    procedure PopulateLanguageRows(const Snapshot: TGA4ReportSnapshot);
    procedure SelectedPreviousDateRange(out StartDate, EndDate: string);
    procedure RefreshPropertySelector;
    procedure SaveGridColumnWidth(const Column: TColumn);
    procedure SelectSection(const SectionIndex: Integer);
    procedure RefreshDashboardForSelectorChange(const ReasonText: string);
    procedure SetRoundedTabStyle(const TabShape: TRectangle; const IsSelected: Boolean);
    procedure MergeSnapshotIntoCurrent(const SourceSnapshot: TGA4ReportSnapshot);
    procedure FetchPropertyReportsWithTokenRefresh(const WebsiteProperty: TWebsitePropertyDefinition;
      const StartDate, EndDate: string; const TargetSnapshot: TGA4ReportSnapshot);
    procedure FetchReportsWithTokenRefresh(const WebsiteProperty: TWebsitePropertyDefinition;
      const StartDate, EndDate: string);
    procedure FetchAllWebsiteReportsWithTokenRefresh(const StartDate, EndDate: string);
    procedure FetchSessionsByDateWithTokenRefresh(const WebsiteProperty: TWebsitePropertyDefinition;
      const ReportDate: string);
    procedure RefreshSessionsByDate;
    procedure PopulateRealtimePanel(const Snapshot: TGA4ReportSnapshot);
    procedure PopulateSessionsByDateRows(const Snapshot: TGA4ReportSnapshot);
    procedure ShowContentTable;
    procedure ShowLocationTable;
    procedure ShowRealtimePanel;
    procedure SelectedDateRange(out StartDate, EndDate: string);
    procedure UpdateChartTitle;
    procedure UpdateComparisonLabels(const Snapshot: TGA4ReportSnapshot);
    procedure UpdateDashboardFromSnapshot(const Snapshot: TGA4ReportSnapshot);
    procedure UpdatePreviewForSection(const SectionIndex: Integer);
    procedure UpdateSummaryTiles(const Snapshot: TGA4ReportSnapshot);
    procedure UpdateRoundedTabStyles;
    function SelectedPropertyForUpdate: TWebsitePropertyDefinition;
  end;

var
  frmMainDashboard: TfrmMainDashboard;

implementation

{$R *.fmx}

uses
  WebsiteAnalytics.AnalyticsMemoryDataModule,
  WebsiteAnalytics.AuthenticationDataModule,
  WebsiteAnalytics.GA4DataModule,
  WebsiteAnalytics.SettingsDataModule,
  WebsiteAnalytics.PropertyManagerForm,
  WebsiteAnalytics.SettingsForm,
  WebsiteAnalytics.DiagnosticsForm;

const
  SECTION_USA = 0;
  SECTION_SESSIONS_BY_DATE = 1;
  SECTION_DOWNLOADS = 2;
  SECTION_SOURCES = 3;
  SECTION_DEVICES = 4;
  SECTION_LANGUAGES = 5;
  SECTION_COUNTRIES = 6;
  SECTION_REALTIME = 7;
  SECTION_PROPERTIES = 8;
  SECTION_SETTINGS = 9;
  SECTION_DIAGNOSTICS = 10;
  MAX_REPORT_SECTION = SECTION_REALTIME;

function TfrmMainDashboard.IsAllWebsitesSelected: Boolean;
begin
  Result := cmbWebsite.ItemIndex = 0;
end;

function TfrmMainDashboard.SelectedWebsiteDisplayName: string;
var
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  if IsAllWebsitesSelected then
    Exit('All websites');

  WebsiteProperty := SelectedPropertyForUpdate;
  if Assigned(WebsiteProperty) then
    Result := WebsiteProperty.DisplayName
  else
    Result := 'selected website';
end;

procedure TfrmMainDashboard.MergeSnapshotIntoCurrent(
  const SourceSnapshot: TGA4ReportSnapshot);
var
  ContentIndex: Integer;
  ContentKey: string;
  ContentMap: TDictionary<string, Integer>;
  ContentRow: TGA4ContentRow;
  ExistingContentRow: TGA4ContentRow;
  ExistingEngagementWeight: Double;
  ExistingTrendPoint: TGA4TrendPoint;
  GeographyIndex: Integer;
  GeographyKey: string;
  GeographyMap: TDictionary<string, Integer>;
  GeographyRow: TGA4GeographyRow;
  ExistingGeographyRow: TGA4GeographyRow;
  KpiSessionTotal: Double;
  PreviousKpiSessionTotal: Double;
  TargetIndex: Integer;
  TargetSnapshot: TGA4ReportSnapshot;
  TrendIndex: Integer;
  TrendKey: Integer;
  TrendMap: TDictionary<Integer, Integer>;
  TrendPoint: TGA4TrendPoint;
begin
  if not Assigned(SourceSnapshot) then
    Exit;

  TargetSnapshot := dmAnalyticsMemory.CurrentSnapshot;
  if not Assigned(TargetSnapshot) then
    Exit;

  KpiSessionTotal := TargetSnapshot.KpiSummary.Sessions +
    SourceSnapshot.KpiSummary.Sessions;
  if KpiSessionTotal > 0 then
    TargetSnapshot.KpiSummary.EngagementRate :=
      ((TargetSnapshot.KpiSummary.EngagementRate *
        TargetSnapshot.KpiSummary.Sessions) +
       (SourceSnapshot.KpiSummary.EngagementRate *
        SourceSnapshot.KpiSummary.Sessions)) / KpiSessionTotal;
  TargetSnapshot.KpiSummary.ActiveUsers :=
    TargetSnapshot.KpiSummary.ActiveUsers + SourceSnapshot.KpiSummary.ActiveUsers;
  TargetSnapshot.KpiSummary.Sessions :=
    TargetSnapshot.KpiSummary.Sessions + SourceSnapshot.KpiSummary.Sessions;
  TargetSnapshot.KpiSummary.ScreenPageViews :=
    TargetSnapshot.KpiSummary.ScreenPageViews +
    SourceSnapshot.KpiSummary.ScreenPageViews;

  if SourceSnapshot.HasPreviousKpiSummary then
  begin
    PreviousKpiSessionTotal := TargetSnapshot.PreviousKpiSummary.Sessions +
      SourceSnapshot.PreviousKpiSummary.Sessions;
    if PreviousKpiSessionTotal > 0 then
      TargetSnapshot.PreviousKpiSummary.EngagementRate :=
        ((TargetSnapshot.PreviousKpiSummary.EngagementRate *
          TargetSnapshot.PreviousKpiSummary.Sessions) +
         (SourceSnapshot.PreviousKpiSummary.EngagementRate *
          SourceSnapshot.PreviousKpiSummary.Sessions)) /
        PreviousKpiSessionTotal;
    TargetSnapshot.PreviousKpiSummary.ActiveUsers :=
      TargetSnapshot.PreviousKpiSummary.ActiveUsers +
      SourceSnapshot.PreviousKpiSummary.ActiveUsers;
    TargetSnapshot.PreviousKpiSummary.Sessions :=
      TargetSnapshot.PreviousKpiSummary.Sessions +
      SourceSnapshot.PreviousKpiSummary.Sessions;
    TargetSnapshot.PreviousKpiSummary.ScreenPageViews :=
      TargetSnapshot.PreviousKpiSummary.ScreenPageViews +
      SourceSnapshot.PreviousKpiSummary.ScreenPageViews;
    TargetSnapshot.HasPreviousKpiSummary := True;
  end;

  TrendMap := TDictionary<Integer, Integer>.Create;
  GeographyMap := TDictionary<string, Integer>.Create;
  ContentMap := TDictionary<string, Integer>.Create;
  try
    for TrendIndex := 0 to TargetSnapshot.TrendPoints.Count - 1 do
      TrendMap.AddOrSetValue(Trunc(TargetSnapshot.TrendPoints[TrendIndex].DateValue),
        TrendIndex);
    for TrendIndex := 0 to SourceSnapshot.TrendPoints.Count - 1 do
    begin
      TrendPoint := SourceSnapshot.TrendPoints[TrendIndex];
      TrendKey := Trunc(TrendPoint.DateValue);
      if TrendMap.TryGetValue(TrendKey, TargetIndex) then
      begin
        ExistingTrendPoint := TargetSnapshot.TrendPoints[TargetIndex];
        ExistingEngagementWeight := ExistingTrendPoint.Sessions + TrendPoint.Sessions;
        if ExistingEngagementWeight > 0 then
          ExistingTrendPoint.EngagementRate :=
            ((ExistingTrendPoint.EngagementRate * ExistingTrendPoint.Sessions) +
             (TrendPoint.EngagementRate * TrendPoint.Sessions)) /
            ExistingEngagementWeight;
        ExistingTrendPoint.ActiveUsers := ExistingTrendPoint.ActiveUsers +
          TrendPoint.ActiveUsers;
        ExistingTrendPoint.Sessions := ExistingTrendPoint.Sessions +
          TrendPoint.Sessions;
        ExistingTrendPoint.ScreenPageViews := ExistingTrendPoint.ScreenPageViews +
          TrendPoint.ScreenPageViews;
        ExistingTrendPoint.EventCount := ExistingTrendPoint.EventCount +
          TrendPoint.EventCount;
        ExistingTrendPoint.Value := ExistingTrendPoint.ActiveUsers;
        TargetSnapshot.TrendPoints[TargetIndex] := ExistingTrendPoint;
      end
      else
      begin
        TrendMap.Add(TrendKey, TargetSnapshot.TrendPoints.Count);
        TargetSnapshot.TrendPoints.Add(TrendPoint);
      end;
    end;

    for GeographyIndex := 0 to TargetSnapshot.GeographyRows.Count - 1 do
    begin
      GeographyRow := TargetSnapshot.GeographyRows[GeographyIndex];
      GeographyKey := GeographyRow.Country + #9 + GeographyRow.Region + #9 +
        GeographyRow.City;
      GeographyMap.AddOrSetValue(GeographyKey, GeographyIndex);
    end;
    for GeographyIndex := 0 to SourceSnapshot.GeographyRows.Count - 1 do
    begin
      GeographyRow := SourceSnapshot.GeographyRows[GeographyIndex];
      GeographyKey := GeographyRow.Country + #9 + GeographyRow.Region + #9 +
        GeographyRow.City;
      if GeographyMap.TryGetValue(GeographyKey, TargetIndex) then
      begin
        ExistingGeographyRow := TargetSnapshot.GeographyRows[TargetIndex];
        ExistingEngagementWeight := ExistingGeographyRow.Sessions +
          GeographyRow.Sessions;
        if ExistingEngagementWeight > 0 then
          ExistingGeographyRow.EngagementRate :=
            ((ExistingGeographyRow.EngagementRate *
              ExistingGeographyRow.Sessions) +
             (GeographyRow.EngagementRate * GeographyRow.Sessions)) /
            ExistingEngagementWeight;
        ExistingGeographyRow.ActiveUsers := ExistingGeographyRow.ActiveUsers +
          GeographyRow.ActiveUsers;
        ExistingGeographyRow.Sessions := ExistingGeographyRow.Sessions +
          GeographyRow.Sessions;
        TargetSnapshot.GeographyRows[TargetIndex] := ExistingGeographyRow;
      end
      else
      begin
        GeographyMap.Add(GeographyKey, TargetSnapshot.GeographyRows.Count);
        TargetSnapshot.GeographyRows.Add(GeographyRow);
      end;
    end;

    for ContentIndex := 0 to TargetSnapshot.ContentRows.Count - 1 do
    begin
      ContentRow := TargetSnapshot.ContentRows[ContentIndex];
      ContentKey := ContentRow.PagePath + #9 + ContentRow.PageTitle + #9 +
        ContentRow.EventName;
      ContentMap.AddOrSetValue(ContentKey, ContentIndex);
    end;
    for ContentIndex := 0 to SourceSnapshot.ContentRows.Count - 1 do
    begin
      ContentRow := SourceSnapshot.ContentRows[ContentIndex];
      ContentKey := ContentRow.PagePath + #9 + ContentRow.PageTitle + #9 +
        ContentRow.EventName;
      if ContentMap.TryGetValue(ContentKey, TargetIndex) then
      begin
        ExistingContentRow := TargetSnapshot.ContentRows[TargetIndex];
        ExistingContentRow.ScreenPageViews :=
          ExistingContentRow.ScreenPageViews + ContentRow.ScreenPageViews;
        ExistingContentRow.ActiveUsers := ExistingContentRow.ActiveUsers +
          ContentRow.ActiveUsers;
        ExistingContentRow.EventCount := ExistingContentRow.EventCount +
          ContentRow.EventCount;
        ExistingContentRow.EngagementSeconds :=
          ExistingContentRow.EngagementSeconds + ContentRow.EngagementSeconds;
        TargetSnapshot.ContentRows[TargetIndex] := ExistingContentRow;
      end
      else
      begin
        ContentMap.Add(ContentKey, TargetSnapshot.ContentRows.Count);
        TargetSnapshot.ContentRows.Add(ContentRow);
      end;
    end;
  finally
    ContentMap.Free;
    GeographyMap.Free;
    TrendMap.Free;
  end;

  TargetSnapshot.RealtimeSummary.ActiveUsers :=
    TargetSnapshot.RealtimeSummary.ActiveUsers +
    SourceSnapshot.RealtimeSummary.ActiveUsers;
  TargetSnapshot.RealtimeSummary.ScreenPageViews :=
    TargetSnapshot.RealtimeSummary.ScreenPageViews +
    SourceSnapshot.RealtimeSummary.ScreenPageViews;
  if SourceSnapshot.RealtimeSummary.HasLastActivity and
    ((not TargetSnapshot.RealtimeSummary.HasLastActivity) or
     (SourceSnapshot.RealtimeSummary.LastMinutesAgo <
      TargetSnapshot.RealtimeSummary.LastMinutesAgo)) then
  begin
    TargetSnapshot.RealtimeSummary.LastCountry :=
      SourceSnapshot.RealtimeSummary.LastCountry;
    TargetSnapshot.RealtimeSummary.LastCity :=
      SourceSnapshot.RealtimeSummary.LastCity;
    TargetSnapshot.RealtimeSummary.LastMinutesAgo :=
      SourceSnapshot.RealtimeSummary.LastMinutesAgo;
    TargetSnapshot.RealtimeSummary.HasLastActivity := True;
  end;
end;

procedure TfrmMainDashboard.AdjustQuadrantProportions;
const
  ColumnGap = 10;
  RowGap = 10;
var
  LeftColumnWidth: Single;
  LeftTopHeight: Single;
  RightTopHeight: Single;
begin
  if (not Assigned(AnalyticsPreviewLayout)) or
    (not Assigned(RightInsightsLayout)) or
    (not Assigned(RightQuadrantsLayout)) or
    (not Assigned(GeographyPreviewCard)) or
    (not Assigned(ContentPreviewCard)) or
    (not Assigned(WeeklyUsersChartCard)) then
    Exit;

  LeftColumnWidth := Max(300, (AnalyticsPreviewLayout.Width - ColumnGap) / 2);
  RightInsightsLayout.Width := LeftColumnWidth;
  RightInsightsLayout.Margins.Right := ColumnGap;

  LeftTopHeight := Max(160, (RightInsightsLayout.Height - RowGap) * 0.56);
  GeographyPreviewCard.Height := LeftTopHeight;
  GeographyPreviewCard.Margins.Bottom := RowGap;
  ContentPreviewCard.Height := Max(130, RightInsightsLayout.Height -
    LeftTopHeight - RowGap);

  if Assigned(TileSummaryCard) then
  begin
    TileSummaryCard.Height := Max(245, Min(285,
      RightQuadrantsLayout.Height * 0.45));
    TileSummaryCard.Margins.Bottom := RowGap;
  end;

  RightTopHeight := Max(180, RightQuadrantsLayout.Height -
    IfThen(Assigned(TileSummaryCard), TileSummaryCard.Height, 0) - RowGap);
  WeeklyUsersChartCard.Height := RightTopHeight;

  if Assigned(pbWeeklyUsers) then
    pbWeeklyUsers.Repaint;
  if Assigned(pbTopPagesDownloads) then
    pbTopPagesDownloads.Repaint;
end;

procedure TfrmMainDashboard.FormShow(Sender: TObject);
begin
  FSelectorChangeEnabled := False;
  RefreshPropertySelector;
  cmbWebsite.ItemIndex := StrToIntDef(
    dmSettings.ReadSetting('default_website_index', '0'), 0);
  if (cmbWebsite.ItemIndex < 0) or (cmbWebsite.ItemIndex >= cmbWebsite.Items.Count) then
    cmbWebsite.ItemIndex := 0;
  cmbDateRange.ItemIndex := StrToIntDef(
    dmSettings.ReadSetting('default_date_range_index', '2'), 2);
  if (cmbDateRange.ItemIndex < 0) or (cmbDateRange.ItemIndex >= cmbDateRange.Items.Count) then
    cmbDateRange.ItemIndex := 2;
  chkComparePrevious.IsChecked := False;
  chkComparePrevious.Visible := False;
  chkAutoUpdate.IsChecked :=
    dmSettings.ReadSetting('auto_update_enabled', '1') = '1';
  AutoUpdateTimer.Enabled := chkAutoUpdate.IsChecked;
  if cmbChartMetric.ItemIndex < 0 then
    cmbChartMetric.ItemIndex := 0;
  if cmbContentFilter.ItemIndex < 0 then
    cmbContentFilter.ItemIndex := 0;
  cmbChartMetric.ItemIndex := 0;
  cmbChartMetric.Visible := False;
  RoundedTabsBar.Visible := False;
  RoundedTabsBar.Height := 0;
  KpiFlow.Visible := False;
  KpiFlow.Height := 0;
  lblSessionsByDatePicker.Visible := False;
  dtSessionsByDate.Visible := False;
  btnSessionsByDateRefresh.Visible := False;
  GeographyPreviewCard.Visible := True;
  ContentPreviewCard.Visible := True;
  RealtimePreviewCard.Visible := False;
  colGeographyEngagement.Visible := False;
  colContentViews.Header := 'Users';
  colContentUsers.Header := 'Events/downloads';
  colContentEvents.Visible := False;
  colContentEngagement.Visible := False;
  dtSessionsByDate.Date := Date;
  grdGeographyRows.RowHeight := 25;
  grdGeographyRows.TextSettings.Font.Size := 15;
  grdGeographyRows.AutoHide := TBehaviorBoolean.False;
  grdContentRows.RowHeight := 25;
  grdContentRows.TextSettings.Font.Size := 15;
  grdContentRows.AutoHide := TBehaviorBoolean.False;
  FGridColumnWidthSavingEnabled := False;
  LoadGridColumnWidths;
  FGridColumnWidthSavingEnabled := True;
  DashboardTabs.TabIndex := SECTION_USA;
  FLastReportTabIndex := SECTION_USA;
  FLocationListMode := llmAllLocations;
  FContentListMode := clmAllRows;
  FLastRealtimeActivityText := 'Current location: None' + sLineBreak +
    'Last activity: None';
  FLastLocationTileText := 'None';
  AdjustQuadrantProportions;
  UpdateChartTitle;
  lblGeographyTitle.Text := 'Where did they come from?';
  lblGeographyRows.Text := 'Country, region/state, city, users, and sessions';
  lblContentTitle.Text := 'What pages/downloads did they use?';
  lblContentRows.Text := 'Top pages and downloads for selected range';
  if Assigned(grdContentRows) then
    grdContentRows.Visible := False;
  if Assigned(pbTopPagesDownloads) then
    pbTopPagesDownloads.Visible := True;
  PopulateRealtimePanel(dmAnalyticsMemory.CurrentSnapshot);
  UpdateSummaryTiles(dmAnalyticsMemory.CurrentSnapshot);
  FSelectorChangeEnabled := True;

  FStartupAuthStarted := False;
  FStartupUpdateDone := False;
  if (not FindCmdLineSwitch('no-startup-auth', True)) and
    (dmSettings.ReadSetting('refresh_at_startup', '1') = '1') then
  AuthStartupTimer.Enabled := True;
end;

procedure TfrmMainDashboard.FormResize(Sender: TObject);
begin
  AdjustQuadrantProportions;
end;

procedure TfrmMainDashboard.RefreshPropertySelector;
var
  PropertyIndex: Integer;
begin
  cmbWebsite.BeginUpdate;
  try
    cmbWebsite.Clear;
    cmbWebsite.Items.Add('All websites');
    for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
      if dmAnalyticsMemory[PropertyIndex].Enabled then
        cmbWebsite.Items.Add(dmAnalyticsMemory[PropertyIndex].DisplayName);
    cmbWebsite.ItemIndex := 0;
  finally
    cmbWebsite.EndUpdate;
  end;
end;

function TfrmMainDashboard.GridColumnWidthSettingName(
  const Column: TColumn): string;
begin
  if Assigned(Column) and (Trim(Column.Name) <> '') then
    Result := 'grid_column_width_' + Column.Name
  else
    Result := '';
end;

procedure TfrmMainDashboard.LoadGridColumnWidth(const Column: TColumn);
var
  SettingName: string;
  StoredWidth: Integer;
begin
  if not Assigned(Column) then
    Exit;

  SettingName := GridColumnWidthSettingName(Column);
  if SettingName = '' then
    Exit;

  StoredWidth := StrToIntDef(dmSettings.ReadSetting(SettingName, ''), -1);
  if StoredWidth >= 36 then
    Column.Width := StoredWidth;
end;

procedure TfrmMainDashboard.LoadGridColumnWidths;
begin
  FLoadingGridColumnWidths := True;
  try
    LoadGridColumnWidth(colGeographyCountry);
    LoadGridColumnWidth(colGeographyRegion);
    LoadGridColumnWidth(colGeographyCity);
    LoadGridColumnWidth(colGeographyUsers);
    LoadGridColumnWidth(colGeographySessions);
    LoadGridColumnWidth(colGeographyEngagement);
    LoadGridColumnWidth(colContentTitle);
    LoadGridColumnWidth(colContentPath);
    LoadGridColumnWidth(colContentAction);
    LoadGridColumnWidth(colContentViews);
    LoadGridColumnWidth(colContentUsers);
    LoadGridColumnWidth(colContentEvents);
    LoadGridColumnWidth(colContentEngagement);
  finally
    FLoadingGridColumnWidths := False;
  end;
end;

procedure TfrmMainDashboard.SaveGridColumnWidth(const Column: TColumn);
var
  SettingName: string;
begin
  if FLoadingGridColumnWidths or (not FGridColumnWidthSavingEnabled) or
    (not Assigned(Column)) then
    Exit;

  SettingName := GridColumnWidthSettingName(Column);
  if SettingName = '' then
    Exit;

  dmSettings.WriteSetting(SettingName, IntToStr(Round(Column.Width)),
    'appearance', 'Saved dashboard grid column width');
end;

procedure TfrmMainDashboard.GridColumnResize(Sender: TObject);
begin
  if Sender is TColumn then
    SaveGridColumnWidth(TColumn(Sender));
end;

function TfrmMainDashboard.CompareGeographyRowsAlphabetically(
  const Left, Right: TGA4GeographyRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.Country, '(country not set)'),
    CleanLocationText(Right.Country, '(country not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.Region, '(region not set)'),
    CleanLocationText(Right.Region, '(region not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.City, '(city not set)'),
    CleanLocationText(Right.City, '(city not set)'));
end;

function TfrmMainDashboard.CompareSessionsByDateRowsAlphabetically(
  const Left, Right: TGA4SessionsByDateRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.Country, '(country not set)'),
    CleanLocationText(Right.Country, '(country not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.Region, '(region not set)'),
    CleanLocationText(Right.Region, '(region not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.City, '(city not set)'),
    CleanLocationText(Right.City, '(city not set)'));
end;

function TfrmMainDashboard.CompareContentRowsAlphabetically(
  const Left, Right: TGA4ContentRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.PageTitle, '(title not set)'),
    CleanLocationText(Right.PageTitle, '(title not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.PagePath, '(path not set)'),
    CleanLocationText(Right.PagePath, '(path not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(ContentActionText(Left), ContentActionText(Right));
end;

function TfrmMainDashboard.CompareAcquisitionRowsAlphabetically(
  const Left, Right: TGA4AcquisitionRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.Source, '(source not set)'),
    CleanLocationText(Right.Source, '(source not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.Medium, '(medium not set)'),
    CleanLocationText(Right.Medium, '(medium not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.Campaign, '(campaign not set)'),
    CleanLocationText(Right.Campaign, '(campaign not set)'));
end;

function TfrmMainDashboard.CompareDeviceRowsAlphabetically(
  const Left, Right: TGA4DeviceRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.DeviceCategory, '(device not set)'),
    CleanLocationText(Right.DeviceCategory, '(device not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.Browser, '(browser not set)'),
    CleanLocationText(Right.Browser, '(browser not set)'));
  if Result <> 0 then
    Exit;

  Result := CompareText(CleanLocationText(Left.OperatingSystem, '(OS not set)'),
    CleanLocationText(Right.OperatingSystem, '(OS not set)'));
end;

function TfrmMainDashboard.CompareLanguageRowsAlphabetically(
  const Left, Right: TGA4LanguageRow): Integer;
begin
  Result := CompareText(CleanLocationText(Left.Language, '(language not set)'),
    CleanLocationText(Right.Language, '(language not set)'));
end;

procedure TfrmMainDashboard.SelectSection(const SectionIndex: Integer);
begin
  if (SectionIndex < 0) or (SectionIndex > MAX_REPORT_SECTION) then
    Exit;
  UpdatePreviewForSection(SectionIndex);
end;

procedure TfrmMainDashboard.UpdatePreviewForSection(const SectionIndex: Integer);
begin
  grdGeographyRows.RowCount := 0;
  grdContentRows.RowCount := 0;
  lblStatusBar.Text := '';
  lblSessionsByDatePicker.Visible := SectionIndex = SECTION_SESSIONS_BY_DATE;
  dtSessionsByDate.Visible := SectionIndex = SECTION_SESSIONS_BY_DATE;
  btnSessionsByDateRefresh.Visible := SectionIndex = SECTION_SESSIONS_BY_DATE;
  case SectionIndex of
    SECTION_USA:
      begin
        ShowLocationTable;
        FLocationListMode := llmUnitedStates;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'USA states and cities';
        lblGeographyRows.Text := 'Filtered to United States rows with users, sessions, and engagement';
        lblContentRows.Text := '';
      end;
    SECTION_SESSIONS_BY_DATE:
      begin
        ShowLocationTable;
        FLocationListMode := llmAllLocations;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'Sessions by Date';
        lblGeographyRows.Text := 'Choose a date to display country, region/state, city, users, sessions, views, and engagement';
        lblContentRows.Text := '';
      end;
    SECTION_DOWNLOADS:
      begin
        ShowContentTable;
        FLocationListMode := llmAllLocations;
        FContentListMode := clmActionsOnly;
        if cmbContentFilter.ItemIndex <> 3 then
          cmbContentFilter.ItemIndex := 3;
        UpdateChartTitle;
        lblContentTitle.Text := 'Downloads and events';
        lblContentRows.Text := 'Downloads, clicks, outbound clicks, and other events/actions';
      end;
    SECTION_SOURCES:
      begin
        ShowLocationTable;
        FLocationListMode := llmAllLocations;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'Traffic sources';
        lblGeographyRows.Text := 'Source, medium, campaign, users, sessions, and engagement rate';
        lblContentRows.Text := '';
      end;
    SECTION_DEVICES:
      begin
        ShowLocationTable;
        FLocationListMode := llmAllLocations;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'Devices, browsers, and operating systems';
        lblGeographyRows.Text := 'Device category, browser, operating system, users, and sessions';
        lblContentRows.Text := '';
      end;
    SECTION_LANGUAGES:
      begin
        ShowLocationTable;
        FLocationListMode := llmAllLocations;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'Visitor languages';
        lblGeographyRows.Text := 'Language, users, sessions, and engagement rate';
        lblContentRows.Text := '';
      end;
    SECTION_COUNTRIES:
      begin
        ShowLocationTable;
        FLocationListMode := llmAllLocations;
        UpdateChartTitle;
        lblGeographyTitle.Text := 'Countries, regions, and cities';
        lblGeographyRows.Text := 'Country, region/state, city, users, sessions, and engagement';
        lblContentRows.Text := '';
      end;
    SECTION_REALTIME:
      begin
        ShowRealtimePanel;
        UpdateChartTitle;
        lblContentRows.Text := '';
        lblStatusBar.Text := 'Realtime shows GA4 active users in the current last-30-minutes realtime window.';
      end;
  else
    begin
      ShowLocationTable;
      FLocationListMode := llmUnitedStates;
      UpdateChartTitle;
      lblGeographyTitle.Text := 'USA states and cities';
      lblGeographyRows.Text := 'Filtered to United States rows with users, sessions, and engagement';
      lblContentRows.Text := '';
    end;
  end;
  if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) then
    if SectionIndex = SECTION_DOWNLOADS then
      PopulateContentRows(dmAnalyticsMemory.CurrentSnapshot)
    else if SectionIndex = SECTION_SESSIONS_BY_DATE then
      PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot)
    else if SectionIndex = SECTION_SOURCES then
      PopulateAcquisitionRows(dmAnalyticsMemory.CurrentSnapshot)
    else if SectionIndex = SECTION_DEVICES then
      PopulateDeviceRows(dmAnalyticsMemory.CurrentSnapshot)
    else if SectionIndex = SECTION_LANGUAGES then
      PopulateLanguageRows(dmAnalyticsMemory.CurrentSnapshot)
    else if SectionIndex = SECTION_REALTIME then
      PopulateRealtimePanel(dmAnalyticsMemory.CurrentSnapshot)
    else
      PopulateGeographyRows(dmAnalyticsMemory.CurrentSnapshot);
  pbWeeklyUsers.Repaint;
end;

procedure TfrmMainDashboard.ShowLocationTable;
begin
  ContentPreviewCard.Visible := True;
  RealtimePreviewCard.Visible := False;
  GeographyPreviewCard.Visible := True;
end;

procedure TfrmMainDashboard.ShowContentTable;
begin
  GeographyPreviewCard.Visible := True;
  RealtimePreviewCard.Visible := False;
  ContentPreviewCard.Visible := True;
end;

procedure TfrmMainDashboard.ShowRealtimePanel;
begin
  GeographyPreviewCard.Visible := True;
  ContentPreviewCard.Visible := True;
  RealtimePreviewCard.Visible := False;
end;

procedure TfrmMainDashboard.SetRoundedTabStyle(const TabShape: TRectangle;
  const IsSelected: Boolean);
var
  ChildIndex: Integer;
  TabLabel: TLabel;
begin
  if not Assigned(TabShape) then
    Exit;

  if IsSelected then
  begin
    TabShape.Fill.Color := $FF38BDF8;
    TabShape.Stroke.Color := $FF7DD3FC;
  end
  else
  begin
    TabShape.Fill.Color := $FF10243B;
    TabShape.Stroke.Color := $FF2B4F76;
  end;

  for ChildIndex := 0 to TabShape.ChildrenCount - 1 do
    if TabShape.Children[ChildIndex] is TLabel then
    begin
      TabLabel := TLabel(TabShape.Children[ChildIndex]);
      if IsSelected then
        TabLabel.TextSettings.FontColor := $FF06111F
      else
        TabLabel.TextSettings.FontColor := $FFFFFFFF;
    end;
end;

procedure TfrmMainDashboard.UpdateRoundedTabStyles;
var
  ChildIndex: Integer;
begin
  if not Assigned(RoundedTabsBar) then
    Exit;

  for ChildIndex := 0 to RoundedTabsBar.ChildrenCount - 1 do
    if RoundedTabsBar.Children[ChildIndex] is TRectangle then
      SetRoundedTabStyle(TRectangle(RoundedTabsBar.Children[ChildIndex]),
        TRectangle(RoundedTabsBar.Children[ChildIndex]).Tag = DashboardTabs.TabIndex);
end;

procedure TfrmMainDashboard.UpdateChartTitle;
begin
  lblWeeklyUsersTitle.Text := SelectedTrendCaption;
end;

function TfrmMainDashboard.CleanLocationText(const Value,
  FallbackText: string): string;
begin
  Result := Trim(Value);
  if Result = '' then
    Result := FallbackText;
end;

function TfrmMainDashboard.FindHelpIndexPath: string;
var
  CandidatePath: string;
  CandidatePaths: TArray<string>;
  ExeFolder: string;
begin
  Result := '';
  ExeFolder := System.IOUtils.TPath.GetDirectoryName(ParamStr(0));
  CandidatePaths := TArray<string>.Create(
    System.IOUtils.TPath.Combine(ExeFolder,
      System.IOUtils.TPath.Combine('help', 'index.html')),
    System.IOUtils.TPath.GetFullPath(System.IOUtils.TPath.Combine(ExeFolder,
      System.IOUtils.TPath.Combine('..',
        System.IOUtils.TPath.Combine('help', 'index.html')))),
    System.IOUtils.TPath.GetFullPath(System.IOUtils.TPath.Combine(ExeFolder,
      System.IOUtils.TPath.Combine('..',
        System.IOUtils.TPath.Combine('..',
          System.IOUtils.TPath.Combine('help', 'index.html'))))),
    System.IOUtils.TPath.GetFullPath(System.IOUtils.TPath.Combine(ExeFolder,
      System.IOUtils.TPath.Combine('..',
        System.IOUtils.TPath.Combine('..',
          System.IOUtils.TPath.Combine('..',
            System.IOUtils.TPath.Combine('help', 'index.html')))))),
    System.IOUtils.TPath.Combine(System.IOUtils.TDirectory.GetCurrentDirectory,
      System.IOUtils.TPath.Combine('help', 'index.html'))
  );

  for CandidatePath in CandidatePaths do
    if System.IOUtils.TFile.Exists(CandidatePath) then
      Exit(CandidatePath);
end;

function TfrmMainDashboard.IsTokenRefreshableError(
  const ErrorText: string): Boolean;
var
  LowerError: string;
begin
  LowerError := LowerCase(ErrorText);
  Result := (Pos('http 401', LowerError) > 0) or
    (Pos('unauthorized', LowerError) > 0) or
    (Pos('invalid authentication', LowerError) > 0) or
    (Pos('expired', LowerError) > 0);
end;

function TfrmMainDashboard.ContentActionText(
  const ContentRow: TGA4ContentRow): string;
var
  EventText: string;
begin
  EventText := CleanLocationText(ContentRow.EventName, '(event not set)');
  if Pos('download', LowerCase(EventText)) > 0 then
    Result := 'Download: ' + EventText
  else if (Pos('click', LowerCase(EventText)) > 0) or
    (Pos('outbound', LowerCase(EventText)) > 0) then
    Result := 'Action: ' + EventText
  else if SameText(EventText, 'page_view') then
    Result := 'Page view'
  else
    Result := EventText;
end;

function TfrmMainDashboard.ContentRowMatchesView(
  const ContentRow: TGA4ContentRow): Boolean;
var
  EventText: string;
begin
  EventText := LowerCase(ContentRow.EventName);
  case FContentListMode of
    clmPagesOnly:
      Result := SameText(ContentRow.EventName, 'page_view') or
        (ContentRow.ScreenPageViews > 0);
    clmDownloadsOnly:
      Result := Pos('download', EventText) > 0;
    clmActionsOnly:
      Result := (not SameText(ContentRow.EventName, 'page_view')) or
        (Pos('click', EventText) > 0) or (Pos('outbound', EventText) > 0) or
        (Pos('download', EventText) > 0);
  else
    Result := True;
  end;
end;

function TfrmMainDashboard.LocationRowMatchesView(
  const GeographyRow: TGA4GeographyRow): Boolean;
begin
  case FLocationListMode of
    llmUnitedStates:
      Result := SameText(GeographyRow.Country, 'United States');
    llmInternational:
      Result := not SameText(GeographyRow.Country, 'United States');
  else
    Result := True;
  end;
end;

function TfrmMainDashboard.SelectedDateRangeCaption: string;
var
  EndDateValue: TDateTime;
  StartDateValue: TDateTime;
begin
  EndDateValue := Date;
  case cmbDateRange.ItemIndex of
    0:
      begin
        StartDateValue := Date;
        Result := 'today (' + FormatDateTime('m/d/yyyy', StartDateValue) + ')';
      end;
    1:
      begin
        StartDateValue := Date - 6;
        Result := 'the last 7 days (' + FormatDateTime('m/d/yyyy',
          StartDateValue) + ' - ' + FormatDateTime('m/d/yyyy',
          EndDateValue) + ')';
      end;
    2:
      begin
        StartDateValue := Date - 27;
        Result := 'the last 28 days (' + FormatDateTime('m/d/yyyy',
          StartDateValue) + ' - ' + FormatDateTime('m/d/yyyy',
          EndDateValue) + ')';
      end;
    3:
      begin
        StartDateValue := Date - 89;
        Result := 'the last 90 days (' + FormatDateTime('m/d/yyyy',
          StartDateValue) + ' - ' + FormatDateTime('m/d/yyyy',
          EndDateValue) + ')';
      end;
    4:
      begin
        StartDateValue := EncodeDate(YearOf(Date), 1, 1);
        Result := 'this year (' + FormatDateTime('m/d/yyyy',
          StartDateValue) + ' - ' + FormatDateTime('m/d/yyyy',
          EndDateValue) + ')';
      end;
  else
    Result := 'the selected date range';
  end;
end;

function TfrmMainDashboard.SelectedTrendCaption: string;
begin
  Result := 'Users over ' + SelectedDateRangeCaption;
end;

function TfrmMainDashboard.SelectedTrendValue(
  const TrendPoint: TGA4TrendPoint): Double;
begin
  Result := TrendPoint.ActiveUsers;
end;

function TfrmMainDashboard.FormatTrendScaleValue(const Value: Double): string;
begin
  Result := FormatFloat('#,##0', Value);
end;

function TfrmMainDashboard.FormatTrendTooltipValue(const Value: Double): string;
begin
  Result := FormatFloat('#,##0', Value);
end;

function TfrmMainDashboard.ComparisonDeltaColor(const CurrentValue,
  PreviousValue: Double): TAlphaColor;
begin
  if Abs(CurrentValue - PreviousValue) < 0.0001 then
    Result := $FF9FB4D1
  else if CurrentValue > PreviousValue then
    Result := $FF34D399
  else
    Result := $FFF87171;
end;

function TfrmMainDashboard.FormatComparisonDelta(const CurrentValue,
  PreviousValue: Double; const IsRate: Boolean): string;
var
  DeltaValue: Double;
  PercentChange: Double;
  PrefixText: string;
begin
  DeltaValue := CurrentValue - PreviousValue;
  if Abs(DeltaValue) < 0.0001 then
    Exit('No change vs previous');

  if DeltaValue > 0 then
    PrefixText := '▲ '
  else
    PrefixText := '▼ ';

  if IsRate then
    Result := PrefixText + FormatFloat('0.0', Abs(DeltaValue) * 100) +
      ' pts'
  else
    Result := PrefixText + FormatFloat('#,##0', Abs(DeltaValue));

  if Abs(PreviousValue) > 0.0001 then
  begin
    PercentChange := (DeltaValue / PreviousValue) * 100;
    Result := Result + ' (' + FormatFloat('+0.0;-0.0;0.0', PercentChange) +
      '%)';
  end
  else if Abs(CurrentValue) > 0.0001 then
    Result := Result + ' (new)';

  Result := Result + ' vs previous';
end;

function TfrmMainDashboard.DateToGA4String(const Value: TDateTime): string;
begin
  Result := FormatDateTime('yyyy"-"mm"-"dd', Value);
end;

procedure TfrmMainDashboard.BuildTrendChartData(const PaintBox: TPaintBox;
  out ChartRect: TRectF; out Points: TArray<TPointF>;
  out Values: TArray<Double>; out Labels: TArray<string>;
  out ScaleMax: Double);
var
  PointIndex: Integer;
  RawMaxValue: Double;
  TrendCount: Integer;
  TickStep: Integer;
begin
  ChartRect := RectF(58, 18, PaintBox.Width - 18, PaintBox.Height - 34);
  RawMaxValue := 0;

  if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) then
    TrendCount := dmAnalyticsMemory.CurrentSnapshot.TrendPoints.Count
  else
    TrendCount := 0;

  SetLength(Points, TrendCount);
  SetLength(Values, TrendCount);
  SetLength(Labels, TrendCount);

  for PointIndex := 0 to TrendCount - 1 do
  begin
    if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) and
      (dmAnalyticsMemory.CurrentSnapshot.TrendPoints.Count > 0) then
    begin
      Values[PointIndex] := SelectedTrendValue(
        dmAnalyticsMemory.CurrentSnapshot.TrendPoints[PointIndex]);
      Labels[PointIndex] :=
        dmAnalyticsMemory.CurrentSnapshot.TrendPoints[PointIndex].LabelText;
    end
    else
      Values[PointIndex] := 0;

    if Values[PointIndex] > RawMaxValue then
      RawMaxValue := Values[PointIndex];
  end;

  if RawMaxValue <= 0 then
    ScaleMax := 1
  else
  begin
    ScaleMax := Ceil(RawMaxValue);
    TickStep := Max(1, Ceil(ScaleMax / 5));
    ScaleMax := TickStep * Ceil(ScaleMax / TickStep);
  end;

  for PointIndex := 0 to TrendCount - 1 do
    Points[PointIndex] := PointF(
      ChartRect.Left + (ChartRect.Width / TrendCount) * PointIndex +
        (ChartRect.Width / TrendCount / 2),
      ChartRect.Bottom - (Values[PointIndex] / ScaleMax) * ChartRect.Height);
end;

procedure TfrmMainDashboard.BuildTopPagesChartData(const PaintBox: TPaintBox;
  out ChartRect: TRectF; out Labels: TArray<string>; out Values: TArray<Double>;
  out ScaleMax: Double);
const
  MaxBars = 7;
var
  BarIndex: Integer;
  ContentIndex: Integer;
  ContentRows: TList<TGA4ContentRow>;
  DisplayCount: Integer;
  RowLabel: string;
  Snapshot: TGA4ReportSnapshot;
begin
  ChartRect := RectF(12, 8, PaintBox.Width - 52, PaintBox.Height - 8);
  ScaleMax := 1;
  SetLength(Labels, 0);
  SetLength(Values, 0);

  if (not Assigned(dmAnalyticsMemory)) or
    (not Assigned(dmAnalyticsMemory.CurrentSnapshot)) then
    Exit;

  Snapshot := dmAnalyticsMemory.CurrentSnapshot;
  if Snapshot.ContentRows.Count = 0 then
    Exit;

  ContentRows := TList<TGA4ContentRow>.Create;
  try
    for ContentIndex := 0 to Snapshot.ContentRows.Count - 1 do
      if Snapshot.ContentRows[ContentIndex].EventCount > 0 then
        ContentRows.Add(Snapshot.ContentRows[ContentIndex]);

    ContentRows.Sort(TComparer<TGA4ContentRow>.Construct(
      function(const Left, Right: TGA4ContentRow): Integer
      begin
        Result := CompareValue(Right.EventCount, Left.EventCount);
        if Result = 0 then
          Result := CompareText(ContentActionText(Left), ContentActionText(Right));
      end));

    DisplayCount := Min(MaxBars, ContentRows.Count);
    SetLength(Labels, DisplayCount);
    SetLength(Values, DisplayCount);

    for BarIndex := 0 to DisplayCount - 1 do
    begin
      RowLabel := CleanLocationText(ContentRows[BarIndex].PagePath, '(path not set)');
      if RowLabel = '/' then
        RowLabel := 'Home';
      RowLabel := RowLabel + ' - ' + ContentActionText(ContentRows[BarIndex]);
      Labels[BarIndex] := RowLabel;
      Values[BarIndex] := ContentRows[BarIndex].EventCount;
      if Values[BarIndex] > ScaleMax then
        ScaleMax := Values[BarIndex];
    end;

    ScaleMax := Max(1, Ceil(ScaleMax));
  finally
    ContentRows.Free;
  end;
end;

procedure TfrmMainDashboard.HideTrendTooltip;
begin
  if Assigned(TrendTooltip) then
    TrendTooltip.Visible := False;
end;

procedure TfrmMainDashboard.HideTopPagesTooltip;
begin
  if Assigned(TopPagesTooltip) then
    TopPagesTooltip.Visible := False;
end;

procedure TfrmMainDashboard.ConfigureGeographyGridColumns(
  const FirstHeader, SecondHeader, ThirdHeader, FourthHeader, FifthHeader,
  SixthHeader: string);
begin
  colGeographyCountry.Header := FirstHeader;
  colGeographyRegion.Header := SecondHeader;
  colGeographyCity.Header := ThirdHeader;
  colGeographyUsers.Header := FourthHeader;
  colGeographySessions.Header := FifthHeader;
  colGeographyEngagement.Header := SixthHeader;
end;

procedure TfrmMainDashboard.PopulateContentRows(
  const Snapshot: TGA4ReportSnapshot);
var
  ContentIndex: Integer;
  ContentRow: TGA4ContentRow;
  ContentRows: TList<TGA4ContentRow>;
  ContentRangeText: string;
  RowIndex: Integer;
  VisibleCount: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ContentRows := TList<TGA4ContentRow>.Create;
  try
    for ContentIndex := 0 to Snapshot.ContentRows.Count - 1 do
    begin
      ContentRow := Snapshot.ContentRows[ContentIndex];
      if ContentRowMatchesView(ContentRow) then
        ContentRows.Add(ContentRow);
    end;

    ContentRows.Sort(TComparer<TGA4ContentRow>.Construct(
      function(const Left, Right: TGA4ContentRow): Integer
      begin
        Result := CompareContentRowsAlphabetically(Left, Right);
      end));
    VisibleCount := ContentRows.Count;

  grdContentRows.BeginUpdate;
  try
    grdContentRows.RowCount := 0;
      for ContentRow in ContentRows do
    begin
      RowIndex := grdContentRows.RowCount;
      grdContentRows.RowCount := RowIndex + 1;
      grdContentRows.Cells[0, RowIndex] :=
        CleanLocationText(ContentRow.PageTitle, '(title not set)');
      grdContentRows.Cells[1, RowIndex] :=
        CleanLocationText(ContentRow.PagePath, '(path not set)');
      grdContentRows.Cells[2, RowIndex] :=
        ContentActionText(ContentRow);
      grdContentRows.Cells[3, RowIndex] :=
        FormatFloat('#,##0', ContentRow.ActiveUsers);
      grdContentRows.Cells[4, RowIndex] :=
        FormatFloat('#,##0', ContentRow.EventCount);
      grdContentRows.Cells[5, RowIndex] := '';
      grdContentRows.Cells[6, RowIndex] :=
        '';
    end;
  finally
    grdContentRows.EndUpdate;
  end;
  finally
    ContentRows.Free;
  end;

  case cmbDateRange.ItemIndex of
    0:
      ContentRangeText := 'Today';
    1:
      ContentRangeText := 'Last 7 days';
    2:
      ContentRangeText := 'Last 28 days';
    3:
      ContentRangeText := 'Last 90 days';
    4:
      ContentRangeText := 'This year';
  else
    ContentRangeText := 'Selected range';
  end;

  if DashboardTabs.TabIndex = SECTION_DOWNLOADS then
  begin
    lblContentTitle.Text := Format('Downloads and events (%d)', [VisibleCount]);
    lblContentRows.Text := 'Top pages and downloads for ' + ContentRangeText;
  end
  else
  begin
    lblContentTitle.Text := Format('Pages and downloads used (%d)', [VisibleCount]);
    lblContentRows.Text := 'Top pages and downloads for ' + ContentRangeText;
  end;

  if (VisibleCount = 0) and (Snapshot.ContentRows.Count > 0) then
    lblStatusBar.Text := 'No page/action rows matched the selected filter.';

  if Assigned(pbTopPagesDownloads) then
    pbTopPagesDownloads.Repaint;
end;

procedure TfrmMainDashboard.PopulateGeographyRows(
  const Snapshot: TGA4ReportSnapshot);
var
  CityText: string;
  CountryText: string;
  GeographyIndex: Integer;
  GeographyRow: TGA4GeographyRow;
  GeographyRows: TList<TGA4GeographyRow>;
  RegionText: string;
  RowIndex: Integer;
  VisibleCount: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ConfigureGeographyGridColumns('Country', 'Region / State', 'City', 'Users',
    'Sessions', 'Engagement rate');

  GeographyRows := TList<TGA4GeographyRow>.Create;
  try
    for GeographyIndex := 0 to Snapshot.GeographyRows.Count - 1 do
    begin
      GeographyRow := Snapshot.GeographyRows[GeographyIndex];
      if LocationRowMatchesView(GeographyRow) then
        GeographyRows.Add(GeographyRow);
    end;

    GeographyRows.Sort(TComparer<TGA4GeographyRow>.Construct(
      function(const Left, Right: TGA4GeographyRow): Integer
      begin
        Result := CompareGeographyRowsAlphabetically(Left, Right);
      end));
    VisibleCount := GeographyRows.Count;

  grdGeographyRows.BeginUpdate;
  try
    grdGeographyRows.RowCount := 0;
      for GeographyRow in GeographyRows do
    begin
      CountryText := CleanLocationText(GeographyRow.Country, '(country not set)');
      RegionText := CleanLocationText(GeographyRow.Region, '(region not set)');
      CityText := CleanLocationText(GeographyRow.City, '(city not set)');

      RowIndex := grdGeographyRows.RowCount;
      grdGeographyRows.RowCount := RowIndex + 1;
      grdGeographyRows.Cells[0, RowIndex] := CountryText;
      grdGeographyRows.Cells[1, RowIndex] := RegionText;
      grdGeographyRows.Cells[2, RowIndex] := CityText;
      grdGeographyRows.Cells[3, RowIndex] :=
        FormatFloat('#,##0', GeographyRow.ActiveUsers);
      grdGeographyRows.Cells[4, RowIndex] :=
        FormatFloat('#,##0', GeographyRow.Sessions);
      grdGeographyRows.Cells[5, RowIndex] :=
        FormatFloat('0.0%', GeographyRow.EngagementRate);
    end;
  finally
    grdGeographyRows.EndUpdate;
  end;
  finally
    GeographyRows.Free;
  end;

  case FLocationListMode of
    llmUnitedStates:
      begin
        lblGeographyTitle.Text := Format('USA states and cities (%d)',
          [VisibleCount]);
        lblGeographyRows.Text := 'Filtered to United States rows with users, sessions, and engagement';
      end;
    llmInternational:
      begin
        lblGeographyTitle.Text := Format('Countries, regions, and cities (%d)',
          [VisibleCount]);
        lblGeographyRows.Text := 'Filtered to non-USA rows with users, sessions, and engagement';
      end;
  else
    begin
      lblGeographyTitle.Text := Format('Where visitors came from (%d)', [VisibleCount]);
      lblGeographyRows.Text := 'Country, region/state, city, users, and sessions';
    end;
  end;

  if (VisibleCount = 0) and (Snapshot.GeographyRows.Count > 0) then
    lblStatusBar.Text := 'No locations matched the selected location tab.';
end;

procedure TfrmMainDashboard.PopulateSessionsByDateRows(
  const Snapshot: TGA4ReportSnapshot);
var
  CityText: string;
  CountryText: string;
  ReportDateText: string;
  RegionText: string;
  RowIndex: Integer;
  SessionsByDateIndex: Integer;
  SessionsByDateRow: TGA4SessionsByDateRow;
  SessionsByDateRows: TList<TGA4SessionsByDateRow>;
  VisibleCount: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ConfigureGeographyGridColumns('Country', 'Region / State', 'City', 'Users',
    'Sessions', 'Views / Engagement');
  ReportDateText := FormatDateTime('m/d/yyyy', dtSessionsByDate.Date);

  SessionsByDateRows := TList<TGA4SessionsByDateRow>.Create;
  try
    for SessionsByDateIndex := 0 to Snapshot.SessionsByDateRows.Count - 1 do
      SessionsByDateRows.Add(Snapshot.SessionsByDateRows[SessionsByDateIndex]);

    SessionsByDateRows.Sort(TComparer<TGA4SessionsByDateRow>.Construct(
      function(const Left, Right: TGA4SessionsByDateRow): Integer
      begin
        Result := CompareSessionsByDateRowsAlphabetically(Left, Right);
      end));
    VisibleCount := SessionsByDateRows.Count;

    grdGeographyRows.BeginUpdate;
    try
      grdGeographyRows.RowCount := 0;
      for SessionsByDateRow in SessionsByDateRows do
      begin
        CountryText := CleanLocationText(SessionsByDateRow.Country,
          '(country not set)');
        RegionText := CleanLocationText(SessionsByDateRow.Region,
          '(region not set)');
        CityText := CleanLocationText(SessionsByDateRow.City,
          '(city not set)');

        RowIndex := grdGeographyRows.RowCount;
        grdGeographyRows.RowCount := RowIndex + 1;
        grdGeographyRows.Cells[0, RowIndex] := CountryText;
        grdGeographyRows.Cells[1, RowIndex] := RegionText;
        grdGeographyRows.Cells[2, RowIndex] := CityText;
        grdGeographyRows.Cells[3, RowIndex] :=
          FormatFloat('#,##0', SessionsByDateRow.ActiveUsers);
        grdGeographyRows.Cells[4, RowIndex] :=
          FormatFloat('#,##0', SessionsByDateRow.Sessions);
        grdGeographyRows.Cells[5, RowIndex] :=
          FormatFloat('#,##0', SessionsByDateRow.ScreenPageViews) +
          ' views / ' + FormatFloat('0.0%', SessionsByDateRow.EngagementRate);
      end;
    finally
      grdGeographyRows.EndUpdate;
    end;
  finally
    SessionsByDateRows.Free;
  end;

  lblGeographyTitle.Text := Format('Sessions by Date (%d)', [VisibleCount]);
  if VisibleCount = 0 then
  begin
    lblGeographyRows.Text := 'No sessions were returned for ' + ReportDateText;
    lblStatusBar.Text := 'GA4 returned no sessions for ' + ReportDateText + '.';
  end
  else
    lblGeographyRows.Text := 'Country, region/state, city, users, sessions, views, and engagement for ' +
      ReportDateText;
end;

procedure TfrmMainDashboard.PopulateAcquisitionRows(
  const Snapshot: TGA4ReportSnapshot);
var
  AcquisitionIndex: Integer;
  AcquisitionRow: TGA4AcquisitionRow;
  AcquisitionRows: TList<TGA4AcquisitionRow>;
  RowIndex: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ConfigureGeographyGridColumns('Source', 'Medium', 'Campaign', 'Users',
    'Sessions', 'Engagement rate');

  AcquisitionRows := TList<TGA4AcquisitionRow>.Create;
  try
    for AcquisitionIndex := 0 to Snapshot.AcquisitionRows.Count - 1 do
      AcquisitionRows.Add(Snapshot.AcquisitionRows[AcquisitionIndex]);

    AcquisitionRows.Sort(TComparer<TGA4AcquisitionRow>.Construct(
      function(const Left, Right: TGA4AcquisitionRow): Integer
      begin
        Result := CompareAcquisitionRowsAlphabetically(Left, Right);
      end));

    grdGeographyRows.BeginUpdate;
    try
      grdGeographyRows.RowCount := 0;
      for AcquisitionRow in AcquisitionRows do
      begin
        RowIndex := grdGeographyRows.RowCount;
        grdGeographyRows.RowCount := RowIndex + 1;
        grdGeographyRows.Cells[0, RowIndex] :=
          CleanLocationText(AcquisitionRow.Source, '(source not set)');
        grdGeographyRows.Cells[1, RowIndex] :=
          CleanLocationText(AcquisitionRow.Medium, '(medium not set)');
        grdGeographyRows.Cells[2, RowIndex] :=
          CleanLocationText(AcquisitionRow.Campaign, '(campaign not set)');
        grdGeographyRows.Cells[3, RowIndex] :=
          FormatFloat('#,##0', AcquisitionRow.ActiveUsers);
        grdGeographyRows.Cells[4, RowIndex] :=
          FormatFloat('#,##0', AcquisitionRow.Sessions);
        grdGeographyRows.Cells[5, RowIndex] :=
          FormatFloat('0.0%', AcquisitionRow.EngagementRate);
      end;
    finally
      grdGeographyRows.EndUpdate;
    end;
  finally
    AcquisitionRows.Free;
  end;

  lblGeographyTitle.Text := Format('Traffic sources (%d)',
    [Snapshot.AcquisitionRows.Count]);
  lblGeographyRows.Text := 'How visitors arrived: source, medium, campaign, users, sessions, and engagement rate';
  if Snapshot.AcquisitionRows.Count = 0 then
    lblStatusBar.Text := 'GA4 returned no traffic source rows for this selection.';
end;

procedure TfrmMainDashboard.PopulateDeviceRows(
  const Snapshot: TGA4ReportSnapshot);
var
  DeviceIndex: Integer;
  DeviceRow: TGA4DeviceRow;
  DeviceRows: TList<TGA4DeviceRow>;
  RowIndex: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ConfigureGeographyGridColumns('Device', 'Browser', 'Operating system',
    'Users', 'Sessions', 'Notes');

  DeviceRows := TList<TGA4DeviceRow>.Create;
  try
    for DeviceIndex := 0 to Snapshot.DeviceRows.Count - 1 do
      DeviceRows.Add(Snapshot.DeviceRows[DeviceIndex]);

    DeviceRows.Sort(TComparer<TGA4DeviceRow>.Construct(
      function(const Left, Right: TGA4DeviceRow): Integer
      begin
        Result := CompareDeviceRowsAlphabetically(Left, Right);
      end));

    grdGeographyRows.BeginUpdate;
    try
      grdGeographyRows.RowCount := 0;
      for DeviceRow in DeviceRows do
      begin
        RowIndex := grdGeographyRows.RowCount;
        grdGeographyRows.RowCount := RowIndex + 1;
        grdGeographyRows.Cells[0, RowIndex] :=
          CleanLocationText(DeviceRow.DeviceCategory, '(device not set)');
        grdGeographyRows.Cells[1, RowIndex] :=
          CleanLocationText(DeviceRow.Browser, '(browser not set)');
        grdGeographyRows.Cells[2, RowIndex] :=
          CleanLocationText(DeviceRow.OperatingSystem, '(OS not set)');
        grdGeographyRows.Cells[3, RowIndex] :=
          FormatFloat('#,##0', DeviceRow.ActiveUsers);
        grdGeographyRows.Cells[4, RowIndex] :=
          FormatFloat('#,##0', DeviceRow.Sessions);
        grdGeographyRows.Cells[5, RowIndex] := '';
      end;
    finally
      grdGeographyRows.EndUpdate;
    end;
  finally
    DeviceRows.Free;
  end;

  lblGeographyTitle.Text := Format('Devices, browsers, and operating systems (%d)',
    [Snapshot.DeviceRows.Count]);
  lblGeographyRows.Text := 'Device category, browser, operating system, users, and sessions';
  if Snapshot.DeviceRows.Count = 0 then
    lblStatusBar.Text := 'GA4 returned no device rows for this selection.';
end;

procedure TfrmMainDashboard.PopulateLanguageRows(
  const Snapshot: TGA4ReportSnapshot);
var
  LanguageIndex: Integer;
  LanguageRow: TGA4LanguageRow;
  LanguageRows: TList<TGA4LanguageRow>;
  RowIndex: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  ConfigureGeographyGridColumns('Language', '', '', 'Users', 'Sessions',
    'Engagement rate');

  LanguageRows := TList<TGA4LanguageRow>.Create;
  try
    for LanguageIndex := 0 to Snapshot.LanguageRows.Count - 1 do
      LanguageRows.Add(Snapshot.LanguageRows[LanguageIndex]);

    LanguageRows.Sort(TComparer<TGA4LanguageRow>.Construct(
      function(const Left, Right: TGA4LanguageRow): Integer
      begin
        Result := CompareLanguageRowsAlphabetically(Left, Right);
      end));

    grdGeographyRows.BeginUpdate;
    try
      grdGeographyRows.RowCount := 0;
      for LanguageRow in LanguageRows do
      begin
        RowIndex := grdGeographyRows.RowCount;
        grdGeographyRows.RowCount := RowIndex + 1;
        grdGeographyRows.Cells[0, RowIndex] :=
          CleanLocationText(LanguageRow.Language, '(language not set)');
        grdGeographyRows.Cells[1, RowIndex] := '';
        grdGeographyRows.Cells[2, RowIndex] := '';
        grdGeographyRows.Cells[3, RowIndex] :=
          FormatFloat('#,##0', LanguageRow.ActiveUsers);
        grdGeographyRows.Cells[4, RowIndex] :=
          FormatFloat('#,##0', LanguageRow.Sessions);
        grdGeographyRows.Cells[5, RowIndex] :=
          FormatFloat('0.0%', LanguageRow.EngagementRate);
      end;
    finally
      grdGeographyRows.EndUpdate;
    end;
  finally
    LanguageRows.Free;
  end;

  lblGeographyTitle.Text := Format('Visitor languages (%d)',
    [Snapshot.LanguageRows.Count]);
  lblGeographyRows.Text := 'Language, users, sessions, and engagement rate';
  if Snapshot.LanguageRows.Count = 0 then
    lblStatusBar.Text := 'GA4 returned no language rows for this selection.';
end;

procedure TfrmMainDashboard.SelectedDateRange(out StartDate, EndDate: string);
begin
  EndDate := 'today';
  case cmbDateRange.ItemIndex of
    0: StartDate := 'today';
    1: StartDate := '6daysAgo';
    2: StartDate := '27daysAgo';
    3: StartDate := '89daysAgo';
    4: StartDate := FormatDateTime('yyyy"-01-01"', Date);
  else
    StartDate := '28daysAgo';
  end;
end;

procedure TfrmMainDashboard.SelectedPreviousDateRange(out StartDate,
  EndDate: string);
var
  CurrentEndDate: TDateTime;
  CurrentStartDate: TDateTime;
  PreviousEndDate: TDateTime;
  PreviousStartDate: TDateTime;
  RangeDays: Integer;
begin
  CurrentEndDate := Date;
  case cmbDateRange.ItemIndex of
    0:
      CurrentStartDate := Date;
    1:
      CurrentStartDate := Date - 6;
    2:
      CurrentStartDate := Date - 27;
    3:
      CurrentStartDate := Date - 89;
    4:
      CurrentStartDate := EncodeDate(YearOf(Date), 1, 1);
  else
    CurrentStartDate := Date - 28;
  end;

  RangeDays := Trunc(CurrentEndDate - CurrentStartDate);
  PreviousEndDate := CurrentStartDate - 1;
  PreviousStartDate := PreviousEndDate - RangeDays;
  StartDate := DateToGA4String(PreviousStartDate);
  EndDate := DateToGA4String(PreviousEndDate);
end;

procedure TfrmMainDashboard.UpdateComparisonLabels(
  const Snapshot: TGA4ReportSnapshot);
begin
  if not Assigned(Snapshot) then
    Exit;

  if chkComparePrevious.IsChecked and Snapshot.HasPreviousKpiSummary then
  begin
    lblUsersDelta.Visible := True;
    lblSessionsDelta.Visible := True;
    lblViewsDelta.Visible := True;
    lblEngagementDelta.Visible := True;

    lblUsersDelta.Text := FormatComparisonDelta(
      Snapshot.KpiSummary.ActiveUsers,
      Snapshot.PreviousKpiSummary.ActiveUsers, False);
    lblUsersDelta.TextSettings.FontColor := ComparisonDeltaColor(
      Snapshot.KpiSummary.ActiveUsers,
      Snapshot.PreviousKpiSummary.ActiveUsers);

    lblSessionsDelta.Text := FormatComparisonDelta(
      Snapshot.KpiSummary.Sessions,
      Snapshot.PreviousKpiSummary.Sessions, False);
    lblSessionsDelta.TextSettings.FontColor := ComparisonDeltaColor(
      Snapshot.KpiSummary.Sessions,
      Snapshot.PreviousKpiSummary.Sessions);

    lblViewsDelta.Text := FormatComparisonDelta(
      Snapshot.KpiSummary.ScreenPageViews,
      Snapshot.PreviousKpiSummary.ScreenPageViews, False);
    lblViewsDelta.TextSettings.FontColor := ComparisonDeltaColor(
      Snapshot.KpiSummary.ScreenPageViews,
      Snapshot.PreviousKpiSummary.ScreenPageViews);

    lblEngagementDelta.Text := FormatComparisonDelta(
      Snapshot.KpiSummary.EngagementRate,
      Snapshot.PreviousKpiSummary.EngagementRate, True);
    lblEngagementDelta.TextSettings.FontColor := ComparisonDeltaColor(
      Snapshot.KpiSummary.EngagementRate,
      Snapshot.PreviousKpiSummary.EngagementRate);
  end
  else
  begin
    lblUsersDelta.Visible := False;
    lblSessionsDelta.Visible := False;
    lblViewsDelta.Visible := False;
    lblEngagementDelta.Visible := False;
    lblUsersDelta.Text := '';
    lblSessionsDelta.Text := '';
    lblViewsDelta.Text := '';
    lblEngagementDelta.Text := '';
  end;
end;

procedure TfrmMainDashboard.UpdateDashboardFromSnapshot(
  const Snapshot: TGA4ReportSnapshot);
begin
  if not Assigned(Snapshot) then
    Exit;

  lblUsersValue.Text := FormatFloat('#,##0', Snapshot.KpiSummary.ActiveUsers);
  lblSessionsValue.Text := FormatFloat('#,##0', Snapshot.KpiSummary.Sessions);
  lblViewsValue.Text := FormatFloat('#,##0', Snapshot.KpiSummary.ScreenPageViews);
  lblEngagementValue.Text := FormatFloat('0.0%', Snapshot.KpiSummary.EngagementRate);
  UpdateComparisonLabels(Snapshot);

  GeographyPreviewCard.Visible := True;
  ContentPreviewCard.Visible := True;
  RealtimePreviewCard.Visible := False;
  FLocationListMode := llmAllLocations;
  FContentListMode := clmAllRows;
  PopulateGeographyRows(Snapshot);
  PopulateContentRows(Snapshot);
  PopulateRealtimePanel(Snapshot);
  UpdateSummaryTiles(Snapshot);

  pbWeeklyUsers.Repaint;
  if Assigned(pbTopPagesDownloads) then
    pbTopPagesDownloads.Repaint;
end;

procedure TfrmMainDashboard.UpdateSummaryTiles(
  const Snapshot: TGA4ReportSnapshot);
var
  ContentIndex: Integer;
  TrendIndex: Integer;
  DownloadTotal: Double;
  RangeUsers: Double;
  TodayUsers: Double;
  TodayViews: Double;
  TopPageValue: Double;
  TopPageText: string;
  LastLocationText: string;
  DownloadRangeText: string;
  EventText: string;
  ContentRow: TGA4ContentRow;
begin
  if not Assigned(Snapshot) then
    Exit;

  DownloadTotal := 0;
  TopPageValue := -1;
  TopPageText := 'None';
  for ContentIndex := 0 to Snapshot.ContentRows.Count - 1 do
  begin
    ContentRow := Snapshot.ContentRows[ContentIndex];
    EventText := LowerCase(ContentRow.EventName);
    if Pos('download', EventText) > 0 then
      DownloadTotal := DownloadTotal + ContentRow.EventCount;

    if ContentRow.ScreenPageViews > TopPageValue then
    begin
      TopPageValue := ContentRow.ScreenPageViews;
      TopPageText := CleanLocationText(ContentRow.PageTitle, '');
      if TopPageText = '' then
        TopPageText := CleanLocationText(ContentRow.PagePath, 'None');
      if (TopPageText = '/') or SameText(TopPageText, '(title not set)') then
        TopPageText := 'Home page';
    end;
  end;

  RangeUsers := Snapshot.KpiSummary.ActiveUsers;
  TodayUsers := 0;
  TodayViews := 0;
  for TrendIndex := 0 to Snapshot.TrendPoints.Count - 1 do
  begin
    if SameDate(Snapshot.TrendPoints[TrendIndex].DateValue, Date) then
    begin
      TodayUsers := Snapshot.TrendPoints[TrendIndex].ActiveUsers;
      TodayViews := Snapshot.TrendPoints[TrendIndex].ScreenPageViews;
    end;
  end;
  if (TodayUsers = 0) and (cmbDateRange.ItemIndex = 0) then
  begin
    TodayUsers := Snapshot.KpiSummary.ActiveUsers;
    TodayViews := Snapshot.KpiSummary.ScreenPageViews;
  end;

  LastLocationText := FLastLocationTileText;
  if Snapshot.RealtimeSummary.HasLastActivity then
  begin
    LastLocationText := CleanLocationText(Snapshot.RealtimeSummary.LastCity, '');
    if LastLocationText <> '' then
      LastLocationText := LastLocationText + ', ';
    LastLocationText := LastLocationText +
      CleanLocationText(Snapshot.RealtimeSummary.LastCountry, 'Unknown');
    FLastLocationTileText := LastLocationText;
  end;

  case cmbDateRange.ItemIndex of
    0:
      DownloadRangeText := 'Today';
    1:
      DownloadRangeText := 'Last 7 days';
    2:
      DownloadRangeText := 'Last 28 days';
    3:
      DownloadRangeText := 'Last 90 days';
    4:
      DownloadRangeText := 'This year';
  else
    DownloadRangeText := 'Selected range';
  end;

  lblTileUsersTodayValue.Text := FormatFloat('#,##0', TodayUsers);
  lblTileUsersRangeTitle.Text := 'Users for' + sLineBreak + DownloadRangeText;
  lblTileUsersRangeValue.Text := FormatFloat('#,##0', RangeUsers);
  lblTileViewsTodayValue.Text := FormatFloat('#,##0', TodayViews);
  lblTileDownloadsTodayTitle.Text := 'Downloads' + sLineBreak + DownloadRangeText;
  lblTileDownloadsTodayValue.Text := FormatFloat('#,##0', DownloadTotal);
  lblTileActiveNowValue.Text := FormatFloat('#,##0',
    Snapshot.RealtimeSummary.ActiveUsers);
  lblTileLastLocationValue.Text := LastLocationText;
  lblTileTopPageValue.Text := TopPageText;
  lblTileRealtimeViewsTitle.Text := 'Views last 30 min';
  lblTileRealtimeViewsValue.Text := FormatFloat('#,##0',
    Snapshot.RealtimeSummary.ScreenPageViews);
end;

procedure TfrmMainDashboard.PopulateRealtimePanel(
  const Snapshot: TGA4ReportSnapshot);
var
  ActivityCity: string;
  ActivityCountry: string;
  ActivityLocation: string;
  ActivityTime: TDateTime;
begin
  if not Assigned(Snapshot) then
    Exit;

  lblRealtimeTitle.Text := 'What is happening right now?';
  lblRealtimeActiveValue.Text := FormatFloat('#,##0',
    Snapshot.RealtimeSummary.ActiveUsers);
  lblRealtimeActiveCaption.Text := 'Current active visitors';

  if Snapshot.RealtimeSummary.HasLastActivity then
  begin
    ActivityCity := CleanLocationText(Snapshot.RealtimeSummary.LastCity, '');
    ActivityCountry := CleanLocationText(Snapshot.RealtimeSummary.LastCountry, '');

    if (ActivityCity <> '') and (ActivityCountry <> '') then
      ActivityLocation := ActivityCity + ', ' + ActivityCountry
    else if ActivityCountry <> '' then
      ActivityLocation := ActivityCountry
    else if ActivityCity <> '' then
      ActivityLocation := ActivityCity
    else
      ActivityLocation := 'an unknown location';

    ActivityTime := IncMinute(Now, -Snapshot.RealtimeSummary.LastMinutesAgo);
    FLastRealtimeActivityText := 'Current location: ' + ActivityLocation +
      sLineBreak + 'Last activity: ' +
      ' on ' + FormatDateTime('m/d/yyyy', ActivityTime) +
      ' at ' + FormatDateTime('h:nn:ss AM/PM', ActivityTime);
  end;

  lblRealtimeActivity.Text := FLastRealtimeActivityText;
end;

procedure TfrmMainDashboard.FetchPropertyReportsWithTokenRefresh(
  const WebsiteProperty: TWebsitePropertyDefinition; const StartDate,
  EndDate: string; const TargetSnapshot: TGA4ReportSnapshot);
var
  OAuthClientId: string;
  OAuthClientSecret: string;
  PreviousEndDate: string;
  PreviousStartDate: string;

  procedure FetchReportsWithCurrentToken;
  begin
    dmGA4.FetchStandardReports(dmAuthentication.AccessToken,
      WebsiteProperty.PropertyId, StartDate, EndDate,
      TargetSnapshot);

    if chkComparePrevious.IsChecked then
    begin
      SelectedPreviousDateRange(PreviousStartDate, PreviousEndDate);
      dmGA4.FetchKpiSummary(dmAuthentication.AccessToken,
        WebsiteProperty.PropertyId, PreviousStartDate, PreviousEndDate,
        TargetSnapshot.PreviousKpiSummary);
      TargetSnapshot.HasPreviousKpiSummary := True;
    end;
  end;

begin
  try
    FetchReportsWithCurrentToken;
  except
    on E: Exception do
    begin
      if not IsTokenRefreshableError(E.Message) then
        raise;

      OAuthClientId := dmSettings.ReadSetting('ga4_oauth_client_id', '');
      OAuthClientSecret := dmSettings.ReadSetting('ga4_oauth_client_secret', '');
      lblStatusBar.Text := 'Google token expired; refreshing access token and retrying update.';
      Application.ProcessMessages;
      if not dmAuthentication.RefreshAccessToken(OAuthClientId, OAuthClientSecret) then
        raise Exception.Create(dmAuthentication.LastStatus);

      FetchReportsWithCurrentToken;
    end;
  end;
end;

procedure TfrmMainDashboard.FetchSessionsByDateWithTokenRefresh(
  const WebsiteProperty: TWebsitePropertyDefinition; const ReportDate: string);
var
  OAuthClientId: string;
  OAuthClientSecret: string;

  procedure FetchSessionsByDateWithCurrentToken;
  begin
    dmGA4.FetchSessionsByDate(dmAuthentication.AccessToken,
      WebsiteProperty.PropertyId, ReportDate,
      dmAnalyticsMemory.CurrentSnapshot);
  end;

begin
  try
    FetchSessionsByDateWithCurrentToken;
  except
    on E: Exception do
    begin
      if not IsTokenRefreshableError(E.Message) then
        raise;

      OAuthClientId := dmSettings.ReadSetting('ga4_oauth_client_id', '');
      OAuthClientSecret := dmSettings.ReadSetting('ga4_oauth_client_secret', '');
      lblStatusBar.Text := 'Google token expired; refreshing access token and retrying date sessions.';
      Application.ProcessMessages;
      if not dmAuthentication.RefreshAccessToken(OAuthClientId, OAuthClientSecret) then
        raise Exception.Create(dmAuthentication.LastStatus);

      FetchSessionsByDateWithCurrentToken;
    end;
  end;
end;

procedure TfrmMainDashboard.RefreshSessionsByDate;
var
  ReportDate: string;
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  if not Assigned(dmAnalyticsMemory) or
    not Assigned(dmAnalyticsMemory.CurrentSnapshot) then
    Exit;

  WebsiteProperty := SelectedPropertyForUpdate;
  if WebsiteProperty = nil then
  begin
    dmAnalyticsMemory.CurrentSnapshot.SessionsByDateRows.Clear;
    PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot);
    lblStatusBar.Text := 'Enable at least one website property before loading sessions by date.';
    Exit;
  end;

  if Trim(WebsiteProperty.PropertyId) = '' then
  begin
    dmAnalyticsMemory.CurrentSnapshot.SessionsByDateRows.Clear;
    PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot);
    lblStatusBar.Text := 'Enter the numeric GA4 property ID before loading sessions by date.';
    Exit;
  end;

  if not dmAuthentication.Authenticated then
  begin
    dmAnalyticsMemory.CurrentSnapshot.SessionsByDateRows.Clear;
    PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot);
    lblStatusBar.Text := 'Connect Google before loading sessions by date.';
    Exit;
  end;

  ReportDate := DateToGA4String(dtSessionsByDate.Date);
  UpdateChartTitle;
  lblStatusBar.Text := 'Loading sessions by date for ' +
    FormatDateTime('m/d/yyyy', dtSessionsByDate.Date) + '.';
  Application.ProcessMessages;
  try
    FetchSessionsByDateWithTokenRefresh(WebsiteProperty, ReportDate);
    PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot);
    pbWeeklyUsers.Repaint;
    lblStatusBar.Text := 'Sessions by date loaded for ' +
      FormatDateTime('m/d/yyyy', dtSessionsByDate.Date) + '.';
  except
    on E: Exception do
    begin
      dmAnalyticsMemory.CurrentSnapshot.SessionsByDateRows.Clear;
      PopulateSessionsByDateRows(dmAnalyticsMemory.CurrentSnapshot);
      pbWeeklyUsers.Repaint;
      lblStatusBar.Text := E.Message;
    end;
  end;
end;

function TfrmMainDashboard.SelectedPropertyForUpdate: TWebsitePropertyDefinition;
var
  PropertyIndex: Integer;
  EnabledIndex: Integer;
begin
  Result := nil;
  if IsAllWebsitesSelected then
    Exit;

  EnabledIndex := 0;

  for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
    if dmAnalyticsMemory[PropertyIndex].Enabled then
    begin
      if cmbWebsite.ItemIndex = EnabledIndex + 1 then
        Exit(dmAnalyticsMemory[PropertyIndex]);
      Inc(EnabledIndex);
    end;
end;

procedure TfrmMainDashboard.pbTopPagesDownloadsPaint(Sender: TObject;
  Canvas: TCanvas);
var
  PaintBox: TPaintBox;
  ChartRect: TRectF;
  Labels: TArray<string>;
  Values: TArray<Double>;
  ScaleMax: Double;
  BarIndex: Integer;
  BarHeight: Single;
  BarRect: TRectF;
  RowTop: Single;
  RowStep: Single;
  LabelRect: TRectF;
  ValueText: string;
begin
  if not (Sender is TPaintBox) then
    Exit;

  PaintBox := TPaintBox(Sender);
  BuildTopPagesChartData(PaintBox, ChartRect, Labels, Values, ScaleMax);

  if Length(Values) = 0 then
  begin
    Canvas.Fill.Color := $FF9FB4D1;
    Canvas.Font.Size := 13;
    Canvas.FillText(RectF(0, 0, PaintBox.Width, PaintBox.Height),
      'No page or download data for the current selection.', False, 1, [],
      TTextAlign.Center, TTextAlign.Center);
    Exit;
  end;

  Canvas.Font.Size := 12;
  RowStep := ChartRect.Height / Length(Values);
  BarHeight := Min(24, RowStep * 0.52);

  for BarIndex := 0 to Length(Values) - 1 do
  begin
    RowTop := ChartRect.Top + (RowStep * BarIndex);
    LabelRect := RectF(ChartRect.Left, RowTop, ChartRect.Left + 230,
      RowTop + RowStep);
    Canvas.Fill.Color := $FFE5F0FF;
    Canvas.FillText(LabelRect, Labels[BarIndex], False, 1, [],
      TTextAlign.Leading, TTextAlign.Center);

    BarRect := RectF(ChartRect.Left + 240, RowTop + ((RowStep - BarHeight) / 2),
      ChartRect.Left + 240 + ((ChartRect.Width - 300) *
      (Values[BarIndex] / ScaleMax)),
      RowTop + ((RowStep - BarHeight) / 2) + BarHeight);
    Canvas.Fill.Color := $FF38BDF8;
    Canvas.Stroke.Color := $FF7DD3FC;
    Canvas.Stroke.Thickness := 1;
    Canvas.FillRect(BarRect, 4, 4, AllCorners, 1);
    Canvas.DrawRect(BarRect, 4, 4, AllCorners, 1);

    ValueText := FormatFloat('#,##0', Values[BarIndex]);
    Canvas.Fill.Color := $FFFFD166;
    Canvas.FillText(RectF(ChartRect.Right - 46, RowTop, ChartRect.Right,
      RowTop + RowStep), ValueText, False, 1, [], TTextAlign.Trailing,
      TTextAlign.Center);
  end;
end;

procedure TfrmMainDashboard.FetchReportsWithTokenRefresh(
  const WebsiteProperty: TWebsitePropertyDefinition; const StartDate,
  EndDate: string);
begin
  FetchPropertyReportsWithTokenRefresh(WebsiteProperty, StartDate, EndDate,
    dmAnalyticsMemory.CurrentSnapshot);
end;

procedure TfrmMainDashboard.FetchAllWebsiteReportsWithTokenRefresh(
  const StartDate, EndDate: string);
var
  PropertyIndex: Integer;
  TemporarySnapshot: TGA4ReportSnapshot;
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  dmAnalyticsMemory.CurrentSnapshot.Clear;
  TemporarySnapshot := TGA4ReportSnapshot.Create;
  try
    for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
    begin
      WebsiteProperty := dmAnalyticsMemory[PropertyIndex];
      if (not WebsiteProperty.Enabled) or (Trim(WebsiteProperty.PropertyId) = '') then
        Continue;

      TemporarySnapshot.Clear;
      lblStatusBar.Text := 'Calling GA4 Data API for ' +
        WebsiteProperty.DisplayName + '.';
      Application.ProcessMessages;
      FetchPropertyReportsWithTokenRefresh(WebsiteProperty, StartDate, EndDate,
        TemporarySnapshot);
      MergeSnapshotIntoCurrent(TemporarySnapshot);
    end;
  finally
    TemporarySnapshot.Free;
  end;
end;

procedure TfrmMainDashboard.pbTopPagesDownloadsMouseLeave(Sender: TObject);
begin
  HideTopPagesTooltip;
end;

procedure TfrmMainDashboard.pbTopPagesDownloadsMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var
  PaintBox: TPaintBox;
  ChartRect: TRectF;
  Labels: TArray<string>;
  Values: TArray<Double>;
  ScaleMax: Double;
  BarIndex: Integer;
  BarHeight: Single;
  BarRect: TRectF;
  RowTop: Single;
  RowStep: Single;
  TooltipLeft: Single;
  TooltipTop: Single;
begin
  if not (Sender is TPaintBox) then
    Exit;

  PaintBox := TPaintBox(Sender);
  BuildTopPagesChartData(PaintBox, ChartRect, Labels, Values, ScaleMax);
  if Length(Values) = 0 then
  begin
    HideTopPagesTooltip;
    Exit;
  end;

  RowStep := ChartRect.Height / Length(Values);
  BarHeight := Min(24, RowStep * 0.52);
  for BarIndex := 0 to Length(Values) - 1 do
  begin
    RowTop := ChartRect.Top + (RowStep * BarIndex);
    BarRect := RectF(ChartRect.Left + 240, RowTop + ((RowStep - BarHeight) / 2),
      ChartRect.Left + 240 + ((ChartRect.Width - 300) *
      (Values[BarIndex] / ScaleMax)),
      RowTop + ((RowStep - BarHeight) / 2) + BarHeight);

    if BarRect.Contains(PointF(X, Y)) then
    begin
      lblTopPagesTooltip.Text := Labels[BarIndex] + sLineBreak +
        'Events: ' + FormatFloat('#,##0', Values[BarIndex]);
      TooltipLeft := PaintBox.Position.X + BarRect.Right + 10;
      TooltipTop := PaintBox.Position.Y + BarRect.Top - 8;
      TooltipLeft := Min(Max(8, TooltipLeft),
        ContentPreviewCard.Width - TopPagesTooltip.Width - 8);
      TooltipTop := Min(Max(8, TooltipTop),
        ContentPreviewCard.Height - TopPagesTooltip.Height - 8);
      TopPagesTooltip.Position.X := TooltipLeft;
      TopPagesTooltip.Position.Y := TooltipTop;
      TopPagesTooltip.Visible := True;
      TopPagesTooltip.BringToFront;
      Exit;
    end;
  end;

  HideTopPagesTooltip;
end;

procedure TfrmMainDashboard.pbWeeklyUsersPaint(Sender: TObject; Canvas: TCanvas);
var
  PaintBox: TPaintBox;
  ChartRect: TRectF;
  PointIndex: Integer;
  Points: TArray<TPointF>;
  Values: TArray<Double>;
  Labels: TArray<string>;
  ScaleMax: Double;
  BarRect: TRectF;
  BarWidth: Single;
  LabelStep: Integer;
  TrendCount: Integer;
  TickIndex: Integer;
  TickCount: Integer;
  TickStep: Integer;
  TickValue: Double;
  TickY: Single;
begin
  if not (Sender is TPaintBox) then
    Exit;

  PaintBox := TPaintBox(Sender);
  BuildTrendChartData(PaintBox, ChartRect, Points, Values, Labels, ScaleMax);
  TrendCount := Length(Points);
  if TrendCount = 0 then
  begin
    Canvas.Fill.Color := $FF9FB4D1;
    Canvas.Font.Size := 13;
    Canvas.FillText(RectF(0, 0, PaintBox.Width, PaintBox.Height),
      'No chart data for the current grid.', False, 1, [],
      TTextAlign.Center, TTextAlign.Center);
    Exit;
  end;

  Canvas.Stroke.Color := $FF2B4F76;
  Canvas.Stroke.Thickness := 1;
  Canvas.Fill.Color := $FFBFD4F2;
  Canvas.Font.Size := 11;
  TickStep := Max(1, Ceil(ScaleMax / 5));
  TickCount := Trunc(Ceil(ScaleMax / TickStep)) + 1;

  for TickIndex := 0 to TickCount - 1 do
  begin
    TickValue := Max(0, ScaleMax - (TickStep * TickIndex));
    TickY := ChartRect.Bottom - (TickValue / ScaleMax) * ChartRect.Height;
    Canvas.DrawLine(
      PointF(ChartRect.Left, TickY),
      PointF(ChartRect.Right, TickY),
      1);
    Canvas.FillText(RectF(0, TickY - 9, ChartRect.Left - 8, TickY + 9),
      FormatTrendScaleValue(TickValue), False, 1, [], TTextAlign.Trailing,
      TTextAlign.Center);
  end;

  BarWidth := Max(4, Min(42, ChartRect.Width / TrendCount * 0.62));
  Canvas.Fill.Color := $FF38BDF8;
  Canvas.Stroke.Color := $FF7DD3FC;
  Canvas.Stroke.Thickness := 1;
  LabelStep := Max(1, Ceil(TrendCount / 8));
  for PointIndex := 0 to TrendCount - 1 do
  begin
    BarRect := RectF(Points[PointIndex].X - (BarWidth / 2), Points[PointIndex].Y,
      Points[PointIndex].X + (BarWidth / 2), ChartRect.Bottom);
    if Values[PointIndex] <= 0 then
      BarRect.Top := ChartRect.Bottom - 2;
    Canvas.FillRect(BarRect, 3, 3, AllCorners, 1);
    Canvas.DrawRect(BarRect, 3, 3, AllCorners, 1);
  end;

  Canvas.Fill.Color := $FF9FB4D1;
  Canvas.Font.Size := 11;
  for PointIndex := 0 to TrendCount - 1 do
  begin
    if (PointIndex <> 0) and (PointIndex <> TrendCount - 1) and
      ((PointIndex mod LabelStep) <> 0) then
      Continue;

    Canvas.FillText(RectF(Points[PointIndex].X - 24, ChartRect.Bottom + 6,
      Points[PointIndex].X + 24, PaintBox.Height), Labels[PointIndex], False, 1, [],
      TTextAlign.Center, TTextAlign.Leading);
  end;
end;

procedure TfrmMainDashboard.pbWeeklyUsersMouseLeave(Sender: TObject);
begin
  HideTrendTooltip;
end;

procedure TfrmMainDashboard.pbWeeklyUsersMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Single);
var
  PaintBox: TPaintBox;
  ChartRect: TRectF;
  Points: TArray<TPointF>;
  Values: TArray<Double>;
  Labels: TArray<string>;
  ScaleMax: Double;
  PointIndex: Integer;
  BarRect: TRectF;
  BarWidth: Single;
  BestIndex: Integer;
  TooltipLeft: Single;
  TooltipTop: Single;
begin
  if not (Sender is TPaintBox) then
    Exit;

  PaintBox := TPaintBox(Sender);
  BuildTrendChartData(PaintBox, ChartRect, Points, Values, Labels, ScaleMax);
  BestIndex := -1;
  if Length(Points) = 0 then
  begin
    HideTrendTooltip;
    Exit;
  end;

  BarWidth := Max(4, Min(42, ChartRect.Width / Length(Points) * 0.62));
  for PointIndex := 0 to Length(Points) - 1 do
  begin
    BarRect := RectF(Points[PointIndex].X - (BarWidth / 2),
      Points[PointIndex].Y, Points[PointIndex].X + (BarWidth / 2),
      ChartRect.Bottom);
    if Values[PointIndex] <= 0 then
      BarRect.Top := ChartRect.Bottom - 4;
    if BarRect.Contains(PointF(X, Y)) then
    begin
      BestIndex := PointIndex;
      Break;
    end;
  end;

  if BestIndex < 0 then
  begin
    HideTrendTooltip;
    Exit;
  end;

  lblTrendTooltip.Text := Labels[BestIndex] + sLineBreak +
    'Users: ' + FormatTrendTooltipValue(Values[BestIndex]);
  TooltipLeft := PaintBox.Position.X + Points[BestIndex].X + 12;
  TooltipTop := PaintBox.Position.Y + Points[BestIndex].Y - 50;
  TooltipLeft := Min(Max(8, TooltipLeft),
    WeeklyUsersChartCard.Width - TrendTooltip.Width - 8);
  TooltipTop := Min(Max(8, TooltipTop),
    WeeklyUsersChartCard.Height - TrendTooltip.Height - 8);
  TrendTooltip.Position.X := TooltipLeft;
  TrendTooltip.Position.Y := TooltipTop;
  TrendTooltip.Visible := True;
  TrendTooltip.BringToFront;
end;

procedure TfrmMainDashboard.NavigationButtonClick(Sender: TObject);
begin
  if Sender is TButton then
    SelectSection(TButton(Sender).Tag);
end;

procedure TfrmMainDashboard.RoundedTabClick(Sender: TObject);
var
  TabIndex: Integer;
begin
  if not (Sender is TRectangle) then
    Exit;

  TabIndex := TRectangle(Sender).Tag;
  if DashboardTabs.TabIndex = TabIndex then
    DashboardTabsChange(DashboardTabs)
  else
    DashboardTabs.TabIndex := TabIndex;
end;

procedure TfrmMainDashboard.RefreshDashboardForSelectorChange(
  const ReasonText: string);
begin
  if not FSelectorChangeEnabled then
    Exit;

  dmSettings.WriteSetting('default_website_index',
    IntToStr(Max(0, cmbWebsite.ItemIndex)), 'dashboard',
    'Default selected website, where 0 means all websites');
  dmSettings.WriteSetting('default_date_range_index',
    IntToStr(Max(0, cmbDateRange.ItemIndex)), 'dashboard',
    'Default date range selection');
  UpdateChartTitle;

  if not dmAuthentication.Authenticated then
  begin
    lblStatusBar.Text := ReasonText +
      ' selected. Connect Google or click Update after authentication to retrieve live GA4 data.';
    if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) then
      UpdateDashboardFromSnapshot(dmAnalyticsMemory.CurrentSnapshot);
    Exit;
  end;

  if not btnUpdate.Enabled then
  begin
    lblStatusBar.Text := ReasonText +
      ' selected; waiting for the current update to finish.';
    Exit;
  end;

  lblStatusBar.Text := ReasonText + ' selected; refreshing GA4 data.';
  btnUpdateClick(btnUpdate);
end;

procedure TfrmMainDashboard.btnHelpClick(Sender: TObject);
var
  HelpPath: string;
begin
  HelpPath := FindHelpIndexPath;
  if HelpPath = '' then
  begin
    lblStatusBar.Text := 'Help file not found. Expected help\index.html beside the app or project folder.';
    Exit;
  end;

  ShellExecute(0, 'open', PChar(HelpPath), nil,
    PChar(System.IOUtils.TPath.GetDirectoryName(HelpPath)), SW_SHOWNORMAL);
  lblStatusBar.Text := 'Opened Website Analytics help.';
end;

procedure TfrmMainDashboard.chkAutoUpdateChange(Sender: TObject);
begin
  AutoUpdateTimer.Enabled := chkAutoUpdate.IsChecked;
  if chkAutoUpdate.IsChecked then
  begin
    dmSettings.WriteSetting('auto_update_enabled', '1', 'dashboard',
      'Refresh the dashboard automatically every 60 seconds while authenticated');
    lblStatusBar.Text := 'Automatic updates are on; the dashboard refreshes every 60 seconds while connected.';
  end
  else
  begin
    dmSettings.WriteSetting('auto_update_enabled', '0', 'dashboard',
      'Refresh the dashboard automatically every 60 seconds while authenticated');
    lblStatusBar.Text := 'Automatic updates are off.';
  end;
end;

procedure TfrmMainDashboard.chkComparePreviousChange(Sender: TObject);
begin
  if chkComparePrevious.IsChecked then
  begin
    dmSettings.WriteSetting('compare_previous_period', '1', 'dashboard',
      'Compare dashboard KPIs with the immediately preceding period');
    lblStatusBar.Text := 'Previous-period comparison is on; KPI cards will show deltas after the next update.';
  end
  else
  begin
    dmSettings.WriteSetting('compare_previous_period', '0', 'dashboard',
      'Compare dashboard KPIs with the immediately preceding period');
    lblStatusBar.Text := 'Previous-period comparison is off.';
  end;

  if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) then
    UpdateComparisonLabels(dmAnalyticsMemory.CurrentSnapshot);

  if FSelectorChangeEnabled and dmAuthentication.Authenticated and btnUpdate.Enabled then
    btnUpdateClick(btnUpdate);
end;

procedure TfrmMainDashboard.cmbWebsiteChange(Sender: TObject);
begin
  FLastRealtimeActivityText := 'Current location: None' + sLineBreak +
    'Last activity: None';
  FLastLocationTileText := 'None';
  lblRealtimeActivity.Text := FLastRealtimeActivityText;
  RefreshDashboardForSelectorChange('Website property');
end;

procedure TfrmMainDashboard.cmbDateRangeChange(Sender: TObject);
begin
  RefreshDashboardForSelectorChange('Date range');
end;

procedure TfrmMainDashboard.cmbChartMetricChange(Sender: TObject);
begin
  UpdateChartTitle;
  pbWeeklyUsers.Repaint;
end;

procedure TfrmMainDashboard.cmbContentFilterChange(Sender: TObject);
begin
  case cmbContentFilter.ItemIndex of
    1:
      FContentListMode := clmPagesOnly;
    2:
      FContentListMode := clmDownloadsOnly;
    3:
      FContentListMode := clmActionsOnly;
  else
    FContentListMode := clmAllRows;
  end;

  if Assigned(dmAnalyticsMemory) and Assigned(dmAnalyticsMemory.CurrentSnapshot) then
    PopulateContentRows(dmAnalyticsMemory.CurrentSnapshot);
end;

procedure TfrmMainDashboard.dtSessionsByDateChange(Sender: TObject);
begin
  if FSelectorChangeEnabled and
    (DashboardTabs.TabIndex = SECTION_SESSIONS_BY_DATE) then
    RefreshSessionsByDate;
end;

procedure TfrmMainDashboard.btnSessionsByDateRefreshClick(Sender: TObject);
begin
  RefreshSessionsByDate;
end;

procedure TfrmMainDashboard.AuthStartupTimerTimer(Sender: TObject);
var
  OAuthClientId: string;
  OAuthClientSecret: string;
  OAuthPort: string;
begin
  if dmAuthentication.Authenticated then
  begin
    lblConnectionStatus.Text := 'Connected';
    if not FStartupUpdateDone then
    begin
      FStartupUpdateDone := True;
      lblRefreshStatus.Text := 'Google connected automatically; updating dashboard.';
      lblStatusBar.Text := 'Google connected automatically; updating dashboard.';
      btnUpdateClick(btnUpdate);
    end;
    AuthStartupTimer.Enabled := False;
    Exit;
  end;

  if FStartupAuthStarted then
  begin
    if dmAuthentication.OAuthFlowComplete then
    begin
      lblConnectionStatus.Text := 'OAuth failed';
      lblRefreshStatus.Text := dmAuthentication.LastStatus;
      lblStatusBar.Text := 'Startup auto-connect did not complete.';
      AuthStartupTimer.Enabled := False;
    end;
    Exit;
  end;

  OAuthClientId := dmSettings.ReadSetting('ga4_oauth_client_id', '');
  OAuthClientSecret := dmSettings.ReadSetting('ga4_oauth_client_secret', '');
  OAuthPort := dmSettings.ReadSetting('ga4_oauth_redirect_port', '53682');
  if Trim(OAuthClientId) = '' then
  begin
    lblConnectionStatus.Text := 'Setup needed';
    lblRefreshStatus.Text := 'Open Settings once and enter the Google OAuth client details.';
    lblStatusBar.Text := 'Open Settings once and enter the Google OAuth client details.';
    AuthStartupTimer.Enabled := False;
    Exit;
  end;

  if dmAuthentication.LoadSavedRefreshToken then
  begin
    lblConnectionStatus.Text := 'Connecting';
    lblRefreshStatus.Text := 'Using saved Google authorization; refreshing access silently.';
    lblStatusBar.Text := 'Using saved Google authorization; refreshing access silently.';
    Application.ProcessMessages;
    if dmAuthentication.RefreshAccessToken(OAuthClientId, OAuthClientSecret) then
      Exit;

    dmAuthentication.ClearSavedRefreshToken;
    lblRefreshStatus.Text := 'Saved Google authorization expired; opening Google sign-in.';
    lblStatusBar.Text := 'Saved Google authorization expired; opening Google sign-in.';
    Application.ProcessMessages;
  end;

  FStartupAuthStarted := True;
  lblConnectionStatus.Text := 'Connecting';
  lblRefreshStatus.Text := 'Opening Google sign-in automatically.';
  lblStatusBar.Text := 'Opening Google sign-in because saved authorization is not available.';
  if not dmAuthentication.StartDesktopOAuth(OAuthClientId, OAuthClientSecret,
    OAuthPort) then
  begin
    lblConnectionStatus.Text := 'OAuth needed';
    lblRefreshStatus.Text := dmAuthentication.LastStatus;
    AuthStartupTimer.Enabled := False;
  end;
end;

procedure TfrmMainDashboard.AutoUpdateTimerTimer(Sender: TObject);
begin
  if not chkAutoUpdate.IsChecked then
    Exit;

  if not dmAuthentication.Authenticated then
    Exit;

  if not btnUpdate.Enabled then
    Exit;

  lblStatusBar.Text := 'Auto update started; refreshing GA4 data.';
  btnUpdateClick(btnUpdate);
end;

procedure TfrmMainDashboard.DashboardTabsChange(Sender: TObject);
begin
  UpdateRoundedTabStyles;
  case DashboardTabs.TabIndex of
    SECTION_USA:
      begin
        FLastReportTabIndex := SECTION_USA;
        SelectSection(SECTION_USA);
      end;
    SECTION_SESSIONS_BY_DATE:
      begin
        FLastReportTabIndex := SECTION_SESSIONS_BY_DATE;
        SelectSection(SECTION_SESSIONS_BY_DATE);
        RefreshSessionsByDate;
      end;
    SECTION_DOWNLOADS:
      begin
        FLastReportTabIndex := SECTION_DOWNLOADS;
        SelectSection(SECTION_DOWNLOADS);
      end;
    SECTION_SOURCES:
      begin
        FLastReportTabIndex := SECTION_SOURCES;
        SelectSection(SECTION_SOURCES);
      end;
    SECTION_DEVICES:
      begin
        FLastReportTabIndex := SECTION_DEVICES;
        SelectSection(SECTION_DEVICES);
      end;
    SECTION_LANGUAGES:
      begin
        FLastReportTabIndex := SECTION_LANGUAGES;
        SelectSection(SECTION_LANGUAGES);
      end;
    SECTION_COUNTRIES:
      begin
        FLastReportTabIndex := SECTION_COUNTRIES;
        SelectSection(SECTION_COUNTRIES);
      end;
    SECTION_REALTIME:
      begin
        FLastReportTabIndex := SECTION_REALTIME;
        SelectSection(SECTION_REALTIME);
      end;
    SECTION_PROPERTIES:
      begin
        btnManagePropertiesClick(Sender);
        DashboardTabs.TabIndex := FLastReportTabIndex;
        UpdateRoundedTabStyles;
      end;
    SECTION_SETTINGS:
      begin
        btnSettingsClick(Sender);
        DashboardTabs.TabIndex := FLastReportTabIndex;
        UpdateRoundedTabStyles;
      end;
    SECTION_DIAGNOSTICS:
      begin
        btnDiagnosticsClick(Sender);
        DashboardTabs.TabIndex := FLastReportTabIndex;
        UpdateRoundedTabStyles;
      end;
  else
    SelectSection(SECTION_USA);
  end;
end;

procedure TfrmMainDashboard.btnUpdateClick(Sender: TObject);
var
  WebsiteProperty: TWebsitePropertyDefinition;
  PropertyIndex: Integer;
  PropertyIdCount: Integer;
  OAuthClientId: string;
  OAuthPort: string;
  AuthorizationUrl: string;
  RequestJson: string;
  StartDate: string;
  EndDate: string;
begin
  WebsiteProperty := SelectedPropertyForUpdate;
  PropertyIdCount := 0;
  if IsAllWebsitesSelected then
  begin
    for PropertyIndex := 0 to dmAnalyticsMemory.PropertyCount - 1 do
      if dmAnalyticsMemory[PropertyIndex].Enabled and
        (Trim(dmAnalyticsMemory[PropertyIndex].PropertyId) <> '') then
        Inc(PropertyIdCount);
  end
  else if Assigned(WebsiteProperty) and (Trim(WebsiteProperty.PropertyId) <> '') then
    PropertyIdCount := 1;

  if PropertyIdCount = 0 then
  begin
    lblConnectionStatus.Text := 'Property ID needed';
    lblRefreshStatus.Text := 'Open Manage properties and enter numeric GA4 property IDs';
    lblStatusBar.Text := 'Open Properties and enter at least one numeric GA4 property ID.';
    Exit;
  end;

  OAuthClientId := dmSettings.ReadSetting('ga4_oauth_client_id', '');
  OAuthPort := dmSettings.ReadSetting('ga4_oauth_redirect_port', '53682');
  if Trim(OAuthClientId) = '' then
  begin
    lblConnectionStatus.Text := 'OAuth client ID needed';
    lblRefreshStatus.Text := 'Open Settings and enter the Google desktop OAuth client ID';
    lblStatusBar.Text := 'Open Settings and enter the Google desktop OAuth client ID. Redirect URI: ' +
      dmAuthentication.DesktopRedirectUri(OAuthPort);
    Exit;
  end;

  SelectedDateRange(StartDate, EndDate);
  UpdateChartTitle;
  RequestJson := dmGA4.BuildRunReportRequest(StartDate, EndDate, grkWeeklyUsers);
  if not dmAuthentication.Authenticated then
  begin
    AuthorizationUrl := dmAuthentication.BuildDesktopAuthorizationUrl(
      OAuthClientId, OAuthPort, 'website-analytics');
    lblConnectionStatus.Text := 'OAuth needed';
    lblRefreshStatus.Text := 'GA4 request and Google sign-in URL are prepared';
    if IsAllWebsitesSelected then
      lblStatusBar.Text := 'Prepared GA4 requests for ' +
        IntToStr(PropertyIdCount) + ' enabled websites. No analytics data stored.'
    else
      lblStatusBar.Text := 'Prepared request for property ' + WebsiteProperty.PropertyId +
      ' (' + IntToStr(Length(RequestJson)) + ' bytes, auth URL ' +
      IntToStr(Length(AuthorizationUrl)) + ' bytes). No analytics data stored.';
    Exit;
  end;

  btnUpdate.Enabled := False;
  btnUpdate.Text := 'Updating...';
  lblConnectionStatus.Text := 'Updating';
  lblRefreshStatus.Text := 'Retrieving live GA4 reports into memory';
  lblStatusBar.Text := 'Calling GA4 Data API...';
  Application.ProcessMessages;
  try
    if IsAllWebsitesSelected then
      FetchAllWebsiteReportsWithTokenRefresh(StartDate, EndDate)
    else
      FetchReportsWithTokenRefresh(WebsiteProperty, StartDate, EndDate);
    if (not IsAllWebsitesSelected) and
      (DashboardTabs.TabIndex = SECTION_SESSIONS_BY_DATE) then
      FetchSessionsByDateWithTokenRefresh(WebsiteProperty,
        DateToGA4String(dtSessionsByDate.Date));
    UpdateDashboardFromSnapshot(dmAnalyticsMemory.CurrentSnapshot);
    lblConnectionStatus.Text := 'Connected';
    lblRefreshStatus.Text := 'Last updated at ' + FormatDateTime('h:nn AM/PM', Now);
    lblStatusBar.Text := 'Dashboard updated from live GA4 data for ' +
      SelectedWebsiteDisplayName + ' at ' + FormatDateTime('h:nn:ss AM/PM', Now) + '.';
  except
    on E: Exception do
    begin
      lblConnectionStatus.Text := 'GA4 error';
      lblRefreshStatus.Text := E.Message;
      lblStatusBar.Text := E.Message;
    end;
  end;
  btnUpdate.Text := 'Update';
  btnUpdate.Enabled := True;
end;

procedure TfrmMainDashboard.btnManagePropertiesClick(Sender: TObject);
begin
  frmPropertyManager.ShowModal;
  RefreshPropertySelector;
end;

procedure TfrmMainDashboard.btnSettingsClick(Sender: TObject);
begin
  if frmSettings.ShowModal = mrOk then
  begin
    FSelectorChangeEnabled := False;
    try
      cmbWebsite.ItemIndex := StrToIntDef(
        dmSettings.ReadSetting('default_website_index', '0'), cmbWebsite.ItemIndex);
      if (cmbWebsite.ItemIndex < 0) or (cmbWebsite.ItemIndex >= cmbWebsite.Items.Count) then
        cmbWebsite.ItemIndex := 0;
      cmbDateRange.ItemIndex := StrToIntDef(
        dmSettings.ReadSetting('default_date_range_index', '2'), cmbDateRange.ItemIndex);
      if (cmbDateRange.ItemIndex < 0) or (cmbDateRange.ItemIndex >= cmbDateRange.Items.Count) then
        cmbDateRange.ItemIndex := 2;
      chkComparePrevious.IsChecked :=
        dmSettings.ReadSetting('compare_previous_period', '1') = '1';
      chkAutoUpdate.IsChecked :=
        dmSettings.ReadSetting('auto_update_enabled', '1') = '1';
      AutoUpdateTimer.Enabled := chkAutoUpdate.IsChecked;
      UpdateChartTitle;
    finally
      FSelectorChangeEnabled := True;
    end;

    if dmAuthentication.Authenticated then
    begin
      lblConnectionStatus.Text := 'Connected';
      lblRefreshStatus.Text := 'Google is connected. Click Update to retrieve live GA4 data.';
      lblStatusBar.Text := 'Google is connected. Click Update to retrieve live GA4 data.';
    end;
  end;
end;

procedure TfrmMainDashboard.btnDiagnosticsClick(Sender: TObject);
begin
  frmDiagnostics.ShowModal;
end;

end.
