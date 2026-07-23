unit WebsiteAnalytics.SettingsDataModule;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.UITypes,
  FireDAC.Comp.Client,
  FireDAC.Stan.Def,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Async,
  FireDAC.Stan.Error,
  FireDAC.Stan.Param,
  FireDAC.FMXUI.Wait,
  FireDAC.Phys,
  FireDAC.Phys.SQLite,
  FireDAC.DApt,
  WebsiteAnalytics.AnalyticsMemoryDataModule;

type
  TdmSettings = class(TDataModule)
    FDConnection: TFDConnection;
  private
    FDatabasePath: string;
    function ResolveDatabasePath: string;
    procedure CreateSchema;
    procedure EnsureSettingDefault(const Name, Value, SettingGroup,
      Description: string);
    procedure SeedDefaultsIfNeeded;
    function QueryScalarString(const Sql, DefaultValue: string): string;
    procedure ExecSQL(const Sql: string);
  public
    procedure Initialize;
    procedure LoadPropertiesIntoMemory(const AnalyticsMemory: TdmAnalyticsMemory);
    procedure SavePropertiesFromMemory(const AnalyticsMemory: TdmAnalyticsMemory);
    function ReadSetting(const Name, DefaultValue: string): string;
    procedure WriteSetting(const Name, Value, SettingGroup, Description: string);
    property DatabasePath: string read FDatabasePath;
  end;

var
  dmSettings: TdmSettings;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  WebsiteAnalytics.Models;

procedure TdmSettings.Initialize;
begin
  if not Assigned(FDConnection) then
    FDConnection := TFDConnection.Create(Self);

  FDatabasePath := ResolveDatabasePath;
  ForceDirectories(ExtractFilePath(FDatabasePath));

  FDConnection.Params.Clear;
  FDConnection.Params.DriverID := 'SQLite';
  FDConnection.Params.Database := FDatabasePath;
  FDConnection.LoginPrompt := False;
  FDConnection.Connected := True;

  CreateSchema;
  SeedDefaultsIfNeeded;
end;

function TdmSettings.ResolveDatabasePath: string;
var
  ExeDirectory: string;
  CandidatePath: string;
begin
  ExeDirectory := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  CandidatePath := TPath.Combine(ExeDirectory, 'databases\WebsiteAnalytics.sqlite3');
  if TDirectory.Exists(ExtractFilePath(CandidatePath)) then
    Exit(CandidatePath);

  CandidatePath := TPath.GetFullPath(TPath.Combine(ExeDirectory,
    '..\..\..\databases\WebsiteAnalytics.sqlite3'));
  if TDirectory.Exists(ExtractFilePath(CandidatePath)) then
    Exit(CandidatePath);

  Result := TPath.Combine(ExeDirectory, 'databases\WebsiteAnalytics.sqlite3');
end;

procedure TdmSettings.ExecSQL(const Sql: string);
begin
  FDConnection.ExecSQL(Sql);
end;

procedure TdmSettings.EnsureSettingDefault(const Name, Value, SettingGroup,
  Description: string);
begin
  FDConnection.ExecSQL('INSERT OR IGNORE INTO app_settings ' +
    '(setting_name, setting_value, setting_group, description, updated_utc) ' +
    'VALUES (:setting_name, :setting_value, :setting_group, :description, CURRENT_TIMESTAMP)',
    [Name, Value, SettingGroup, Description]);
end;

procedure TdmSettings.CreateSchema;
begin
  ExecSQL('PRAGMA foreign_keys = ON');
  ExecSQL('CREATE TABLE IF NOT EXISTS app_settings (' +
    'setting_name TEXT PRIMARY KEY, ' +
    'setting_value TEXT NOT NULL, ' +
    'setting_group TEXT NOT NULL DEFAULT ''general'', ' +
    'description TEXT NOT NULL DEFAULT '''', ' +
    'updated_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)');
  ExecSQL('CREATE TABLE IF NOT EXISTS website_properties (' +
    'property_key INTEGER PRIMARY KEY AUTOINCREMENT, ' +
    'display_name TEXT NOT NULL, ' +
    'website_address TEXT NOT NULL, ' +
    'ga4_property_id TEXT NOT NULL DEFAULT '''', ' +
    'display_color INTEGER NOT NULL, ' +
    'enabled INTEGER NOT NULL DEFAULT 1, ' +
    'display_order INTEGER NOT NULL DEFAULT 0, ' +
    'updated_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP)');
  ExecSQL('CREATE INDEX IF NOT EXISTS idx_website_properties_order ' +
    'ON website_properties(display_order, display_name)');
end;

procedure TdmSettings.SeedDefaultsIfNeeded;
begin
  EnsureSettingDefault('schema_version', '1', 'system',
    'Portable settings database schema version');
  EnsureSettingDefault('default_website_index', '0', 'dashboard',
    'Default selected website, where 0 means all websites');
  EnsureSettingDefault('default_date_range_index', '2', 'dashboard',
    'Default date range selection');
  EnsureSettingDefault('refresh_at_startup', '1', 'dashboard',
    'Retrieve GA4 data when the program opens after authentication is configured');
  EnsureSettingDefault('compare_previous_period', '1', 'dashboard',
    'Compare the selected period with the previous period');
  EnsureSettingDefault('auto_update_enabled', '1', 'dashboard',
    'Refresh the dashboard automatically every 60 seconds while authenticated');
  EnsureSettingDefault('theme_name', 'VCL2FMX Blue', 'appearance',
    'Current dashboard color theme');
  EnsureSettingDefault('ga4_auth_method', 'desktop_oauth', 'ga4',
    'Preferred GA4 authentication approach');
  EnsureSettingDefault('ga4_oauth_client_id', '', 'ga4',
    'Google Cloud desktop OAuth client ID');
  EnsureSettingDefault('ga4_oauth_client_secret', '', 'ga4',
    'Google Cloud desktop OAuth client secret for token exchange when required');
  EnsureSettingDefault('ga4_oauth_redirect_port', '53682', 'ga4',
    'Local loopback port used for Google OAuth desktop sign-in');
  EnsureSettingDefault('ga4_oauth_scope',
    'https://www.googleapis.com/auth/analytics.readonly', 'ga4',
    'Read-only Google Analytics scope for GA4 Data API reporting');
  EnsureSettingDefault('ga4_oauth_refresh_token_dpapi', '', 'ga4',
    'Encrypted Google OAuth refresh token for silent startup reconnect');

  if QueryScalarString('SELECT COUNT(*) FROM website_properties', '0') <> '0' then
    Exit;

  FDConnection.ExecSQL('INSERT INTO website_properties ' +
    '(display_name, website_address, ga4_property_id, display_color, enabled, display_order) ' +
    'VALUES (:display_name, :website_address, :ga4_property_id, :display_color, :enabled, :display_order)',
    ['Example Site', 'https://example.com', '', Integer($FF1974DF), 1, 0]);
end;

function TdmSettings.QueryScalarString(const Sql, DefaultValue: string): string;
var
  Query: TFDQuery;
begin
  Result := DefaultValue;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.Open(Sql);
    if not Query.Eof then
      Result := Query.Fields[0].AsString;
  finally
    Query.Free;
  end;
end;

function TdmSettings.ReadSetting(const Name, DefaultValue: string): string;
var
  Query: TFDQuery;
begin
  Result := DefaultValue;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.SQL.Text := 'SELECT setting_value FROM app_settings WHERE setting_name = :setting_name';
    Query.ParamByName('setting_name').AsString := Name;
    Query.Open;
    if not Query.Eof then
      Result := Query.FieldByName('setting_value').AsString;
  finally
    Query.Free;
  end;
end;

procedure TdmSettings.WriteSetting(const Name, Value, SettingGroup,
  Description: string);
begin
  FDConnection.ExecSQL('INSERT OR REPLACE INTO app_settings ' +
    '(setting_name, setting_value, setting_group, description, updated_utc) ' +
    'VALUES (:setting_name, :setting_value, :setting_group, :description, CURRENT_TIMESTAMP)',
    [Name, Value, SettingGroup, Description]);
end;

procedure TdmSettings.LoadPropertiesIntoMemory(
  const AnalyticsMemory: TdmAnalyticsMemory);
var
  Query: TFDQuery;
begin
  AnalyticsMemory.ClearProperties;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FDConnection;
    Query.SQL.Text := 'SELECT display_name, website_address, ga4_property_id, ' +
      'display_color, enabled FROM website_properties ' +
      'ORDER BY display_order, display_name';
    Query.Open;
    while not Query.Eof do
    begin
      AnalyticsMemory.AddProperty(
        Query.FieldByName('display_name').AsString,
        Query.FieldByName('website_address').AsString,
        Query.FieldByName('ga4_property_id').AsString,
        TAlphaColor(Query.FieldByName('display_color').AsInteger),
        Query.FieldByName('enabled').AsInteger <> 0);
      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

procedure TdmSettings.SavePropertiesFromMemory(
  const AnalyticsMemory: TdmAnalyticsMemory);
var
  PropertyIndex: Integer;
  WebsiteProperty: TWebsitePropertyDefinition;
begin
  FDConnection.StartTransaction;
  try
    FDConnection.ExecSQL('DELETE FROM website_properties');
    for PropertyIndex := 0 to AnalyticsMemory.PropertyCount - 1 do
    begin
      WebsiteProperty := AnalyticsMemory[PropertyIndex];
      FDConnection.ExecSQL('INSERT INTO website_properties ' +
        '(display_name, website_address, ga4_property_id, display_color, enabled, display_order) ' +
        'VALUES (:display_name, :website_address, :ga4_property_id, :display_color, :enabled, :display_order)',
        [WebsiteProperty.DisplayName,
         WebsiteProperty.WebsiteAddress,
         WebsiteProperty.PropertyId,
         Integer(WebsiteProperty.DisplayColor),
         Ord(WebsiteProperty.Enabled),
         PropertyIndex]);
    end;
    FDConnection.Commit;
  except
    FDConnection.Rollback;
    raise;
  end;
end;

end.


