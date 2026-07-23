# Website Analytics Roadmap

Last changed: July 22, 2026

This roadmap records likely future reporting ideas for Website Analytics. The goal is to keep the app useful to website owners anywhere in the world, not only users in the United States.

## Guiding principles

- Keep analytics report data memory-only unless a future feature explicitly adds export/history.
- Keep the dashboard easy to understand at a glance.
- Prefer full useful lists over GA4-style short previews.
- Use worldwide wording such as "region/state" instead of assuming every visitor is in a U.S. state.
- Avoid country-specific assumptions. The current location grid should remain useful for U.S. and international visitors.
- Add reporting areas incrementally so each new quadrant or dialog can be tested and understood.

## High-priority reporting additions

### 1. Realtime: visitors in the last 30 minutes

This should be treated as a high-priority realtime improvement.

Possible realtime panel additions:

- active users now
- visitors in the last 30 minutes
- views in the last 30 minutes
- top pages in the last 30 minutes
- countries, regions, and cities active in the last 30 minutes, where GA4 provides them
- downloads/events in the last 30 minutes, where GA4 provides them

Why it matters:

- It supports the intended use of leaving the app open all day.
- It is immediately understandable to non-technical users.
- It answers whether the site is active right now.
- It works for users worldwide.

### 2. Traffic Sources

Show how visitors found the selected website.

Useful fields:

- source
- medium
- campaign
- users
- sessions
- engagement rate

Example questions answered:

- Did visitors come from Google, Bing, GitHub, direct traffic, or another website?
- Are visitors finding the site through search, referral links, or direct access?

### 3. Devices / Browsers

Show what visitors are using to browse the site.

Useful fields:

- device category, such as desktop, mobile, or tablet
- browser
- operating system
- users
- sessions

Why it matters:

- It is useful worldwide because visitors may use many devices, browsers, and operating systems.
- It can influence UI/layout testing and website compatibility decisions.

### 4. Languages

Show visitor browser language or locale information where GA4 provides it.

Useful fields:

- language
- users
- sessions
- engagement rate

Why it matters:

- It helps decide whether translation support or localized documentation would be useful.
- It avoids assuming every visitor reads English.

### 5. Downloads / Events

Promote download and event reporting beyond the current Pages/actions filtering when GA4 provides useful event rows.

Useful fields:

- event name
- page path
- page title
- file name or link text, if GA4 provides it
- event count
- users

Why it matters:

- Downloads, clicks, and outbound events are often more important than raw page views.
- It helps project owners understand whether visitors are taking useful actions.

### 6. Data Quality

Show whether GA4 returned complete, partial, or messy data.

Useful indicators:

- number of "(not set)" country rows
- number of "(not set)" region/state rows
- number of "(not set)" city rows
- number of "(not set)" page titles
- no-row responses
- GA4 permission/API errors
- realtime zero-user conditions

Why it matters:

- It helps users know whether the app is wrong or GA4 simply returned limited data.
- It is especially useful for public/open-source users who are configuring their own properties.

## Worldwide presentation notes

- Keep Countries/Regions/Cities as first-class worldwide location data.
- Keep U.S. city/state formatting useful, but do not make the overall app feel U.S.-only.
- Prefer "Region / State" or "Region/State" labels where space allows.
- Consider locale-aware date and number formatting later.
- Consider ISO-style date display options, such as `2026-07-20`, for users who prefer unambiguous international dates.
- Avoid hard-coded currency unless a future reporting feature actually needs it.

## Lower-priority ideas

- world map or region summary visualization
- previous-period comparison line on the trend graph
- export or print-friendly report views
- stronger visual highlighting for downloads and outbound events
- first-run setup wizard for public/open-source users
