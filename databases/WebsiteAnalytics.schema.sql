PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS app_settings (
  setting_name TEXT PRIMARY KEY,
  setting_value TEXT NOT NULL,
  setting_group TEXT NOT NULL DEFAULT 'general',
  description TEXT NOT NULL DEFAULT '',
  updated_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS website_properties (
  property_key INTEGER PRIMARY KEY AUTOINCREMENT,
  display_name TEXT NOT NULL,
  website_address TEXT NOT NULL,
  ga4_property_id TEXT NOT NULL DEFAULT '',
  display_color INTEGER NOT NULL,
  enabled INTEGER NOT NULL DEFAULT 1,
  display_order INTEGER NOT NULL DEFAULT 0,
  updated_utc TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_website_properties_order
ON website_properties(display_order, display_name);

INSERT OR IGNORE INTO app_settings
  (setting_name, setting_value, setting_group, description)
VALUES
  ('schema_version', '1', 'system', 'Portable settings database schema version'),
  ('default_website_index', '0', 'dashboard', 'Default selected website, where 0 means all websites'),
  ('default_date_range_index', '2', 'dashboard', 'Default date range selection'),
  ('refresh_at_startup', '1', 'dashboard', 'Retrieve GA4 data when the program opens after authentication is configured'),
  ('compare_previous_period', '1', 'dashboard', 'Compare the selected period with the previous period'),
  ('theme_name', 'VCL2FMX Blue', 'appearance', 'Current dashboard color theme'),
  ('ga4_auth_method', 'desktop_oauth', 'ga4', 'Preferred GA4 authentication approach'),
  ('ga4_oauth_client_id', '', 'ga4', 'Google Cloud desktop OAuth client ID'),
  ('ga4_oauth_client_secret', '', 'ga4', 'Google Cloud desktop OAuth client secret for token exchange when required'),
  ('ga4_oauth_redirect_port', '53682', 'ga4', 'Local loopback port used for Google OAuth desktop sign-in'),
  ('ga4_oauth_scope', 'https://www.googleapis.com/auth/analytics.readonly', 'ga4', 'Read-only Google Analytics scope for GA4 Data API reporting'),
  ('ga4_oauth_refresh_token_dpapi', '', 'ga4', 'Encrypted Google OAuth refresh token for silent startup reconnect');

INSERT INTO website_properties
  (display_name, website_address, ga4_property_id, display_color, enabled, display_order)
SELECT 'Example Site', 'https://example.com', '', -15108897, 1, 0
WHERE NOT EXISTS (SELECT 1 FROM website_properties);
