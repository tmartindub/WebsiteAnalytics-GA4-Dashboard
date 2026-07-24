from __future__ import annotations

import json
import os
from datetime import date
from pathlib import Path

from docx import Document
from docx.enum.section import WD_SECTION_START
from docx.enum.table import WD_CELL_VERTICAL_ALIGNMENT, WD_TABLE_ALIGNMENT
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from docx.shared import Inches, Pt, RGBColor


ROOT = Path(__file__).resolve().parents[1]
GUIDES = ROOT / "docs" / "guides"
PDFS = ROOT / "docs" / "pdf"
HELP = ROOT / "help"
ASSETS = GUIDES / "doc-assets"
HELP_ASSETS = HELP / "assets"
TODAY = date.today().strftime("%B %#d, %Y") if os.name == "nt" else date.today().strftime("%B %-d, %Y")

NAVY = "0B2341"
BLUE = "1974DF"
CYAN = "38BDF8"
MUTED = "64748B"
LIGHT = "EAF8FF"
TABLE = "F2F7FC"


ASSET_FILES = {
    "dashboard": "real-dashboard-current-redacted.png",
    "hero": "real-hero-redacted.png",
    "cards": "real-summary-cards.png",
    "locations": "real-locations-grid-redacted.png",
    "pages": "real-pages-downloads-redacted.png",
    "graph": "real-users-graph.png",
    "realtime": "real-realtime-panel.png",
    "settings": "real-settings-redacted.png",
    "properties": "real-properties-redacted.png",
}


def rgb(hex_value: str) -> RGBColor:
    return RGBColor.from_string(hex_value)


def set_shading(cell, fill: str) -> None:
    tc_pr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement("w:shd")
    shd.set(qn("w:fill"), fill)
    tc_pr.append(shd)


def set_cell_margins(table, margin: int = 120) -> None:
    tbl_pr = table._tbl.tblPr
    tbl_cell_mar = tbl_pr.first_child_found_in("w:tblCellMar")
    if tbl_cell_mar is None:
        tbl_cell_mar = OxmlElement("w:tblCellMar")
        tbl_pr.append(tbl_cell_mar)
    for edge in ("top", "start", "bottom", "end"):
        node = tbl_cell_mar.find(qn(f"w:{edge}"))
        if node is None:
            node = OxmlElement(f"w:{edge}")
            tbl_cell_mar.append(node)
        node.set(qn("w:w"), str(margin))
        node.set(qn("w:type"), "dxa")


def add_toc(paragraph) -> None:
    run = paragraph.add_run()
    begin = OxmlElement("w:fldChar")
    begin.set(qn("w:fldCharType"), "begin")
    instr = OxmlElement("w:instrText")
    instr.set(qn("xml:space"), "preserve")
    instr.text = 'TOC \\o "1-3" \\h \\z \\u'
    sep = OxmlElement("w:fldChar")
    sep.set(qn("w:fldCharType"), "separate")
    end = OxmlElement("w:fldChar")
    end.set(qn("w:fldCharType"), "end")
    run._r.append(begin)
    run._r.append(instr)
    run._r.append(sep)
    run._r.append(end)


def setup_doc(doc: Document, title: str, subtitle: str) -> None:
    sec = doc.sections[0]
    sec.top_margin = Inches(0.75)
    sec.bottom_margin = Inches(0.75)
    sec.left_margin = Inches(0.75)
    sec.right_margin = Inches(0.75)
    styles = doc.styles
    normal = styles["Normal"]
    normal.font.name = "Calibri"
    normal.font.size = Pt(10.5)
    normal.paragraph_format.space_after = Pt(6)
    normal.paragraph_format.line_spacing = 1.12
    for name, size, color in [
        ("Heading 1", 18, NAVY),
        ("Heading 2", 14, BLUE),
        ("Heading 3", 12, NAVY),
    ]:
        style = styles[name]
        style.font.name = "Calibri"
        style.font.size = Pt(size)
        style.font.bold = True
        style.font.color.rgb = rgb(color)
        style.paragraph_format.space_before = Pt(14 if name == "Heading 1" else 9)
        style.paragraph_format.space_after = Pt(6)

    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(title)
    r.bold = True
    r.font.size = Pt(28)
    r.font.color.rgb = rgb(NAVY)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(subtitle)
    r.font.size = Pt(12)
    r.font.color.rgb = rgb(MUTED)
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p.add_run(f"Last changed: {TODAY}")
    r.font.size = Pt(10)
    r.font.color.rgb = rgb(MUTED)

    callout = doc.add_table(rows=1, cols=1)
    callout.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_cell_margins(callout)
    cell = callout.cell(0, 0)
    set_shading(cell, LIGHT)
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    cell.text = (
        "All screenshots in this guide are actual application screenshots that have been cropped and sanitized. "
        "Private property names, property IDs, OAuth values, personal paths, and location details are hidden."
    )

    doc.add_paragraph()
    doc.add_heading("Table of Contents", level=1)
    add_toc(doc.add_paragraph())
    doc.add_page_break()


def paragraph(doc: Document, text: str) -> None:
    doc.add_paragraph(text)


def bullets(doc: Document, items: list[str]) -> None:
    for item in items:
        doc.add_paragraph(item, style="List Bullet")


def numbered(doc: Document, items: list[str]) -> None:
    for item in items:
        doc.add_paragraph(item, style="List Number")


def figure(doc: Document, asset_key: str, caption: str, width: float = 6.6) -> None:
    image_path = ASSETS / ASSET_FILES[asset_key]
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.add_run().add_picture(str(image_path), width=Inches(width))
    c = doc.add_paragraph(caption)
    c.alignment = WD_ALIGN_PARAGRAPH.CENTER
    run = c.runs[0]
    run.italic = True
    run.font.size = Pt(9)
    run.font.color.rgb = rgb(MUTED)


def simple_table(doc: Document, headers: list[str], rows: list[tuple[str, ...]]) -> None:
    table = doc.add_table(rows=1, cols=len(headers))
    table.style = "Table Grid"
    table.alignment = WD_TABLE_ALIGNMENT.CENTER
    set_cell_margins(table)
    for i, h in enumerate(headers):
        table.cell(0, i).text = h
        set_shading(table.cell(0, i), TABLE)
    for row in rows:
        cells = table.add_row().cells
        for i, value in enumerate(row):
            cells[i].text = value


def build_user_guide() -> None:
    doc = Document()
    setup_doc(
        doc,
        "Website Analytics User Guide",
        "A practical guide to using the GA4 desktop dashboard",
    )

    doc.add_heading("1. What This Application Is Doing", level=1)
    paragraph(
        doc,
        "Website Analytics is a Delphi FMX desktop dashboard for Google Analytics 4. "
        "Its purpose is to answer the everyday questions a site owner actually asks: who visited, "
        "where they came from, what pages or downloads they used, what the recent trend looks like, "
        "and whether anyone is active right now. It does not try to reproduce every GA4 screen. "
        "It pulls selected GA4 data through the Google Analytics Data API, keeps the report rows in memory, "
        "formats the results, and displays them in a cleaner desktop layout.",
    )
    paragraph(
        doc,
        "The application stores settings locally, but analytics report results are intentionally memory-only. "
        "When the application closes, the fetched GA4 report rows are discarded. This keeps the program simple, "
        "portable, and suitable for open-source use without creating a second analytics database.",
    )
    figure(doc, "dashboard", "Actual dashboard screenshot, cropped/sanitized to hide private row data.", 6.6)

    doc.add_heading("2. Important Terms", level=1)
    simple_table(
        doc,
        ["Term", "Meaning in this application"],
        [
            ("Website property", "A saved website definition that contains a display name and a numeric GA4 property ID."),
            ("GA4 property ID", "The numeric property identifier used by the GA4 Data API. It is not the G- measurement ID."),
            ("Date range", "The selected historical reporting window, such as Today, Last 7 days, Last 28 days, or Last 90 days."),
            ("Realtime data", "GA4 data from the realtime endpoint, generally representing current or recent activity."),
            ("Standard report data", "Historical GA4 report data returned by runReport requests for a selected date range."),
            ("Memory-only rows", "Fetched analytics rows that are shown on screen but not saved to the SQLite database."),
        ],
    )

    doc.add_heading("3. First-Time Setup", level=1)
    paragraph(
        doc,
        "First-time setup connects your copy of the desktop app to your own Google account and your own GA4 properties. "
        "The app does not include shared Google credentials. Each user should create and enter their own OAuth desktop client values."
    )
    numbered(
        doc,
        [
            "Confirm that GA4 is installed and collecting data on the website.",
            "Find the numeric GA4 property ID in Google Analytics Admin.",
            "Create a Google Cloud Desktop OAuth client for this app.",
            "Enable the Google Analytics Data API in the same Google Cloud project.",
            "Open Settings in the app and enter the OAuth desktop client ID and client secret.",
            "Confirm that the redirect URI shown in Settings matches the local loopback redirect used by the desktop OAuth client.",
            "Click Connect Google, complete the browser sign-in, return to the app, and click Update.",
        ],
    )
    figure(doc, "settings", "Actual Settings screen section with OAuth values redacted.", 6.3)

    doc.add_heading("4. The Main Dashboard", level=1)
    paragraph(
        doc,
        "The dashboard is organized for glanceable use. The top hero area contains the app identity, website selector, "
        "date range selector, auto-update setting, current connection status, and the Update, Settings, and Help buttons."
    )
    figure(doc, "hero", "Actual hero/control area with the selected property value redacted.", 6.5)
    paragraph(
        doc,
        "Below the hero, the workspace is divided into practical report areas. The left side focuses on tabular lookup: "
        "visitor locations and pages/downloads/actions. The right side focuses on visual trend and realtime status."
    )

    doc.add_heading("5. Summary Cards", level=1)
    paragraph(
        doc,
        "The card group gives quick values without forcing you to read a grid. These cards should be used as first-glance indicators. "
        "If something looks interesting, the grid or chart below the cards gives more context."
    )
    figure(doc, "cards", "Actual summary-card area from the application.", 5.9)
    simple_table(
        doc,
        ["Card", "What it tells you", "Notes"],
        [
            ("Users today", "Users reported for the current day.", "Uses the current day rather than the selected historical range."),
            ("Users for selected range", "Users for the selected date range.", "Should agree with the users chart total for the same reporting scope."),
            ("Views today", "Page/screen views for the current day.", "Useful for quick same-day activity checks."),
            ("Downloads", "Download events in the selected range.", "Depends on the website emitting GA4 download events."),
            ("Active now", "Current realtime active users.", "Realtime data can update differently from standard report data."),
            ("Last Location", "Latest returned realtime location.", "Shown only when GA4 returns usable city/country or city/state data."),
            ("Top page", "Most-used page for the selected range.", "Home page is shown when the GA4 path is /."),
            ("Views last 30 min", "Realtime views during the recent realtime window.", "Uses realtime reporting."),
            ("Events/session", "Average events per session.", "Helps indicate whether sessions are shallow or active."),
            ("Scrolled", "Users who triggered the scroll metric/event.", "Useful as a simple engagement signal."),
        ],
    )

    doc.add_heading("6. Visitor Locations", level=1)
    paragraph(
        doc,
        "The location grid answers where visitors came from. It groups by country, region/state, and city, then shows users and sessions. "
        "Rows are sorted alphabetically so a country, state, or city is easier to find than in GA4's default scrolling lists."
    )
    figure(doc, "locations", "Actual location grid with visitor rows redacted.", 6.3)
    bullets(
        doc,
        [
            "Country is the broadest location grouping.",
            "Region / State is a state, province, county, or other regional value when GA4 supplies it.",
            "City is shown when GA4 can resolve it; otherwise GA4 may return (not set).",
            "Users counts people; sessions counts visits/sessions. They are related but not the same number.",
            "If a row says (not set), that is a GA4 result, not a dashboard formatting bug.",
        ],
    )

    doc.add_heading("7. Pages, Downloads, and Actions", level=1)
    paragraph(
        doc,
        "The pages/downloads area answers what visitors used. Instead of burying this information inside GA4 event tables, "
        "the dashboard combines page title, path, action/event, users, and event/download counts into one practical view."
    )
    figure(doc, "pages", "Actual pages/downloads area with row details redacted.", 6.3)
    bullets(
        doc,
        [
            "Page title is the browser/page title reported to GA4.",
            "Path is the URL path, such as / or /downloads.html.",
            "Action/Event distinguishes page views, file downloads, clicks, scrolls, and other GA4 events.",
            "Users shows how many users were associated with that row.",
            "Events/downloads shows how many event occurrences were returned for that row.",
        ],
    )

    doc.add_heading("8. Users Graph", level=1)
    paragraph(
        doc,
        "The users graph is intentionally simple. Its job is to show whether traffic rose, fell, spiked, or stayed flat over the selected date range. "
        "The current layout uses a bar graph because it is easier to read than a smooth line when values are daily counts."
    )
    figure(doc, "graph", "Actual users graph from the dashboard.", 6.3)
    bullets(
        doc,
        [
            "The title shows the selected range and exact date span.",
            "The left scale uses whole numbers and starts at zero.",
            "Each bar represents the reporting unit shown on the chart, usually a day.",
            "Hovering over a bar shows the exact value in the compact tooltip.",
        ],
    )

    doc.add_heading("9. Realtime Activity", level=1)
    paragraph(
        doc,
        "The realtime panel answers what is happening right now. This information comes from GA4 realtime reporting and should be treated as a live indicator, "
        "not as a permanent historical record. When the selected property changes, realtime location text should reset so stale locations are not carried between sites."
    )
    figure(doc, "realtime", "Actual realtime panel with no private location shown.", 6.3)

    doc.add_heading("10. Auto Update and Long-Running Use", level=1)
    paragraph(
        doc,
        "The app is intended to be left open while you work. With Auto 60 sec enabled, it refreshes automatically about once per minute. "
        "Manual Update is still available when you want an immediate refresh. If the access token expires, the app attempts to refresh it silently using the encrypted refresh token."
    )
    bullets(
        doc,
        [
            "Leave the app open for an always-visible site dashboard.",
            "Use the status bar to confirm the last update or see an error message.",
            "If Google sign-in appears again, the saved refresh token may have been revoked, removed, or tied to another Windows account.",
            "Realtime and standard reports can differ briefly because GA4 updates those data surfaces differently.",
        ],
    )

    doc.add_heading("11. Managing Properties", level=1)
    paragraph(
        doc,
        "Properties are the websites the app can query. A property definition normally includes a display name, URL, numeric GA4 property ID, enabled state, and ordering information. "
        "Only enabled properties appear in normal dashboard selection."
    )
    figure(doc, "properties", "Actual Manage Properties screen with property names and IDs redacted.", 6.1)
    bullets(
        doc,
        [
            "Use the numeric GA4 property ID from GA4 Admin.",
            "Do not enter the G- measurement ID.",
            "Do not enter the Google Cloud project number.",
            "For open-source copies, each user should add their own properties.",
        ],
    )

    doc.add_heading("12. Privacy and Storage", level=1)
    paragraph(
        doc,
        "The dashboard is intentionally conservative about storage. Settings are stored so the app can remember how you use it. Report results are not stored. "
        "The saved Google refresh token is encrypted using Windows DPAPI so it is tied to the current Windows user profile."
    )
    simple_table(
        doc,
        ["Stored", "Where", "Why"],
        [
            ("Dashboard settings", "Portable SQLite database", "Remember defaults such as date range and selected website."),
            ("Website/property definitions", "Portable SQLite database", "Let the app query multiple websites."),
            ("OAuth client ID/secret", "Portable SQLite database", "Allow Google token exchange for the desktop OAuth client."),
            ("Refresh token", "SQLite, encrypted with DPAPI", "Allow silent reconnect on startup."),
            ("GA4 report rows", "Memory only", "Avoid creating a separate analytics database."),
        ],
    )

    doc.add_heading("13. Troubleshooting", level=1)
    simple_table(
        doc,
        ["Symptom", "Likely cause", "What to check"],
        [
            ("Google says the app is not verified", "OAuth consent app is still in testing", "Add yourself as a test user or complete Google verification before broad public use."),
            ("403 permission error", "Wrong property ID or wrong Google account", "Confirm the numeric GA4 property ID and GA4 Admin access for the signed-in account."),
            ("No rows returned", "No GA4 data for that range/property", "Try a wider date range and compare with GA4."),
            ("Downloads are zero", "No download event reported", "Confirm the website sends file_download or equivalent GA4 events."),
            ("Realtime shows location but grid does not", "Realtime and standard GA4 reports update differently", "Refresh later or compare current-day standard reports."),
            ("Login appears again", "Refresh token missing/revoked/unusable", "Open Settings and reconnect Google."),
        ],
    )

    doc.add_heading("14. How to Interpret the Numbers", level=1)
    paragraph(
        doc,
        "The dashboard intentionally separates similar-looking numbers because GA4 metrics do not all mean the same thing. "
        "Users, sessions, views, events, downloads, realtime active users, and realtime views answer different questions. "
        "The most common mistake is expecting every number to move together. A single person can create multiple sessions, view multiple pages, trigger several events, and still count as one user."
    )
    simple_table(
        doc,
        ["Metric", "Plain-language meaning", "How to use it"],
        [
            ("Users", "People or browser/device identities GA4 counted.", "Use for overall audience size."),
            ("Sessions", "Visits or activity periods.", "Use for visit volume. Sessions can exceed users."),
            ("Views", "Page/screen views.", "Use for page consumption and site activity."),
            ("Events", "Tracked actions GA4 received.", "Use for interactions such as clicks, downloads, scrolls, and engagement."),
            ("Downloads", "Download-related events.", "Use to judge whether users are getting files or documents."),
            ("Events/session", "Average event depth per session.", "Use as a compact engagement indicator."),
            ("Scrolled", "Users who triggered scroll tracking.", "Use to see if visitors are moving beyond the first screen."),
            ("Active now", "Realtime active users.", "Use as a live pulse, not a historical total."),
        ],
    )
    paragraph(
        doc,
        "For a quiet website, daily numbers can be small. That is not a failure. The value of the dashboard is that it makes small numbers readable, "
        "keeps the complete rows visible, and avoids GA4's habit of hiding most values behind limited tables and side-scrolling panels."
    )

    doc.add_heading("15. Date Ranges and All-Websites Mode", level=1)
    paragraph(
        doc,
        "The selected date range controls most historical panels. Today is useful for checking whether the site is alive right now. "
        "Last 7 days is good for a short trend. Last 28 days gives a month-like operational view. Last 90 days is better for slow-moving sites where one week may not show enough activity."
    )
    paragraph(
        doc,
        "All websites mode combines enabled properties. This is useful for a broad operational view, but it can also make labels less specific because the same page path or event name may exist on more than one website. "
        "For investigation, switch back to one property at a time. Individual property review is usually clearer when you want to know exactly which website produced a row."
    )
    bullets(
        doc,
        [
            "Use Today to verify new tracking changes or a current visitor.",
            "Use Last 7 days to see whether traffic changed this week.",
            "Use Last 28 or Last 90 days to reduce noise on low-traffic sites.",
            "Use All websites for a quick roll-up, then switch to individual properties for detail.",
        ],
    )

    doc.add_heading("16. Google OAuth Walkthrough", level=1)
    paragraph(
        doc,
        "Google OAuth is the part of the setup that feels the least obvious at first. The important idea is that the desktop app does not use your email address as a client ID. "
        "The app needs a Google Cloud Desktop OAuth client. That client gives you a client ID and often a client secret. Those two values identify the desktop app during Google's authorization flow."
    )
    numbered(
        doc,
        [
            "Open Google Cloud Console and select or create a project for this desktop dashboard.",
            "Enable the Google Analytics Data API in that project.",
            "Configure the OAuth consent screen. While testing, add your Google account as a test user.",
            "Create an OAuth Client ID with application type Desktop app.",
            "Copy the generated client ID and client secret into Settings.",
            "Use Connect Google from Settings. Google opens in the browser, you approve access, and the browser returns to the app's local redirect URI.",
            "After success, the refresh token is encrypted locally and future launches should reconnect silently.",
        ],
    )
    paragraph(
        doc,
        "If you later publish the project publicly, each user should create their own OAuth client. Do not publish your client secret or local database. "
        "For wide public distribution, Google app verification may be required so users do not see unverified-app warnings."
    )

    doc.add_heading("17. Public/Open-Source User Notes", level=1)
    paragraph(
        doc,
        "A public copy of this project should not include the developer's SQLite database, OAuth secret, refresh token, property IDs, or personal screenshots. "
        "Each user cloning the repository should create their own Google Cloud OAuth desktop client, add their own GA4 property IDs, and let the app create a local settings database at startup."
    )
    simple_table(
        doc,
        ["Public repo item", "Should it be included?", "Reason"],
        [
            ("Source code and forms", "Yes", "Needed to build and inspect the app."),
            ("Help and guides", "Yes", "Needed for users and developers."),
            ("Schema SQL", "Yes", "Allows fresh database creation."),
            ("Real .sqlite3 database", "No", "Can contain settings, property IDs, and tokens."),
            ("OAuth client secret", "No", "Credential material."),
            ("Refresh token", "No", "Account authorization material."),
            ("Real screenshots with private data", "No", "Can reveal property IDs, locations, account details, and usage."),
        ],
    )

    doc.add_heading("18. Daily Operating Checklist", level=1)
    bullets(
        doc,
        [
            "Open the app and confirm the status shows Connected.",
            "Choose the property you want to review.",
            "Choose the date range that matches the question you are asking.",
            "Check the cards first for the quick story.",
            "Check the users graph for spikes or drop-offs.",
            "Check locations to see where visitors came from.",
            "Check pages/downloads to see what they used.",
            "Check realtime if you are actively testing or watching a current visitor.",
            "Leave Auto 60 sec enabled if you want the dashboard to run continuously.",
        ],
    )
    doc.save(GUIDES / "WebsiteAnalytics_User_Guide.docx")


def build_engineering_guide() -> None:
    doc = Document()
    setup_doc(
        doc,
        "Website Analytics Engineering Guide",
        "Implementation, maintenance, build, and public-repository notes",
    )
    doc.add_heading("1. Engineering Purpose", level=1)
    paragraph(
        doc,
        "This project is a Delphi FMX desktop application that retrieves selected GA4 data, formats it into in-memory models, and displays it in a clean dashboard. "
        "The engineering goal is not to clone GA4. The goal is to make the highest-value website analytics easier to read, while keeping forms editable in RAD Studio and keeping local storage minimal."
    )
    figure(doc, "dashboard", "Actual dashboard screenshot with private report rows redacted.", 6.6)

    doc.add_heading("2. Project Structure", level=1)
    simple_table(
        doc,
        ["Folder/file", "Role"],
        [
            ("WebsiteAnalytics.dpr / .dproj", "Application entry point and RAD Studio project file."),
            ("WebsiteAnalytics.MainForm.pas/.fmx", "Main dashboard form, hero controls, charts, grids, and realtime display."),
            ("WebsiteAnalytics.SettingsForm.pas/.fmx", "Settings and Google sign-in UI."),
            ("WebsiteAnalytics.PropertyManagerForm.pas/.fmx", "Manage website/GA4 property definitions."),
            ("WebsiteAnalytics.GA4DataModule.pas", "Builds GA4 API requests, executes HTTP calls, parses report responses."),
            ("WebsiteAnalytics.AuthenticationDataModule.pas", "Handles desktop OAuth, loopback redirect, access token, and refresh token logic."),
            ("WebsiteAnalytics.SettingsDataModule.pas", "SQLite-backed settings and schema management."),
            ("WebsiteAnalytics.Models.pas", "Memory model types for snapshots, KPI summaries, trend points, content rows, and location rows."),
            ("help", "Local HTML help used by the Help button."),
            ("docs/guides and docs/pdf", "Editable guides and companion PDF output."),
        ],
    )

    doc.add_heading("3. Design Directives for Future Work", level=1)
    bullets(
        doc,
        [
            "Forms should remain editable in the RAD Studio IDE.",
            "Avoid runtime-only UI construction unless it is unavoidable and approved.",
            "Do not add helper code unless the developer approves it.",
            "Prefer Object Inspector settings for layout where practical.",
            "Make a pre-change backup on D: before modifying project files.",
            "After approved changes are validated, commit and push both the private and public repositories.",
        ],
    )

    doc.add_heading("4. Data Flow", level=1)
    numbered(
        doc,
        [
            "The user selects a property and date range in the main form.",
            "The main form requests an access token from the authentication data module.",
            "The GA4 data module builds runReport or realtime report JSON requests.",
            "HTTP responses are parsed into in-memory model objects.",
            "The main form updates existing FMX controls: cards, grids, chart paint boxes, and realtime labels.",
            "The report snapshot remains in memory and is discarded when the app closes.",
        ],
    )

    doc.add_heading("5. GA4 Report Responsibilities", level=1)
    simple_table(
        doc,
        ["Report area", "GA4 data used", "Displayed as"],
        [
            ("Summary cards", "Users, views, downloads/events, active users, realtime views, events/session, scrolled users", "Ten compact cards."),
            ("Locations", "Country, region, city, users, sessions, engagement", "Alphabetized grid."),
            ("Pages/downloads", "Page title, path, event/action, users, event/download counts", "Bar chart and supporting data logic."),
            ("Users trend", "Daily users over selected date range", "Bar graph with tooltip."),
            ("Realtime", "Active users and realtime location/activity dimensions", "Realtime panel."),
        ],
    )
    figure(doc, "cards", "Actual summary-card area used to expose high-value GA4 metrics.", 5.8)

    doc.add_heading("6. Authentication and Refresh Tokens", level=1)
    paragraph(
        doc,
        "The app uses Google desktop OAuth. The browser sign-in returns to a loopback redirect URI. The app exchanges the authorization code for tokens. "
        "The access token is held in memory. The refresh token is encrypted with Windows DPAPI and saved in the SQLite settings database so startup can reconnect silently."
    )
    figure(doc, "settings", "Actual settings area with credentials and status redacted.", 6.3)
    bullets(
        doc,
        [
            "The OAuth client ID and secret belong to the user's own Google Cloud desktop OAuth client.",
            "The saved refresh token should never be committed or included in a public release.",
            "Disconnect clears the access token and saved encrypted refresh token.",
            "Silent reconnect should be attempted before showing Google login screens.",
        ],
    )

    doc.add_heading("7. All-Websites Merge Behavior", level=1)
    paragraph(
        doc,
        "All-websites mode is not a separate GA4 property. It is an application-level merge across enabled properties. "
        "The app requests each enabled property, aggregates compatible metrics, and then updates the same dashboard controls. "
        "This makes the dashboard useful for a broad roll-up, but it also means labels such as Home or /downloads.html may represent the same path on more than one site."
    )
    bullets(
        doc,
        [
            "Additive metrics such as users, sessions, views, events, downloads, and scrolled users can be summed carefully.",
            "Ratio metrics such as engagement rate and events/session should be recomputed or weighted, not blindly summed.",
            "Trend points should be merged by date so the chart remains aligned to the selected range.",
            "Content rows should be grouped by meaningful keys such as page title, path, and event/action.",
            "Realtime all-sites data can be more expensive and potentially more confusing; individual property view is usually clearer.",
        ],
    )

    doc.add_heading("8. SQLite Storage Model", level=1)
    paragraph(
        doc,
        "SQLite is used for portable settings, not analytics warehousing. The local database may live beside the source or executable according to the current project setup. "
        "The schema SQL is tracked so a fresh database can be created, but real .sqlite3 files should be ignored by Git."
    )
    simple_table(
        doc,
        ["Data category", "Stored?", "Reason"],
        [
            ("Default website/date range", "Yes", "User preference."),
            ("Property definitions", "Yes", "Needed to query GA4 properties."),
            ("Grid widths", "Yes", "Preserve user's manual column adjustments."),
            ("OAuth client setup", "Yes", "Needed for token exchange."),
            ("Encrypted refresh token", "Yes", "Enables silent reconnect."),
            ("GA4 report rows", "No", "Memory-only design."),
        ],
    )

    doc.add_heading("9. UI Implementation Notes", level=1)
    paragraph(
        doc,
        "The main form is intentionally a real FMX form rather than a runtime-built dashboard. Chart painting and data updates are runtime behavior, but control existence, general layout, captions, and editable form structure belong in the designer whenever possible."
    )
    bullets(
        doc,
        [
            "The bar charts are painted in paint boxes from in-memory trend/top-page data.",
            "Tooltips are compact overlays for exact chart values.",
            "The grids use FMX string grids and saved column widths.",
            "Property/date selection and tab changes should trigger appropriate data refresh behavior.",
            "Avoid code that silently resizes or rebuilds controls unless explicitly approved.",
        ],
    )
    figure(doc, "graph", "Actual users graph showing a selected date range.", 6.3)

    doc.add_heading("10. GA4 Request and Parser Notes", level=1)
    paragraph(
        doc,
        "GA4 responses must be parsed defensively. Some successful responses contain no rows. Some dimensions return (not set). "
        "Realtime responses may return fewer dimensions than standard runReport responses. The code should treat missing rows as no data rather than as a fatal parser failure."
    )
    simple_table(
        doc,
        ["Condition", "Expected engineering behavior"],
        [
            ("No rows", "Clear the relevant model list and display zero/None/no rows gracefully."),
            ("Missing rows member", "Treat as empty rather than throwing a user-facing parser error."),
            ("Wrong property ID", "Show the GA4 HTTP error clearly."),
            ("Permission denied", "Show enough of the 403 message to guide the user to GA4 Admin access/property ID checks."),
            ("Token expired", "Attempt one refresh/retry before asking the user to reconnect."),
            ("Realtime location missing", "Show None or Current location: None rather than stale location text."),
        ],
    )

    doc.add_heading("11. Build and Smoke Test", level=1)
    numbered(
        doc,
        [
            "Run the RAD Studio environment setup from C:\\Program Files (x86)\\Embarcadero\\Studio\\37.0\\bin\\rsvars.bat.",
            "Build Win64 Debug with MSBuild.",
            "Build Win32 Debug with MSBuild.",
            "Start the executable briefly with startup authentication disabled when appropriate to catch FMX read errors.",
            "If the executable is locked, close any running WebsiteAnalytics.exe process and rebuild.",
        ],
    )

    doc.add_heading("12. Release and Repository Checklist", level=1)
    numbered(
        doc,
        [
            "Run a private-info scan against documents, help, source text, and tracked configuration files.",
            "Verify .gitignore excludes databases/*.sqlite3 and other local credential material.",
            "Build Win64 and Win32.",
            "Start the app and confirm the main form loads without FMX property/read errors.",
            "Verify help opens from the Help button.",
            "Confirm User Guide and Engineering Guide exist as both DOCX and PDF.",
            "Review git status and stage only intended files.",
            "Commit the private repository.",
            "Mirror safe files to the public repository.",
            "Commit and push the public repository.",
        ],
    )

    doc.add_heading("13. Public Repository Hygiene", level=1)
    bullets(
        doc,
        [
            "Never commit real SQLite databases.",
            "Never commit OAuth secrets, refresh tokens, credential JSON files, PEM files, or .env files.",
            "Never commit screenshots that show private property IDs, personal locations, or developer-only data.",
            "Use sanitized real screenshots in documentation.",
            "Track schema SQL, source, help, guides, and safe image/icon assets.",
            "Keep private and public repos synchronized only after reviewing the diff for secrets.",
        ],
    )
    figure(doc, "properties", "Actual property-management screen with site names and IDs redacted.", 6.1)

    doc.add_heading("14. Documentation Maintenance", level=1)
    paragraph(
        doc,
        "Documentation should be rebuilt from actual UI captures and source behavior. Do not use synthetic mockups as screenshots. If an image is cropped from the UI, redact only the private values. The screenshot should still look like the real application."
    )
    bullets(
        doc,
        [
            "User Guide: friendly, procedural, and explanatory.",
            "Engineering Guide: implementation details, architecture, build process, and safety rules.",
            "Help: concise but complete local help, with useful cropped screenshots per topic.",
            "All public screenshots: no personal city, account email, OAuth values, property IDs, or private paths.",
        ],
    )

    doc.add_heading("15. Maintenance Risk Areas", level=1)
    simple_table(
        doc,
        ["Area", "Risk", "Mitigation"],
        [
            ("OAuth", "Google policy or consent-screen changes can alter the login experience.", "Keep setup docs current and test first-run flow periodically."),
            ("GA4 API", "Metric/dimension names can change or behave differently.", "Prefer official GA4 API docs and fail gracefully on missing rows."),
            ("FMX grids", "Rendering quirks can appear at different sizes/DPI.", "Avoid unnecessary grid-control churn; test visual changes at common resolutions."),
            ("Public docs", "Screenshots can accidentally reveal private data.", "Use actual screenshots, crop to the area discussed, and redact private fields before committing."),
            ("All-sites merge", "Ratios and duplicate labels can mislead.", "Document what is merged and prefer individual property view for diagnosis."),
        ],
    )

    doc.add_heading("16. Known Limitations and Future Work", level=1)
    bullets(
        doc,
        [
            "GA4 realtime data and standard reports can disagree briefly because they are separate GA4 reporting surfaces.",
            "Some GA4 dimensions may return (not set). The app should display those rows rather than hiding them.",
            "The current grid control can have minor FMX rendering quirks. Replacing it should be considered only if the benefit is worth the disruption.",
            "CSV export, saved report snapshots, and additional graphs are possible future enhancements, but they would change the current memory-only philosophy.",
        ],
    )
    doc.save(GUIDES / "WebsiteAnalytics_Engineering_Guide.docx")


HELP_TOPICS = {
    "overview.html": (
        "Overview",
        "dashboard",
        "Website Analytics is a focused GA4 desktop dashboard. It retrieves selected data through GA4 APIs, keeps report rows in memory, and presents the information in practical panels instead of GA4's busier web interface.",
        [
            "Use the dashboard to answer who visited, where they came from, what they used, how users changed over the selected range, and what is happening now.",
            "Report rows are memory-only and are discarded when the app closes.",
            "Settings and property definitions are stored locally.",
        ],
    ),
    "quick-start.html": (
        "Quick Start",
        "settings",
        "First setup connects your own Google OAuth desktop client and your own GA4 properties.",
        [
            "Enter your OAuth desktop client ID and client secret in Settings.",
            "Use the numeric GA4 property ID in Properties.",
            "Click Connect Google once, complete browser sign-in, then return to the app and update.",
            "After first sign-in, startup should reconnect silently if the encrypted refresh token is still valid.",
        ],
    ),
    "dashboard-tour.html": (
        "Dashboard Tour",
        "dashboard",
        "The dashboard is organized into real work areas: controls at the top, data lookup on the left, trend/realtime on the right.",
        [
            "The hero area holds property selection, date range, auto-update, status, Update, Settings, and Help.",
            "The upper-left grid shows locations.",
            "The lower-left area shows pages, downloads, and actions.",
            "The upper-right graph shows users over the selected range.",
            "The lower-right panel shows realtime status.",
        ],
    ),
    "website-date-filters.html": (
        "Website and Date Filters",
        "hero",
        "The website selector controls which GA4 property is queried. The date range controls historical report data and charts.",
        [
            "Individual properties are usually clearest for review.",
            "All websites combines enabled properties when you want a broad view.",
            "Auto 60 sec refreshes the dashboard while the app is running.",
        ],
    ),
    "trend-graph.html": (
        "Users Graph",
        "graph",
        "The users graph shows the selected date range as readable bars.",
        [
            "The graph starts at zero and uses whole-number scale labels.",
            "Hover over a bar to see the exact value.",
            "The title includes the date span so you know what you are looking at.",
        ],
    ),
    "locations.html": (
        "Visitor Locations",
        "locations",
        "The location grid groups visitors by country, region/state, and city.",
        [
            "Rows are sorted alphabetically for easier lookup.",
            "GA4 may return (not set) when it cannot resolve a dimension.",
            "Users and sessions are separate GA4 metrics and may differ.",
        ],
    ),
    "pages-actions.html": (
        "Pages, Downloads, and Actions",
        "pages",
        "The pages/downloads area shows what visitors used during the selected date range.",
        [
            "Page title and path identify the content.",
            "Action/Event distinguishes page views, downloads, scrolls, clicks, and engagement events.",
            "Download counts depend on GA4 receiving download events from the website.",
        ],
    ),
    "realtime.html": (
        "Realtime Activity",
        "realtime",
        "Realtime shows current active visitors and current/last activity information when GA4 returns it.",
        [
            "Realtime data can differ from standard reports because it comes from a different GA4 endpoint.",
            "Location is shown only when GA4 returns usable location data.",
            "Last activity resets when the selected property changes.",
        ],
    ),
    "properties.html": (
        "Managing Properties",
        "properties",
        "Properties define which websites the dashboard can query.",
        [
            "Use the numeric GA4 property ID.",
            "Do not use the G- measurement ID or Google Cloud project number.",
            "Disable properties you do not want in the dashboard selector.",
        ],
    ),
    "settings-and-google.html": (
        "Settings and Google Sign-in",
        "settings",
        "Settings store dashboard defaults and Google OAuth desktop client values.",
        [
            "The OAuth client ID and secret are not your Gmail address.",
            "The client secret is hidden by default in the UI.",
            "The refresh token is encrypted with Windows DPAPI.",
            "Disconnect clears the current token and saved refresh token.",
        ],
    ),
    "long-running-dashboard.html": (
        "Running the Dashboard All Day",
        "cards",
        "The app is designed to sit open as a glanceable dashboard.",
        [
            "Leave Auto 60 sec enabled for periodic refreshes.",
            "Use Update when you want an immediate refresh.",
            "If authentication cannot refresh silently, open Settings and reconnect Google.",
        ],
    ),
    "diagnostics.html": (
        "Diagnostics",
        "settings",
        "Diagnostics help explain authentication, setup, request, and parser problems.",
        [
            "Use Diagnostics when Update fails or data looks suspicious.",
            "Check the selected property, authentication state, and last GA4 status.",
            "Permission errors usually mean the signed-in Google account or property ID is wrong.",
        ],
    ),
    "troubleshooting.html": (
        "Troubleshooting",
        "dashboard",
        "Most problems are setup, permission, token, or date-range issues.",
        [
            "If rows are empty, try a wider date range and compare with GA4.",
            "If downloads are zero, confirm the website emits download events.",
            "If Google login repeats, reconnect and verify that token storage is working.",
            "If a public repo is used, each user must provide their own OAuth client and GA4 properties.",
        ],
    ),
    "privacy-storage.html": (
        "Privacy and Storage",
        "settings",
        "The app stores settings but does not store fetched analytics report rows.",
        [
            "Settings and property definitions are stored in SQLite.",
            "The refresh token is encrypted for the current Windows user.",
            "GA4 report rows are memory-only.",
            "Do not commit real databases, OAuth secrets, tokens, or private screenshots.",
        ],
    ),
}


def html_topic(title: str, asset_key: str, intro: str, points: list[str]) -> str:
    lis = "".join(f"<li>{p}</li>" for p in points)
    img = ASSET_FILES[asset_key]
    return f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <title>{title}</title>
  <link rel="stylesheet" href="../style.css">
</head>
<body class="topic-body">
<main class="topic">
<h1>{title}</h1>
<figure><img src="../assets/{img}" alt="{title}"><figcaption>Actual application screenshot, cropped and sanitized.</figcaption></figure>
<p>{intro}</p>
<ul>{lis}</ul>
</main>
</body>
</html>
"""


def build_help() -> None:
    HELP.mkdir(parents=True, exist_ok=True)
    (HELP / "topics").mkdir(parents=True, exist_ok=True)
    HELP_ASSETS.mkdir(parents=True, exist_ok=True)
    for key, name in ASSET_FILES.items():
        src = ASSETS / name
        if src.exists():
            (HELP_ASSETS / name).write_bytes(src.read_bytes())

    css = """
:root { --navy:#0b2341; --blue:#1974df; --accent:#38bdf8; --ink:#0f172a; --muted:#64748b; --page:#f7fbff; --line:#cfe1f4; }
body { margin:0; font-family: Segoe UI, Arial, sans-serif; color:var(--ink); background:var(--page); }
.help-shell { display:grid; grid-template-columns:330px 1fr; height:100vh; }
aside { background:linear-gradient(180deg,#ffffff 0%,#eaf8ff 100%); padding:18px; overflow:auto; border-right:1px solid var(--line); }
aside h1 { margin:0 0 4px; color:var(--navy); font-size:24px; }
.help-subtitle { color:var(--muted); margin:0 0 14px; font-size:13px; }
.shell-search input { width:100%; box-sizing:border-box; padding:10px; border-radius:10px; border:1px solid var(--line); }
.shell-links { display:flex; gap:8px; flex-wrap:wrap; margin:12px 0; }
.shell-links a, nav a { text-decoration:none; color:var(--navy); }
.shell-links a { background:white; border:1px solid var(--line); border-radius:10px; padding:7px 9px; }
nav ul { list-style:none; padding:0; margin:12px 0 0; }
nav li { margin:7px 0; }
nav a { display:block; padding:10px 11px; border-radius:12px; background:white; border:1px solid var(--line); font-weight:650; box-shadow:0 2px 8px rgba(15,23,42,.05); }
nav a.active, nav a:hover { background:var(--accent); color:#06111f; }
.topic-frame { background:#eaf8ff; padding:14px; }
iframe { width:100%; height:calc(100vh - 28px); border:1px solid var(--line); border-radius:16px; background:white; }
.topic { max-width:1040px; margin:0 auto; padding:32px 38px 60px; }
.topic h1 { color:var(--navy); border-bottom:4px solid var(--accent); padding-bottom:9px; margin-top:0; font-size:32px; }
.topic p, .topic li { font-size:16px; line-height:1.58; }
.topic li { margin-bottom:8px; }
figure { margin:18px 0 26px; border:1px solid var(--line); border-radius:16px; padding:12px; background:white; box-shadow:0 10px 28px rgba(15,23,42,.10); }
figure img { display:block; max-width:100%; height:auto; border-radius:10px; margin:0 auto; }
figcaption { color:var(--muted); font-size:13px; padding-top:8px; text-align:center; }
#searchResults a, #searchResults span { display:block; padding:6px 2px; color:var(--blue); }
.print-topic { page-break-after:always; }
@media print { .topic { max-width:none; padding:24px; } figure { box-shadow:none; } }
"""
    (HELP / "style.css").write_text(css, encoding="utf-8")

    toc = []
    search = []
    for filename, (title, asset_key, intro, points) in HELP_TOPICS.items():
        (HELP / "topics" / filename).write_text(html_topic(title, asset_key, intro, points), encoding="utf-8")
        toc.append({"title": title, "url": f"topics/{filename}", "status": "Approved", "owner": "Website Analytics"})
        search.append({"title": title, "url": f"topics/{filename}", "text": f"{title} {intro} {' '.join(points)}"})
    (HELP / "toc.json").write_text(json.dumps(toc, indent=2), encoding="utf-8")
    (HELP / "search-index.json").write_text(json.dumps(search, indent=2), encoding="utf-8")
    (HELP / "metadata.json").write_text(json.dumps({"lastChanged": TODAY, "generator": "tools/refresh_websiteanalytics_docs.py"}, indent=2), encoding="utf-8")
    (HELP / "WebsiteAnalytics Help.hdc.json").write_text(json.dumps({"name": "Website Analytics Help", "outputPath": "help", "lastChanged": TODAY, "topics": toc}, indent=2), encoding="utf-8")

    nav = "".join(
        f"<li><a href=\"{item['url']}\" target=\"topicFrame\" data-topic-url=\"{item['url']}\" "
        f"onclick=\"setActiveTopic(this.getAttribute('data-topic-url'))\">{item['title']}</a></li>"
        for item in toc
    )
    index = f"""<!doctype html>
<html lang="en"><head><meta charset="utf-8"><title>Website Analytics Help</title><link rel="stylesheet" href="style.css"></head>
<body class="help-shell"><aside><h1>Website Analytics Help</h1><p class="help-subtitle">Friendly local help for the GA4 desktop dashboard.</p>
<div class="shell-search"><input id="searchBox" placeholder="Search help" oninput="runSearch()"><div id="searchResults"></div></div>
<div class="shell-links"><a href="manual-print.html" target="topicFrame">Print view</a><a href="keyword-index.html" target="topicFrame">Index</a><a href="glossary.html" target="topicFrame">Glossary</a></div>
<nav><ul>{nav}</ul></nav></aside><section class="topic-frame"><iframe id="topicFrame" name="topicFrame" src="topics/overview.html" title="Help topic"></iframe></section>
<script>
var searchItems = {json.dumps(search)};
function cleanTopicUrl(url) {{ url=String(url||'').split('#')[0].split('?')[0].replace(/\\\\/g,'/'); var i=url.lastIndexOf('topics/'); if(i>=0) return url.substring(i); var p=url.lastIndexOf('/'); if(p>=0) return 'topics/'+url.substring(p+1); return url; }}
function clearActiveTopic() {{ document.querySelectorAll('nav a.active').forEach(function(a){{a.classList.remove('active');}}); }}
function setActiveTopic(url) {{ var wanted=cleanTopicUrl(url); clearActiveTopic(); document.querySelectorAll('nav a[data-topic-url]').forEach(function(a){{ if(cleanTopicUrl(a.getAttribute('href'))===wanted){{ a.classList.add('active'); a.scrollIntoView({{block:'nearest'}}); }} }}); }}
function runSearch() {{ var q=document.getElementById('searchBox').value.toLowerCase(); var r=document.getElementById('searchResults'); if(!q){{r.innerHTML='';return;}} var h=''; searchItems.filter(function(x){{return (x.title+' '+x.text).toLowerCase().indexOf(q)>=0;}}).slice(0,20).forEach(function(x){{h+='<a target="topicFrame" href="'+x.url+'" onclick="setActiveTopic(\\''+x.url+'\\')">'+x.title+'</a>';}}); r.innerHTML=h||'<span>No matches</span>'; }}
document.getElementById('topicFrame').addEventListener('load', function(){{try{{setActiveTopic(this.contentWindow.location.href||this.contentWindow.location.pathname);}}catch(e){{}}}});
setActiveTopic('topics/overview.html');
</script></body></html>"""
    (HELP / "index.html").write_text(index, encoding="utf-8")

    manual = ['<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Website Analytics Help Manual</title><link rel="stylesheet" href="style.css"></head><body class="topic-body">']
    for filename in HELP_TOPICS:
        content = (HELP / "topics" / filename).read_text(encoding="utf-8")
        start = content.index('<main class="topic">') + len('<main class="topic">')
        end = content.index("</main>")
        manual.append(f'<section class="topic print-topic">{content[start:end]}</section>')
    manual.append("</body></html>")
    (HELP / "manual-print.html").write_text("\n".join(manual), encoding="utf-8")


def main() -> None:
    GUIDES.mkdir(parents=True, exist_ok=True)
    PDFS.mkdir(parents=True, exist_ok=True)
    build_user_guide()
    build_engineering_guide()
    build_help()


if __name__ == "__main__":
    main()
