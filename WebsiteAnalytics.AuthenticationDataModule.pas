unit WebsiteAnalytics.AuthenticationDataModule;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Hash,
  System.JSON,
  System.NetConsts,
  System.NetEncoding,
  System.Net.URLClient,
  System.Net.HttpClient,
  System.IOUtils,
  Winapi.Windows,
  Winapi.ShellAPI,
  IdContext,
  IdCustomHTTPServer,
  IdHTTPServer;

type
  TdmAuthentication = class(TDataModule)
  private
    FAuthenticated: Boolean;
    FAccessToken: string;
    FCodeVerifier: string;
    FHttpServer: TIdHTTPServer;
    FOAuthFlowComplete: Boolean;
    FLastError: string;
    FLastStatus: string;
    FPendingClientId: string;
    FPendingClientSecret: string;
    FPendingRedirectPort: string;
    FPendingState: string;
    FRefreshToken: string;
    function Base64UrlEncode(const Bytes: TBytes): string;
    function BuildCodeChallenge(const CodeVerifier: string): string;
    function BuildTokenFailureMessage(const Response: IHTTPResponse;
      const ResponseText: string): string;
    function DecryptRefreshTokenForStorage(const EncryptedValue: string): string;
    function EncryptRefreshTokenForStorage(const PlainValue: string): string;
    function GenerateCodeVerifier: string;
    function GenerateState: string;
    procedure SaveRefreshTokenToSettings;
    procedure ExchangeAuthorizationCode(const ClientId, ClientSecret,
      RedirectPort,
      AuthorizationCode: string);
    procedure OAuthRedirectCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure StopRedirectListener;
  public
    destructor Destroy; override;
    function BuildDesktopAuthorizationUrl(const ClientId, RedirectPort,
      State: string): string;
    function LoadSavedRefreshToken: Boolean;
    function DesktopRedirectUri(const RedirectPort: string): string;
    function HasRefreshToken: Boolean;
    function RefreshAccessToken(const ClientId, ClientSecret: string): Boolean;
    function StartDesktopOAuth(const ClientId, ClientSecret,
      RedirectPort: string): Boolean;
    procedure ClearAccessToken;
    procedure ClearSavedRefreshToken;
    procedure SetAccessToken(const Value: string);
    property AccessToken: string read FAccessToken;
    property Authenticated: Boolean read FAuthenticated;
    property LastError: string read FLastError;
    property LastStatus: string read FLastStatus;
    property OAuthFlowComplete: Boolean read FOAuthFlowComplete;
  end;

var
  dmAuthentication: TdmAuthentication;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

uses
  WebsiteAnalytics.SettingsDataModule;

type
  TDataBlob = record
    cbData: DWORD;
    pbData: PByte;
  end;
  PDataBlob = ^TDataBlob;

const
  CRYPTPROTECT_UI_FORBIDDEN = $00000001;
  SAVED_REFRESH_TOKEN_SETTING = 'ga4_oauth_refresh_token_dpapi';

function CryptProtectData(var DataIn: TDataBlob; DataDescription: PWideChar;
  OptionalEntropy: PDataBlob; Reserved: Pointer; PromptStruct: Pointer;
  Flags: DWORD; var DataOut: TDataBlob): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptProtectData';

function CryptUnprotectData(var DataIn: TDataBlob; DataDescription: PPWideChar;
  OptionalEntropy: PDataBlob; Reserved: Pointer; PromptStruct: Pointer;
  Flags: DWORD; var DataOut: TDataBlob): BOOL; stdcall;
  external 'crypt32.dll' name 'CryptUnprotectData';

function TdmAuthentication.Base64UrlEncode(const Bytes: TBytes): string;
begin
  Result := TNetEncoding.Base64.EncodeBytesToString(Bytes);
  Result := Result.Replace('+', '-').Replace('/', '_').Replace('=', '');
end;

procedure TdmAuthentication.ClearSavedRefreshToken;
begin
  FRefreshToken := '';
  if Assigned(dmSettings) then
    dmSettings.WriteSetting(SAVED_REFRESH_TOKEN_SETTING, '', 'ga4',
      'Encrypted Google OAuth refresh token for silent startup reconnect');
end;

function TdmAuthentication.BuildCodeChallenge(
  const CodeVerifier: string): string;
begin
  Result := Base64UrlEncode(THashSHA2.GetHashBytes(CodeVerifier));
end;

function TdmAuthentication.BuildTokenFailureMessage(
  const Response: IHTTPResponse; const ResponseText: string): string;
var
  ErrorDescriptionValue: TJSONValue;
  ErrorValue: TJSONValue;
  ResponseJson: TJSONObject;
begin
  Result := Format('Token exchange failed: HTTP %d %s',
    [Response.StatusCode, Response.StatusText]);

  ResponseJson := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
  try
    if Assigned(ResponseJson) then
    begin
      ErrorValue := ResponseJson.GetValue('error');
      ErrorDescriptionValue := ResponseJson.GetValue('error_description');
      if Assigned(ErrorValue) then
        Result := Result + ' - ' + ErrorValue.Value;
      if Assigned(ErrorDescriptionValue) then
        Result := Result + ': ' + ErrorDescriptionValue.Value;
    end
    else if Trim(ResponseText) <> '' then
      Result := Result + ' - ' + Trim(ResponseText);
  finally
    ResponseJson.Free;
  end;
end;

function TdmAuthentication.DesktopRedirectUri(
  const RedirectPort: string): string;
var
  PortText: string;
begin
  PortText := Trim(RedirectPort);
  if PortText = '' then
    PortText := '53682';
  Result := 'http://127.0.0.1:' + PortText + '/oauth2redirect';
end;

function TdmAuthentication.BuildDesktopAuthorizationUrl(const ClientId,
  RedirectPort, State: string): string;
const
  AuthorizationEndpoint = 'https://accounts.google.com/o/oauth2/v2/auth';
  AnalyticsReadonlyScope = 'https://www.googleapis.com/auth/analytics.readonly';
var
  RedirectUri: string;
begin
  RedirectUri := DesktopRedirectUri(RedirectPort);
  Result := AuthorizationEndpoint +
    '?response_type=code' +
    '&access_type=offline' +
    '&prompt=consent' +
    '&client_id=' + TNetEncoding.URL.Encode(Trim(ClientId)) +
    '&redirect_uri=' + TNetEncoding.URL.Encode(RedirectUri) +
    '&scope=' + TNetEncoding.URL.Encode(AnalyticsReadonlyScope) +
    '&code_challenge=' + TNetEncoding.URL.Encode(BuildCodeChallenge(FCodeVerifier)) +
    '&code_challenge_method=S256' +
    '&state=' + TNetEncoding.URL.Encode(State);
end;

procedure TdmAuthentication.ClearAccessToken;
begin
  FAccessToken := '';
  FAuthenticated := False;
  FOAuthFlowComplete := False;
  FLastStatus := 'Not connected';
end;

function TdmAuthentication.DecryptRefreshTokenForStorage(
  const EncryptedValue: string): string;
var
  EncryptedBytes: TBytes;
  DataIn: TDataBlob;
  DataOut: TDataBlob;
  PlainBytes: TBytes;
begin
  Result := '';
  if Trim(EncryptedValue) = '' then
    Exit;

  EncryptedBytes := TNetEncoding.Base64.DecodeStringToBytes(EncryptedValue);
  if Length(EncryptedBytes) = 0 then
    Exit;

  ZeroMemory(@DataIn, SizeOf(DataIn));
  ZeroMemory(@DataOut, SizeOf(DataOut));
  DataIn.cbData := Length(EncryptedBytes);
  DataIn.pbData := @EncryptedBytes[0];

  if CryptUnprotectData(DataIn, nil, nil, nil, nil, CRYPTPROTECT_UI_FORBIDDEN,
    DataOut) then
  try
    SetLength(PlainBytes, DataOut.cbData);
    if DataOut.cbData > 0 then
      Move(DataOut.pbData^, PlainBytes[0], DataOut.cbData);
    Result := TEncoding.UTF8.GetString(PlainBytes);
  finally
    LocalFree(HLOCAL(DataOut.pbData));
  end;
end;

destructor TdmAuthentication.Destroy;
begin
  StopRedirectListener;
  inherited;
end;

procedure TdmAuthentication.ExchangeAuthorizationCode(const ClientId,
  ClientSecret, RedirectPort, AuthorizationCode: string);
var
  Headers: TNetHeaders;
  HttpClient: THTTPClient;
  RequestBody: TStringStream;
  RequestText: string;
  Response: IHTTPResponse;
  ResponseText: string;
  ResponseJson: TJSONObject;
  JsonValue: TJSONValue;
begin
  RequestText :=
    'code=' + TNetEncoding.URL.Encode(AuthorizationCode) +
    '&client_id=' + TNetEncoding.URL.Encode(Trim(ClientId)) +
    '&code_verifier=' + TNetEncoding.URL.Encode(FCodeVerifier) +
    '&redirect_uri=' + TNetEncoding.URL.Encode(DesktopRedirectUri(RedirectPort)) +
    '&grant_type=authorization_code';
  if Trim(ClientSecret) <> '' then
    RequestText := RequestText + '&client_secret=' +
      TNetEncoding.URL.Encode(Trim(ClientSecret));

  HttpClient := THTTPClient.Create;
  RequestBody := TStringStream.Create(RequestText, TEncoding.UTF8);
  try
    SetLength(Headers, 2);
    Headers[0].Name := 'Content-Type';
    Headers[0].Value := 'application/x-www-form-urlencoded';
    Headers[1].Name := 'Accept';
    Headers[1].Value := 'application/json';
    Response := HttpClient.Post('https://oauth2.googleapis.com/token',
      RequestBody, nil, Headers);
    ResponseText := Response.ContentAsString(TEncoding.UTF8);
    if Response.StatusCode <> 200 then
    begin
      FLastError := BuildTokenFailureMessage(Response, ResponseText);
      FLastStatus := FLastError;
      Exit;
    end;

    ResponseJson := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      if not Assigned(ResponseJson) then
      begin
        FLastError := 'Token exchange returned invalid JSON.';
        FLastStatus := FLastError;
        Exit;
      end;

      JsonValue := ResponseJson.GetValue('access_token');
      if Assigned(JsonValue) then
        SetAccessToken(JsonValue.Value);

      JsonValue := ResponseJson.GetValue('refresh_token');
      if Assigned(JsonValue) then
      begin
        FRefreshToken := JsonValue.Value;
        SaveRefreshTokenToSettings;
      end;

      if FAuthenticated then
      begin
        FLastError := '';
        FLastStatus := 'Connected to Google Analytics for this app session';
      end
      else
      begin
        FLastError := 'Token exchange did not return an access token.';
        FLastStatus := FLastError;
      end;
    finally
      ResponseJson.Free;
    end;
  finally
    RequestBody.Free;
    HttpClient.Free;
  end;
end;

function TdmAuthentication.GenerateCodeVerifier: string;
begin
  Result := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '') +
    TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '') +
    TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '');
end;

function TdmAuthentication.GenerateState: string;
begin
  Result := TGUID.NewGuid.ToString.Replace('{', '').Replace('}', '').Replace('-', '');
end;

function TdmAuthentication.EncryptRefreshTokenForStorage(
  const PlainValue: string): string;
var
  DataIn: TDataBlob;
  DataOut: TDataBlob;
  EncryptedBytes: TBytes;
  PlainBytes: TBytes;
begin
  Result := '';
  if Trim(PlainValue) = '' then
    Exit;

  PlainBytes := TEncoding.UTF8.GetBytes(PlainValue);
  if Length(PlainBytes) = 0 then
    Exit;

  ZeroMemory(@DataIn, SizeOf(DataIn));
  ZeroMemory(@DataOut, SizeOf(DataOut));
  DataIn.cbData := Length(PlainBytes);
  DataIn.pbData := @PlainBytes[0];

  if CryptProtectData(DataIn, 'Website Analytics GA4 refresh token', nil, nil,
    nil, CRYPTPROTECT_UI_FORBIDDEN, DataOut) then
  try
    SetLength(EncryptedBytes, DataOut.cbData);
    if DataOut.cbData > 0 then
      Move(DataOut.pbData^, EncryptedBytes[0], DataOut.cbData);
    Result := TNetEncoding.Base64.EncodeBytesToString(EncryptedBytes);
  finally
    LocalFree(HLOCAL(DataOut.pbData));
  end;
end;

function TdmAuthentication.HasRefreshToken: Boolean;
begin
  Result := Trim(FRefreshToken) <> '';
end;

function TdmAuthentication.LoadSavedRefreshToken: Boolean;
var
  EncryptedValue: string;
begin
  Result := False;
  if not Assigned(dmSettings) then
    Exit;

  EncryptedValue := dmSettings.ReadSetting(SAVED_REFRESH_TOKEN_SETTING, '');
  FRefreshToken := DecryptRefreshTokenForStorage(EncryptedValue);
  Result := HasRefreshToken;
  if Result then
    FLastStatus := 'Saved Google refresh token loaded for silent reconnect.'
  else if Trim(EncryptedValue) <> '' then
    FLastStatus := 'Saved Google refresh token could not be decrypted.';
end;

procedure TdmAuthentication.OAuthRedirectCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  AuthorizationCode: string;
  ErrorText: string;
  ResponseHtml: string;
  StateText: string;
begin
  if not SameText(ARequestInfo.Document, '/oauth2redirect') then
  begin
    AResponseInfo.ResponseNo := 404;
    AResponseInfo.ContentText := 'Not found';
    Exit;
  end;

  ErrorText := ARequestInfo.Params.Values['error'];
  StateText := ARequestInfo.Params.Values['state'];
  AuthorizationCode := ARequestInfo.Params.Values['code'];

  if ErrorText <> '' then
  begin
    FLastError := 'Google sign-in returned: ' + ErrorText;
    FLastStatus := FLastError;
  end
  else if StateText <> FPendingState then
  begin
    FLastError := 'Google sign-in returned an unexpected state value.';
    FLastStatus := FLastError;
  end
  else if AuthorizationCode = '' then
  begin
    FLastError := 'Google sign-in did not return an authorization code.';
    FLastStatus := FLastError;
  end
  else
    ExchangeAuthorizationCode(FPendingClientId, FPendingClientSecret,
      FPendingRedirectPort,
      AuthorizationCode);

  FOAuthFlowComplete := True;

  ResponseHtml := '<html><body style="font-family:Segoe UI,Arial">' +
    '<h2>Website Analytics</h2>' +
    '<p>You may close this browser tab and return to the app.</p>' +
    '</body></html>';
  AResponseInfo.ContentType := 'text/html';
  AResponseInfo.ContentText := ResponseHtml;
  AResponseInfo.CloseConnection := True;

  TThread.Queue(nil,
    procedure
    begin
      StopRedirectListener;
    end);
end;

procedure TdmAuthentication.SetAccessToken(const Value: string);
begin
  FAccessToken := Trim(Value);
  FAuthenticated := FAccessToken <> '';
end;

function TdmAuthentication.RefreshAccessToken(const ClientId,
  ClientSecret: string): Boolean;
var
  Headers: TNetHeaders;
  HttpClient: THTTPClient;
  JsonValue: TJSONValue;
  RequestBody: TStringStream;
  RequestText: string;
  Response: IHTTPResponse;
  ResponseJson: TJSONObject;
  ResponseText: string;
begin
  Result := False;
  FLastError := '';

  if Trim(FRefreshToken) = '' then
  begin
    FLastStatus := 'Google sign-in is required because no refresh token is available.';
    FAuthenticated := False;
    Exit;
  end;

  RequestText :=
    'client_id=' + TNetEncoding.URL.Encode(Trim(ClientId)) +
    '&refresh_token=' + TNetEncoding.URL.Encode(Trim(FRefreshToken)) +
    '&grant_type=refresh_token';
  if Trim(ClientSecret) <> '' then
    RequestText := RequestText + '&client_secret=' +
      TNetEncoding.URL.Encode(Trim(ClientSecret));

  HttpClient := THTTPClient.Create;
  RequestBody := TStringStream.Create(RequestText, TEncoding.UTF8);
  try
    SetLength(Headers, 2);
    Headers[0].Name := 'Content-Type';
    Headers[0].Value := 'application/x-www-form-urlencoded';
    Headers[1].Name := 'Accept';
    Headers[1].Value := 'application/json';
    Response := HttpClient.Post('https://oauth2.googleapis.com/token',
      RequestBody, nil, Headers);
    ResponseText := Response.ContentAsString(TEncoding.UTF8);
    if Response.StatusCode <> 200 then
    begin
      FLastError := BuildTokenFailureMessage(Response, ResponseText);
      FLastStatus := FLastError;
      FAuthenticated := False;
      Exit;
    end;

    ResponseJson := TJSONObject.ParseJSONValue(ResponseText) as TJSONObject;
    try
      if not Assigned(ResponseJson) then
      begin
        FLastError := 'Token refresh returned invalid JSON.';
        FLastStatus := FLastError;
        FAuthenticated := False;
        Exit;
      end;

      JsonValue := ResponseJson.GetValue('access_token');
      if Assigned(JsonValue) then
        SetAccessToken(JsonValue.Value);

      Result := FAuthenticated;
      if Result then
      begin
        FLastError := '';
        FLastStatus := 'Google access token refreshed for continued dashboard updates.';
      end
      else
      begin
        FLastError := 'Token refresh did not return an access token.';
        FLastStatus := FLastError;
      end;
    finally
      ResponseJson.Free;
    end;
  finally
    RequestBody.Free;
    HttpClient.Free;
  end;
end;

procedure TdmAuthentication.SaveRefreshTokenToSettings;
var
  EncryptedValue: string;
begin
  if (not Assigned(dmSettings)) or (Trim(FRefreshToken) = '') then
    Exit;

  EncryptedValue := EncryptRefreshTokenForStorage(FRefreshToken);
  if EncryptedValue <> '' then
    dmSettings.WriteSetting(SAVED_REFRESH_TOKEN_SETTING, EncryptedValue, 'ga4',
      'Encrypted Google OAuth refresh token for silent startup reconnect');
end;

function TdmAuthentication.StartDesktopOAuth(const ClientId, ClientSecret,
  RedirectPort: string): Boolean;
var
  AuthorizationUrl: string;
  PortValue: Integer;
begin
  Result := False;
  FLastError := '';
  FOAuthFlowComplete := False;

  if Trim(ClientId) = '' then
  begin
    FLastStatus := 'Enter the Google desktop OAuth client ID first.';
    Exit;
  end;

  PortValue := StrToIntDef(Trim(RedirectPort), 53682);
  FCodeVerifier := GenerateCodeVerifier;
  FPendingClientId := Trim(ClientId);
  FPendingClientSecret := Trim(ClientSecret);
  FPendingRedirectPort := IntToStr(PortValue);
  FPendingState := GenerateState;

  StopRedirectListener;
  FHttpServer := TIdHTTPServer.Create(Self);
  FHttpServer.DefaultPort := PortValue;
  FHttpServer.OnCommandGet := OAuthRedirectCommandGet;
  FHttpServer.Active := True;

  AuthorizationUrl := BuildDesktopAuthorizationUrl(ClientId, IntToStr(PortValue),
    FPendingState);

  FLastStatus := 'Opening Google sign-in in your browser';
  ShellExecute(0, 'open', PChar(AuthorizationUrl), nil, nil, SW_SHOWNORMAL);
  Result := True;
end;

procedure TdmAuthentication.StopRedirectListener;
begin
  if Assigned(FHttpServer) then
  begin
    FHttpServer.Active := False;
    FreeAndNil(FHttpServer);
  end;
end;

end.
