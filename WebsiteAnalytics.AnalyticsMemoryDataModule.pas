unit WebsiteAnalytics.AnalyticsMemoryDataModule;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.UITypes,
  WebsiteAnalytics.Models;

type
  TdmAnalyticsMemory = class(TDataModule)
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FCurrentSnapshot: TGA4ReportSnapshot;
    FProperties: TObjectList<TWebsitePropertyDefinition>;
    procedure AddInitialProperties;
    function GetPropertyCount: Integer;
    function GetPropertyDefinition(const Index: Integer): TWebsitePropertyDefinition;
  public
    function AddProperty(const DisplayName, WebsiteAddress, PropertyId: string;
      const DisplayColor: TAlphaColor; const Enabled: Boolean): Integer;
    procedure ClearProperties;
    procedure DeleteProperty(const Index: Integer);
    property PropertyCount: Integer read GetPropertyCount;
    property Properties[const Index: Integer]: TWebsitePropertyDefinition
      read GetPropertyDefinition; default;
    property CurrentSnapshot: TGA4ReportSnapshot read FCurrentSnapshot;
  end;

var
  dmAnalyticsMemory: TdmAnalyticsMemory;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

procedure TdmAnalyticsMemory.DataModuleCreate(Sender: TObject);
begin
  FCurrentSnapshot := TGA4ReportSnapshot.Create;
  FProperties := TObjectList<TWebsitePropertyDefinition>.Create(True);
  AddInitialProperties;
end;

procedure TdmAnalyticsMemory.DataModuleDestroy(Sender: TObject);
begin
  FProperties.Free;
  FCurrentSnapshot.Free;
end;

procedure TdmAnalyticsMemory.AddInitialProperties;
begin
  AddProperty('Carillon Bells', 'https://carillon-bells.github.io', '',
    $FFB7791F, True);
  AddProperty('VCL2FMX', 'https://vcl2fmx.github.io', '',
    $FF1974DF, True);
  AddProperty('GPS Sync', 'https://gpssync.github.io', '',
    $FF168C8C, True);
end;

procedure TdmAnalyticsMemory.ClearProperties;
begin
  FProperties.Clear;
end;

function TdmAnalyticsMemory.AddProperty(const DisplayName, WebsiteAddress,
  PropertyId: string; const DisplayColor: TAlphaColor;
  const Enabled: Boolean): Integer;
begin
  Result := FProperties.Add(TWebsitePropertyDefinition.Create(DisplayName,
    WebsiteAddress, PropertyId, DisplayColor, Enabled, FProperties.Count));
end;

procedure TdmAnalyticsMemory.DeleteProperty(const Index: Integer);
begin
  if (Index >= 0) and (Index < FProperties.Count) then
    FProperties.Delete(Index);
end;

function TdmAnalyticsMemory.GetPropertyCount: Integer;
begin
  Result := FProperties.Count;
end;

function TdmAnalyticsMemory.GetPropertyDefinition(
  const Index: Integer): TWebsitePropertyDefinition;
begin
  Result := FProperties[Index];
end;

end.
