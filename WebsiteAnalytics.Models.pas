unit WebsiteAnalytics.Models;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  System.UITypes;

type
  TWebsitePropertyDefinition = class
  private
    FDisplayName: string;
    FPropertyId: string;
    FWebsiteAddress: string;
    FDisplayColor: TAlphaColor;
    FEnabled: Boolean;
    FDisplayOrder: Integer;
  public
    constructor Create(const ADisplayName, AWebsiteAddress, APropertyId: string;
      const ADisplayColor: TAlphaColor; const AEnabled: Boolean;
      const ADisplayOrder: Integer);
    property DisplayName: string read FDisplayName write FDisplayName;
    property PropertyId: string read FPropertyId write FPropertyId;
    property WebsiteAddress: string read FWebsiteAddress write FWebsiteAddress;
    property DisplayColor: TAlphaColor read FDisplayColor write FDisplayColor;
    property Enabled: Boolean read FEnabled write FEnabled;
    property DisplayOrder: Integer read FDisplayOrder write FDisplayOrder;
  end;

  TGA4KpiSummary = record
    ActiveUsers: Double;
    Sessions: Double;
    ScreenPageViews: Double;
    EngagementRate: Double;
    EventsPerSession: Double;
    ScrolledUsers: Double;
  end;

  TGA4TrendPoint = record
    DateValue: TDate;
    LabelText: string;
    ActiveUsers: Double;
    Sessions: Double;
    ScreenPageViews: Double;
    EngagementRate: Double;
    EventCount: Double;
    Value: Double;
  end;

  TGA4GeographyRow = record
    Country: string;
    Region: string;
    City: string;
    ActiveUsers: Double;
    Sessions: Double;
    EngagementRate: Double;
  end;

  TGA4SessionsByDateRow = record
    Country: string;
    Region: string;
    City: string;
    ActiveUsers: Double;
    Sessions: Double;
    ScreenPageViews: Double;
    EngagementRate: Double;
  end;

  TGA4ContentRow = record
    PagePath: string;
    PageTitle: string;
    EventName: string;
    ScreenPageViews: Double;
    ActiveUsers: Double;
    EventCount: Double;
    EngagementSeconds: Double;
  end;

  TGA4AcquisitionRow = record
    Source: string;
    Medium: string;
    Campaign: string;
    ActiveUsers: Double;
    Sessions: Double;
    EngagementRate: Double;
  end;

  TGA4DeviceRow = record
    DeviceCategory: string;
    Browser: string;
    OperatingSystem: string;
    ActiveUsers: Double;
    Sessions: Double;
  end;

  TGA4LanguageRow = record
    Language: string;
    ActiveUsers: Double;
    Sessions: Double;
    EngagementRate: Double;
  end;

  TGA4RealtimeSummary = record
    ActiveUsers: Double;
    ScreenPageViews: Double;
    LastCountry: string;
    LastCity: string;
    LastMinutesAgo: Integer;
    HasLastActivity: Boolean;
  end;

  TGA4ReportSnapshot = class
  private
    FAcquisitionRows: TList<TGA4AcquisitionRow>;
    FContentRows: TList<TGA4ContentRow>;
    FDeviceRows: TList<TGA4DeviceRow>;
    FGeographyRows: TList<TGA4GeographyRow>;
    FLanguageRows: TList<TGA4LanguageRow>;
    FSessionsByDateRows: TList<TGA4SessionsByDateRow>;
    FTrendPoints: TList<TGA4TrendPoint>;
  public
    KpiSummary: TGA4KpiSummary;
    PreviousKpiSummary: TGA4KpiSummary;
    HasPreviousKpiSummary: Boolean;
    RealtimeSummary: TGA4RealtimeSummary;
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    property AcquisitionRows: TList<TGA4AcquisitionRow> read FAcquisitionRows;
    property ContentRows: TList<TGA4ContentRow> read FContentRows;
    property DeviceRows: TList<TGA4DeviceRow> read FDeviceRows;
    property GeographyRows: TList<TGA4GeographyRow> read FGeographyRows;
    property LanguageRows: TList<TGA4LanguageRow> read FLanguageRows;
    property SessionsByDateRows: TList<TGA4SessionsByDateRow> read FSessionsByDateRows;
    property TrendPoints: TList<TGA4TrendPoint> read FTrendPoints;
  end;

implementation

constructor TWebsitePropertyDefinition.Create(const ADisplayName,
  AWebsiteAddress, APropertyId: string; const ADisplayColor: TAlphaColor;
  const AEnabled: Boolean; const ADisplayOrder: Integer);
begin
  inherited Create;
  FDisplayName := ADisplayName;
  FWebsiteAddress := AWebsiteAddress;
  FPropertyId := APropertyId;
  FDisplayColor := ADisplayColor;
  FEnabled := AEnabled;
  FDisplayOrder := ADisplayOrder;
end;

constructor TGA4ReportSnapshot.Create;
begin
  inherited Create;
  FAcquisitionRows := TList<TGA4AcquisitionRow>.Create;
  FContentRows := TList<TGA4ContentRow>.Create;
  FDeviceRows := TList<TGA4DeviceRow>.Create;
  FGeographyRows := TList<TGA4GeographyRow>.Create;
  FLanguageRows := TList<TGA4LanguageRow>.Create;
  FSessionsByDateRows := TList<TGA4SessionsByDateRow>.Create;
  FTrendPoints := TList<TGA4TrendPoint>.Create;
  Clear;
end;

destructor TGA4ReportSnapshot.Destroy;
begin
  FTrendPoints.Free;
  FSessionsByDateRows.Free;
  FLanguageRows.Free;
  FGeographyRows.Free;
  FDeviceRows.Free;
  FContentRows.Free;
  FAcquisitionRows.Free;
  inherited;
end;

procedure TGA4ReportSnapshot.Clear;
begin
  KpiSummary := Default(TGA4KpiSummary);
  PreviousKpiSummary := Default(TGA4KpiSummary);
  HasPreviousKpiSummary := False;
  RealtimeSummary := Default(TGA4RealtimeSummary);
  FAcquisitionRows.Clear;
  FContentRows.Clear;
  FDeviceRows.Clear;
  FGeographyRows.Clear;
  FLanguageRows.Clear;
  FSessionsByDateRows.Clear;
  FTrendPoints.Clear;
end;

end.
