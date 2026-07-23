# Website Analytics GA4 Dashboard

Website Analytics is a Delphi FireMonkey desktop dashboard for viewing Google Analytics 4 data in a cleaner, simpler layout than the standard GA4 web interface.

This public repository is source code only. It does not include working Google credentials, private refresh tokens, or a local settings database. Every user brings their own Google Cloud OAuth desktop client and their own GA4 property IDs.

## What the app does

- Connects to Google with an installed-app OAuth desktop flow.
- Reconnects silently after first authorization by using a locally stored Windows-DPAPI-encrypted refresh token.
- Retrieves GA4 data through the Google Analytics Data API.
- Shows visitor locations by country, region/state, city, users, and sessions.
- Shows top pages, downloads, and events for the selected date range.
- Shows users over the selected range in a bar graph with hover values.
- Shows realtime active visitors, location, and last activity when GA4 supplies the data.
- Keeps analytics report rows in memory only; report rows are discarded when the app closes.

## Public setup summary

1. Install RAD Studio / Delphi with FireMonkey support.
2. Clone this repository.
3. Open `WebsiteAnalytics.dproj`.
4. Build Win64 Debug first.
5. Start the app.
6. Open Settings and enter your own Google Cloud OAuth Desktop Client ID and Client Secret.
7. Open Properties and enter your own numeric GA4 Property IDs.
8. Connect Google once, then click Update.

For detailed instructions, read:

- `docs/guides/WebsiteAnalytics_Public_How_To_Guide.docx`
- `docs/pdf/WebsiteAnalytics_Public_How_To_Guide.pdf`
- `docs/guides/WebsiteAnalytics_User_Guide.docx`
- `docs/guides/WebsiteAnalytics_Engineering_Guide.docx`

## Google and GA4 requirements

Each user needs:

- a Google Cloud project;
- the Google Analytics Data API enabled;
- an OAuth 2.0 Desktop Client ID and Client Secret;
- access to one or more GA4 properties;
- the numeric GA4 Property ID for each website.

The OAuth Client ID is not your Gmail address. The GA4 Property ID is not the `G-...` Measurement ID and not the Google Cloud project number.

## SQLite and privacy

The app creates a local SQLite settings database at startup if it does not already exist. The public repository tracks only the schema:

```text
databases/WebsiteAnalytics.schema.sql
```

The generated local database is ignored by Git:

```text
databases/*.sqlite3
```

SQLite stores local settings, website definitions, OAuth setup values, saved grid widths, and the DPAPI-encrypted refresh token. Analytics report results are not saved as history.

## Do not commit secrets

Never commit:

- `databases/*.sqlite3`
- OAuth client secrets from your Google Cloud project
- encrypted refresh tokens
- `client_secret*.json`
- `credentials*.json`
- `token*.json`
- `.env` files
- `.key`, `.pem`, or other private key material
- screenshots showing unredacted OAuth secrets or tokens

## Build notes

The project file is:

```text
WebsiteAnalytics.dproj
```

A convenience build script is included:

```text
tools/build_phase1.cmd
```

The original development environment used RAD Studio 37.0. If your RAD Studio version is different, update the build script path or build directly from the IDE.

## Repository layout

- `WebsiteAnalytics.dpr` - application entry point.
- `WebsiteAnalytics.dproj` - Delphi project file.
- `WebsiteAnalytics.MainForm.*` - main dashboard UI and behavior.
- `WebsiteAnalytics.GA4DataModule.*` - GA4 Data API request/response handling.
- `WebsiteAnalytics.AuthenticationDataModule.*` - desktop OAuth flow, token refresh, and DPAPI refresh-token storage.
- `WebsiteAnalytics.SettingsDataModule.*` - portable SQLite settings initialization.
- `WebsiteAnalytics.PropertyManagerForm.*` - website/property manager.
- `WebsiteAnalytics.SettingsForm.*` - dashboard and OAuth settings.
- `databases/WebsiteAnalytics.schema.sql` - tracked schema/default setup.
- `docs/` - public setup, user, and engineering guides.
- `help/` - local HTML help package opened by the Help button.
- `images and icons/` and `Images/` - app icon assets.
- `tools/` - build/support scripts safe for public distribution.

## License

MIT License. See `LICENSE`.
