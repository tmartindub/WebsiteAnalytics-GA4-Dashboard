# Website Analytics GA4 Setup and Release Checklist

Last changed: July 22, 2026

## Local setup

1. Build the project once so the `bin` and `dcu` folders exist.
2. Start the app. If `databases/WebsiteAnalytics.sqlite3` is missing, the app creates it from `databases/WebsiteAnalytics.schema.sql`.
3. Open Settings and enter your own Google OAuth desktop client ID and client secret.
4. Confirm the loopback redirect shown in Settings matches the redirect used by Google OAuth.
5. Confirm each website has the correct numeric GA4 property ID.
6. Connect Google and run Update.

Analytics report rows remain memory-only. The SQLite database stores local settings, saved grid widths, OAuth setup values, and the DPAPI-encrypted Google refresh token used for silent reconnect.

## Dashboard behavior

- Update retrieves live GA4 data for the selected property/date range.
- Auto update refreshes every 60 seconds while Google is connected and the app is not already updating.
- The four quadrants show locations, pages/actions/downloads, users over the selected date range, and realtime activity.
- Downloads appear only when GA4 reports a download-related event such as `file_download`.
- The graph shows users over the selected date range.
- After the first successful Google authorization, the app should normally reconnect silently on startup using the encrypted refresh token.

## Priority roadmap notes

- Treat visitors in the last 30 minutes as a high-priority Realtime improvement.
- Treat Traffic Sources, Devices / Browsers, Languages, Downloads / Events, and Data Quality as the strongest next reporting additions for worldwide users.
- Keep Countries/Regions/Cities as first-class worldwide location data; U.S. city/state formatting should be useful but not make the app feel U.S.-only.
- See `docs/guides/WebsiteAnalytics_Roadmap.md` for the fuller roadmap.

## Open-source release notes

Before making a public release:

1. Do not commit `databases/*.sqlite3`.
2. Do not commit OAuth client secret files, encrypted refresh tokens, generated databases, credential JSON files, `.env` files, keys, or PEM files.
3. Keep `databases/WebsiteAnalytics.schema.sql` tracked.
4. Tell users they must bring their own Google OAuth desktop client.
5. Document that Google may show an unverified-app warning while a user's OAuth app is in testing mode.
6. Keep OAuth screenshots redacted.
7. Consider adding first-run guidance that explains Google Cloud setup and silent reconnect inside the app.

## Build checklist

1. Run `tools\build_phase1.cmd`.
2. Confirm Win32 and Win64 builds complete.
3. Launch with `--no-startup-auth` for UI smoke testing when you do not want the OAuth browser to open.
4. Verify Settings, Properties, Diagnostics, Update, Help, auto update, and all four dashboard quadrants.
5. Check Git status and commit only intentional source/documentation changes.
