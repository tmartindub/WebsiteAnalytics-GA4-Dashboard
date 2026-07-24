unit WebsiteAnalytics.GA4DataModule;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.JSON,
  System.NetConsts,
  System.Net.URLClient,
  System.Net.HttpClient,
  WebsiteAnalytics.Models;

type
  TGA4ReportKind = (
    grkOverview,
    grkWeeklyUsers,
    grkGeography,
    grkSessionsByDate,
    grkContent,
    grkAcquisition,
    grkDevices,
    grkLanguages,
    grkRealtimeActivity,
    grkRealtimeLocation,
    grkRealtime);

type
  TdmGA4 = class(TDataModule)
  private
    FLastStatus: string;
    FLastError: string;
    function BuildFailureMessage(const Response: IHTTPResponse;
      const ResponseText: string): string;
    function BuildMetricArray(const MetricNames: array of string): TJSONArray;
    function BuildDimensionArray(const DimensionNames: array of string): TJSONArray;
    function DimensionValue(const Row: TJSONObject; const Index: Integer): string;
    function MetricValue(const Row: TJSONObject; const Index: Integer): Double;
    function ParseGA4Date(const Value: string): TDate;
    function PostJson(const AccessToken, Url, RequestJson: string): string;
    function ResolveReportDate(const Value: string; const FallbackDate: TDate): TDate;
    procedure NormalizeTrendPoints(const StartDate, EndDate: string;
      const Snapshot: TGA4ReportSnapshot);
  public
    function BuildRunReportRequest(const StartDate, EndDate: string;
      const ReportKind: TGA4ReportKind): string;
    function ExecuteRunReport(const AccessToken, PropertyId, RequestJson: string): string;
    function ExecuteReport(const AccessToken, PropertyId, StartDate, EndDate: string;
      const ReportKind: TGA4ReportKind): string;
    procedure FetchStandardReports(const AccessToken, PropertyId, StartDate,
      EndDate: string; const Snapshot: TGA4ReportSnapshot);
    procedure FetchSessionsByDate(const AccessToken, PropertyId,
      ReportDate: string; const Snapshot: TGA4ReportSnapshot);
    procedure FetchKpiSummary(const AccessToken, PropertyId, StartDate,
      EndDate: string; out KpiSummary: TGA4KpiSummary);
    procedure ParseReportResponse(const ReportKind: TGA4ReportKind;
      const ResponseJson: string; const Snapshot: TGA4ReportSnapshot);
    property LastError: string read FLastError;
    property LastStatus: string read FLastStatus;
  end;

var
  dmGA4: TdmGA4;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

function TdmGA4.BuildMetricArray(const MetricNames: array of string): TJSONArray;
var
  MetricName: string;
begin
  Result := TJSONArray.Create;
  for MetricName in MetricNames do
    Result.AddElement(TJSONObject.Create.AddPair('name', MetricName));
end;

function TdmGA4.BuildFailureMessage(const Response: IHTTPResponse;
  const ResponseText: string): string;
var
  ErrorObject: TJSONObject;
  ErrorValue: TJSONValue;
  JsonRoot: TJSONObject;
  MessageValue: TJSONValue;
begin
  Result := Format('GA4 request failed: HTTP %d %s',
    [Response.StatusCode, Response.StatusText]);

  JsonRoot := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
  try
    if Assigned(JsonRoot) then
    begin
      ErrorValue := JsonRoot.GetValue('error');
      if ErrorValue is TJSONObject then
      begin
        ErrorObject := TJSONObject(ErrorValue);
        MessageValue := ErrorObject.GetValue('message');
        if Assigned(MessageValue) then
          Result := Result + ' - ' + MessageValue.Value;
      end;
    end
    else if Trim(ResponseText) <> '' then
      Result := Result + ' - ' + Trim(ResponseText);
  finally
    JsonRoot.Free;
  end;
end;

function TdmGA4.BuildDimensionArray(
  const DimensionNames: array of string): TJSONArray;
var
  DimensionName: string;
begin
  Result := TJSONArray.Create;
  for DimensionName in DimensionNames do
    Result.AddElement(TJSONObject.Create.AddPair('name', DimensionName));
end;

function TdmGA4.DimensionValue(const Row: TJSONObject;
  const Index: Integer): string;
var
  JsonValue: TJSONValue;
  Values: TJSONArray;
  ValueObject: TJSONObject;
begin
  Result := '';
  JsonValue := Row.GetValue('dimensionValues');
  if not (JsonValue is TJSONArray) then
    Exit;

  Values := TJSONArray(JsonValue);
  if Assigned(Values) and (Index >= 0) and (Index < Values.Count) and
    (Values.Items[Index] is TJSONObject) then
  begin
    ValueObject := TJSONObject(Values.Items[Index]);
    Result := ValueObject.GetValue<string>('value', '');
  end;
end;

function TdmGA4.MetricValue(const Row: TJSONObject; const Index: Integer): Double;
var
  FormatSettings: TFormatSettings;
  JsonValue: TJSONValue;
  ValueObject: TJSONObject;
  Values: TJSONArray;
  ValueText: string;
begin
  Result := 0;
  JsonValue := Row.GetValue('metricValues');
  if not (JsonValue is TJSONArray) then
    Exit;

  Values := TJSONArray(JsonValue);
  if not (Assigned(Values) and (Index >= 0) and (Index < Values.Count) and
    (Values.Items[Index] is TJSONObject)) then
    Exit;

  ValueObject := TJSONObject(Values.Items[Index]);
  ValueText := ValueObject.GetValue<string>('value', '0');
  FormatSettings := TFormatSettings.Invariant;
  TryStrToFloat(ValueText, Result, FormatSettings);
end;

function TdmGA4.ParseGA4Date(const Value: string): TDate;
var
  DayValue: Word;
  MonthValue: Word;
  YearValue: Word;
begin
  Result := 0;
  if Length(Value) <> 8 then
    Exit;

  YearValue := StrToIntDef(Copy(Value, 1, 4), 0);
  MonthValue := StrToIntDef(Copy(Value, 5, 2), 0);
  DayValue := StrToIntDef(Copy(Value, 7, 2), 0);
  if (YearValue > 0) and (MonthValue > 0) and (DayValue > 0) then
    Result := EncodeDate(YearValue, MonthValue, DayValue);
end;

function TdmGA4.ResolveReportDate(const Value: string;
  const FallbackDate: TDate): TDate;
var
  CleanValue: string;
  DaysAgoPosition: Integer;
  DaysBack: Integer;
  DayValue: Word;
  EncodedDate: TDateTime;
  MonthValue: Word;
  YearValue: Word;
begin
  CleanValue := Trim(Value);
  if SameText(CleanValue, 'today') then
    Exit(Date);

  DaysAgoPosition := Pos('daysago', LowerCase(CleanValue));
  if DaysAgoPosition > 0 then
  begin
    DaysBack := StrToIntDef(Copy(CleanValue, 1, DaysAgoPosition - 1), 0);
    Exit(Date - DaysBack);
  end;

  if Length(CleanValue) = 10 then
  begin
    YearValue := StrToIntDef(Copy(CleanValue, 1, 4), 0);
    MonthValue := StrToIntDef(Copy(CleanValue, 6, 2), 0);
    DayValue := StrToIntDef(Copy(CleanValue, 9, 2), 0);
    if TryEncodeDate(YearValue, MonthValue, DayValue, EncodedDate) then
    begin
      Result := EncodedDate;
      Exit;
    end;
  end;

  Result := FallbackDate;
end;

procedure TdmGA4.NormalizeTrendPoints(const StartDate, EndDate: string;
  const Snapshot: TGA4ReportSnapshot);
var
  CurrentDate: TDate;
  EndDateValue: TDate;
  ExistingPoint: TGA4TrendPoint;
  ExistingPointsByDate: TDictionary<Integer, TGA4TrendPoint>;
  NormalizedPoint: TGA4TrendPoint;
  StartDateValue: TDate;
  SwapDate: TDate;
  TrendIndex: Integer;
begin
  if not Assigned(Snapshot) then
    Exit;

  StartDateValue := ResolveReportDate(StartDate, Date);
  EndDateValue := ResolveReportDate(EndDate, Date);
  if StartDateValue > EndDateValue then
  begin
    SwapDate := StartDateValue;
    StartDateValue := EndDateValue;
    EndDateValue := SwapDate;
  end;

  ExistingPointsByDate := TDictionary<Integer, TGA4TrendPoint>.Create;
  try
    for TrendIndex := 0 to Snapshot.TrendPoints.Count - 1 do
    begin
      ExistingPoint := Snapshot.TrendPoints[TrendIndex];
      if ExistingPoint.DateValue > 0 then
        ExistingPointsByDate.AddOrSetValue(Trunc(ExistingPoint.DateValue),
          ExistingPoint);
    end;

    Snapshot.TrendPoints.Clear;
    CurrentDate := StartDateValue;
    while CurrentDate <= EndDateValue do
    begin
      if ExistingPointsByDate.TryGetValue(Trunc(CurrentDate),
        NormalizedPoint) then
      begin
        NormalizedPoint.DateValue := CurrentDate;
        NormalizedPoint.LabelText := FormatDateTime('m/d', CurrentDate);
      end
      else
      begin
        NormalizedPoint := Default(TGA4TrendPoint);
        NormalizedPoint.DateValue := CurrentDate;
        NormalizedPoint.LabelText := FormatDateTime('m/d', CurrentDate);
      end;

      Snapshot.TrendPoints.Add(NormalizedPoint);
      CurrentDate := CurrentDate + 1;
    end;
  finally
    ExistingPointsByDate.Free;
  end;

  Snapshot.TrendPoints.Sort(TComparer<TGA4TrendPoint>.Construct(
    function(const Left, Right: TGA4TrendPoint): Integer
    begin
      if Left.DateValue < Right.DateValue then
        Result := -1
      else if Left.DateValue > Right.DateValue then
        Result := 1
      else
        Result := 0;
    end));
end;

function TdmGA4.BuildRunReportRequest(const StartDate, EndDate: string;
  const ReportKind: TGA4ReportKind): string;
var
  RequestJson: TJSONObject;
  DateRanges: TJSONArray;
  DateRange: TJSONObject;
  OrderBys: TJSONArray;
  OrderBy: TJSONObject;
  DimensionOrderBy: TJSONObject;
begin
  RequestJson := TJSONObject.Create;
  try
    if not (ReportKind in [grkRealtime, grkRealtimeActivity,
      grkRealtimeLocation]) then
    begin
      DateRange := TJSONObject.Create;
      DateRange.AddPair('startDate', StartDate);
      DateRange.AddPair('endDate', EndDate);

      DateRanges := TJSONArray.Create;
      DateRanges.AddElement(DateRange);
      RequestJson.AddPair('dateRanges', DateRanges);
    end;

    case ReportKind of
      grkOverview:
        RequestJson.AddPair('metrics',
          BuildMetricArray(['activeUsers', 'sessions', 'screenPageViews',
            'engagementRate', 'eventsPerSession', 'scrolledUsers']));
      grkWeeklyUsers:
        begin
          RequestJson.AddPair('dimensions', BuildDimensionArray(['date']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions', 'screenPageViews',
              'engagementRate', 'eventCount']));
          DimensionOrderBy := TJSONObject.Create;
          DimensionOrderBy.AddPair('dimensionName', 'date');
          OrderBy := TJSONObject.Create;
          OrderBy.AddPair('dimension', DimensionOrderBy);
          OrderBys := TJSONArray.Create;
          OrderBys.AddElement(OrderBy);
          RequestJson.AddPair('orderBys', OrderBys);
        end;
      grkGeography:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['country', 'region', 'city']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions', 'engagementRate']));
          OrderBy := TJSONObject.Create;
          OrderBy.AddPair('metric',
            TJSONObject.Create.AddPair('metricName', 'activeUsers'));
          OrderBys := TJSONArray.Create;
          OrderBys.AddElement(OrderBy);
          RequestJson.AddPair('orderBys', OrderBys);
          RequestJson.AddPair('limit', TJSONNumber.Create(10000));
        end;
      grkSessionsByDate:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['country', 'region', 'city']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions', 'screenPageViews',
              'engagementRate']));
          OrderBy := TJSONObject.Create;
          OrderBy.AddPair('metric',
            TJSONObject.Create.AddPair('metricName', 'sessions'));
          OrderBys := TJSONArray.Create;
          OrderBys.AddElement(OrderBy);
          RequestJson.AddPair('orderBys', OrderBys);
          RequestJson.AddPair('limit', TJSONNumber.Create(10000));
        end;
      grkContent:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['pagePath', 'pageTitle', 'eventName']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['screenPageViews', 'activeUsers', 'eventCount',
              'userEngagementDuration']));
          RequestJson.AddPair('limit', TJSONNumber.Create(1000));
        end;
      grkAcquisition:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['sessionSource', 'sessionMedium',
              'sessionCampaignName']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions', 'engagementRate']));
          RequestJson.AddPair('limit', TJSONNumber.Create(25));
        end;
      grkDevices:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['deviceCategory', 'browser',
              'operatingSystem']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions']));
          RequestJson.AddPair('limit', TJSONNumber.Create(25));
        end;
      grkLanguages:
        begin
          RequestJson.AddPair('dimensions', BuildDimensionArray(['language']));
          RequestJson.AddPair('metrics',
            BuildMetricArray(['activeUsers', 'sessions', 'engagementRate']));
          RequestJson.AddPair('limit', TJSONNumber.Create(1000));
        end;
      grkRealtimeActivity:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['country', 'city', 'minutesAgo']));
          RequestJson.AddPair('metrics', BuildMetricArray(['activeUsers']));
          DimensionOrderBy := TJSONObject.Create;
          DimensionOrderBy.AddPair('dimensionName', 'minutesAgo');
          OrderBy := TJSONObject.Create;
          OrderBy.AddPair('dimension', DimensionOrderBy);
          OrderBys := TJSONArray.Create;
          OrderBys.AddElement(OrderBy);
          RequestJson.AddPair('orderBys', OrderBys);
          RequestJson.AddPair('limit', TJSONNumber.Create(1));
        end;
      grkRealtimeLocation:
        begin
          RequestJson.AddPair('dimensions',
            BuildDimensionArray(['country', 'city']));
          RequestJson.AddPair('metrics', BuildMetricArray(['activeUsers']));
          OrderBy := TJSONObject.Create;
          OrderBy.AddPair('metric',
            TJSONObject.Create.AddPair('metricName', 'activeUsers'));
          OrderBys := TJSONArray.Create;
          OrderBys.AddElement(OrderBy);
          RequestJson.AddPair('orderBys', OrderBys);
          RequestJson.AddPair('limit', TJSONNumber.Create(1));
        end;
      grkRealtime:
        RequestJson.AddPair('metrics',
          BuildMetricArray(['activeUsers', 'screenPageViews']));
    end;

    Result := RequestJson.ToJSON;
    FLastStatus := 'GA4 report request prepared';
  finally
    RequestJson.Free;
  end;
end;

procedure TdmGA4.ParseReportResponse(const ReportKind: TGA4ReportKind;
  const ResponseJson: string; const Snapshot: TGA4ReportSnapshot);
var
  AcquisitionRow: TGA4AcquisitionRow;
  ContentRow: TGA4ContentRow;
  DeviceRow: TGA4DeviceRow;
  GeographyRow: TGA4GeographyRow;
  JsonRoot: TJSONObject;
  LanguageRow: TGA4LanguageRow;
  RowsValue: TJSONValue;
  Row: TJSONObject;
  Rows: TJSONArray;
  RowIndex: Integer;
  SessionsByDateRow: TGA4SessionsByDateRow;
  TrendPoint: TGA4TrendPoint;
begin
  if not Assigned(Snapshot) then
    Exit;

  JsonRoot := TJSONObject.ParseJSONValue(ResponseJson) as TJSONObject;
  try
    if not Assigned(JsonRoot) then
    begin
      FLastError := 'GA4 response was not valid JSON.';
      Exit;
    end;

    RowsValue := JsonRoot.GetValue('rows');
    if not (RowsValue is TJSONArray) then
    begin
      FLastError := '';
      FLastStatus := 'GA4 response contained no rows';
      Exit;
    end;

    Rows := TJSONArray(RowsValue);

    for RowIndex := 0 to Rows.Count - 1 do
    begin
      if not (Rows.Items[RowIndex] is TJSONObject) then
        Continue;
      Row := TJSONObject(Rows.Items[RowIndex]);

      case ReportKind of
        grkOverview:
          begin
            Snapshot.KpiSummary.ActiveUsers := MetricValue(Row, 0);
            Snapshot.KpiSummary.Sessions := MetricValue(Row, 1);
            Snapshot.KpiSummary.ScreenPageViews := MetricValue(Row, 2);
            Snapshot.KpiSummary.EngagementRate := MetricValue(Row, 3);
            Snapshot.KpiSummary.EventsPerSession := MetricValue(Row, 4);
            Snapshot.KpiSummary.ScrolledUsers := MetricValue(Row, 5);
          end;
        grkWeeklyUsers:
          begin
            TrendPoint.DateValue := ParseGA4Date(DimensionValue(Row, 0));
            if TrendPoint.DateValue > 0 then
              TrendPoint.LabelText := FormatDateTime('m/d', TrendPoint.DateValue)
            else
              TrendPoint.LabelText := DimensionValue(Row, 0);
            TrendPoint.ActiveUsers := MetricValue(Row, 0);
            TrendPoint.Sessions := MetricValue(Row, 1);
            TrendPoint.ScreenPageViews := MetricValue(Row, 2);
            TrendPoint.EngagementRate := MetricValue(Row, 3);
            TrendPoint.EventCount := MetricValue(Row, 4);
            TrendPoint.Value := TrendPoint.ActiveUsers;
            Snapshot.TrendPoints.Add(TrendPoint);
          end;
        grkGeography:
          begin
            GeographyRow.Country := DimensionValue(Row, 0);
            GeographyRow.Region := DimensionValue(Row, 1);
            GeographyRow.City := DimensionValue(Row, 2);
            GeographyRow.ActiveUsers := MetricValue(Row, 0);
            GeographyRow.Sessions := MetricValue(Row, 1);
            GeographyRow.EngagementRate := MetricValue(Row, 2);
            Snapshot.GeographyRows.Add(GeographyRow);
          end;
        grkSessionsByDate:
          begin
            SessionsByDateRow.Country := DimensionValue(Row, 0);
            SessionsByDateRow.Region := DimensionValue(Row, 1);
            SessionsByDateRow.City := DimensionValue(Row, 2);
            SessionsByDateRow.ActiveUsers := MetricValue(Row, 0);
            SessionsByDateRow.Sessions := MetricValue(Row, 1);
            SessionsByDateRow.ScreenPageViews := MetricValue(Row, 2);
            SessionsByDateRow.EngagementRate := MetricValue(Row, 3);
            Snapshot.SessionsByDateRows.Add(SessionsByDateRow);
          end;
        grkContent:
          begin
            ContentRow.PagePath := DimensionValue(Row, 0);
            ContentRow.PageTitle := DimensionValue(Row, 1);
            ContentRow.EventName := DimensionValue(Row, 2);
            ContentRow.ScreenPageViews := MetricValue(Row, 0);
            ContentRow.ActiveUsers := MetricValue(Row, 1);
            ContentRow.EventCount := MetricValue(Row, 2);
            ContentRow.EngagementSeconds := MetricValue(Row, 3);
            Snapshot.ContentRows.Add(ContentRow);
          end;
        grkAcquisition:
          begin
            AcquisitionRow.Source := DimensionValue(Row, 0);
            AcquisitionRow.Medium := DimensionValue(Row, 1);
            AcquisitionRow.Campaign := DimensionValue(Row, 2);
            AcquisitionRow.ActiveUsers := MetricValue(Row, 0);
            AcquisitionRow.Sessions := MetricValue(Row, 1);
            AcquisitionRow.EngagementRate := MetricValue(Row, 2);
            Snapshot.AcquisitionRows.Add(AcquisitionRow);
          end;
        grkDevices:
          begin
            DeviceRow.DeviceCategory := DimensionValue(Row, 0);
            DeviceRow.Browser := DimensionValue(Row, 1);
            DeviceRow.OperatingSystem := DimensionValue(Row, 2);
            DeviceRow.ActiveUsers := MetricValue(Row, 0);
            DeviceRow.Sessions := MetricValue(Row, 1);
            Snapshot.DeviceRows.Add(DeviceRow);
          end;
        grkLanguages:
          begin
            LanguageRow.Language := DimensionValue(Row, 0);
            LanguageRow.ActiveUsers := MetricValue(Row, 0);
            LanguageRow.Sessions := MetricValue(Row, 1);
            LanguageRow.EngagementRate := MetricValue(Row, 2);
            Snapshot.LanguageRows.Add(LanguageRow);
          end;
        grkRealtimeActivity:
          begin
            if not Snapshot.RealtimeSummary.HasLastActivity then
            begin
              Snapshot.RealtimeSummary.LastCountry := DimensionValue(Row, 0);
              Snapshot.RealtimeSummary.LastCity := DimensionValue(Row, 1);
              Snapshot.RealtimeSummary.LastMinutesAgo :=
                StrToIntDef(DimensionValue(Row, 2), 0);
              Snapshot.RealtimeSummary.HasLastActivity := True;
            end;
          end;
        grkRealtimeLocation:
          begin
            if not Snapshot.RealtimeSummary.HasLastActivity then
            begin
              Snapshot.RealtimeSummary.LastCountry := DimensionValue(Row, 0);
              Snapshot.RealtimeSummary.LastCity := DimensionValue(Row, 1);
              Snapshot.RealtimeSummary.LastMinutesAgo := 0;
              Snapshot.RealtimeSummary.HasLastActivity := True;
            end;
          end;
        grkRealtime:
          begin
            Snapshot.RealtimeSummary.ActiveUsers := MetricValue(Row, 0);
            Snapshot.RealtimeSummary.ScreenPageViews := MetricValue(Row, 1);
          end;
      end;
    end;

    FLastError := '';
    FLastStatus := 'GA4 response parsed in memory';
  finally
    JsonRoot.Free;
  end;
end;

function TdmGA4.ExecuteRunReport(const AccessToken, PropertyId,
  RequestJson: string): string;
var
  Url: string;
begin
  if Trim(PropertyId) = '' then
    raise EArgumentException.Create('A numeric GA4 property ID is required.');
  Url := Format('https://analyticsdata.googleapis.com/v1beta/properties/%s:runReport',
    [Trim(PropertyId)]);
  Result := PostJson(AccessToken, Url, RequestJson);
end;

function TdmGA4.ExecuteReport(const AccessToken, PropertyId, StartDate,
  EndDate: string; const ReportKind: TGA4ReportKind): string;
var
  RequestJson: string;
  Url: string;
begin
  if Trim(PropertyId) = '' then
    raise EArgumentException.Create('A numeric GA4 property ID is required.');

  RequestJson := BuildRunReportRequest(StartDate, EndDate, ReportKind);
  if ReportKind in [grkRealtime, grkRealtimeActivity, grkRealtimeLocation] then
    Url := Format('https://analyticsdata.googleapis.com/v1beta/properties/%s:runRealtimeReport',
      [Trim(PropertyId)])
  else
    Url := Format('https://analyticsdata.googleapis.com/v1beta/properties/%s:runReport',
      [Trim(PropertyId)]);

  Result := PostJson(AccessToken, Url, RequestJson);
end;

function TdmGA4.PostJson(const AccessToken, Url, RequestJson: string): string;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  RequestBody: TStringStream;
begin
  if Trim(AccessToken) = '' then
    raise EArgumentException.Create('A GA4 OAuth access token is required.');

  HttpClient := THTTPClient.Create;
  RequestBody := TStringStream.Create(RequestJson, TEncoding.UTF8);
  try
    HttpClient.CustomHeaders['Authorization'] := 'Bearer ' + Trim(AccessToken);
    HttpClient.ContentType := 'application/json';
    HttpClient.ConnectionTimeout := 15000;
    HttpClient.ResponseTimeout := 30000;
    Response := HttpClient.Post(Url, RequestBody);
    Result := Response.ContentAsString(TEncoding.UTF8);
    FLastStatus := Format('GA4 response received: HTTP %d',
      [Response.StatusCode]);
    if (Response.StatusCode < 200) or (Response.StatusCode > 299) then
    begin
      FLastError := BuildFailureMessage(Response, Result);
      raise Exception.Create(FLastError);
    end;
    FLastError := '';
  finally
    RequestBody.Free;
    HttpClient.Free;
  end;
end;

procedure TdmGA4.FetchStandardReports(const AccessToken, PropertyId, StartDate,
  EndDate: string; const Snapshot: TGA4ReportSnapshot);
var
  ReportKind: TGA4ReportKind;
  ResponseJson: string;
begin
  if not Assigned(Snapshot) then
    Exit;

  Snapshot.Clear;
  for ReportKind in [grkOverview, grkWeeklyUsers, grkGeography, grkContent,
    grkRealtime, grkRealtimeActivity] do
  begin
    ResponseJson := ExecuteReport(AccessToken, PropertyId, StartDate, EndDate,
      ReportKind);
    ParseReportResponse(ReportKind, ResponseJson, Snapshot);
  end;
  if (Snapshot.RealtimeSummary.ActiveUsers > 0) and
    (not Snapshot.RealtimeSummary.HasLastActivity) then
  begin
    ResponseJson := ExecuteReport(AccessToken, PropertyId, StartDate, EndDate,
      grkRealtimeLocation);
    ParseReportResponse(grkRealtimeLocation, ResponseJson, Snapshot);
  end;
  NormalizeTrendPoints(StartDate, EndDate, Snapshot);
end;

procedure TdmGA4.FetchSessionsByDate(const AccessToken, PropertyId,
  ReportDate: string; const Snapshot: TGA4ReportSnapshot);
var
  ResponseJson: string;
begin
  if not Assigned(Snapshot) then
    Exit;

  Snapshot.SessionsByDateRows.Clear;
  ResponseJson := ExecuteReport(AccessToken, PropertyId, ReportDate,
    ReportDate, grkSessionsByDate);
  ParseReportResponse(grkSessionsByDate, ResponseJson, Snapshot);
end;

procedure TdmGA4.FetchKpiSummary(const AccessToken, PropertyId, StartDate,
  EndDate: string; out KpiSummary: TGA4KpiSummary);
var
  ResponseJson: string;
  Snapshot: TGA4ReportSnapshot;
begin
  KpiSummary := Default(TGA4KpiSummary);
  Snapshot := TGA4ReportSnapshot.Create;
  try
    ResponseJson := ExecuteReport(AccessToken, PropertyId, StartDate, EndDate,
      grkOverview);
    ParseReportResponse(grkOverview, ResponseJson, Snapshot);
    KpiSummary := Snapshot.KpiSummary;
  finally
    Snapshot.Free;
  end;
end;

end.
