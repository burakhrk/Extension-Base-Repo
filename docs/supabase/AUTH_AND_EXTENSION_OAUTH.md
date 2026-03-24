# Auth and Chrome Extension OAuth

## Recommended auth method

Use Supabase Auth with Google provider and Chrome-extension-compatible OAuth flow:

- `chrome.identity.getRedirectURL()`
- `chrome.identity.launchWebAuthFlow(...)`
- `supabase.auth.exchangeCodeForSession(code)`

## Important requirements

- `manifest.json` must include `identity` permission
- Supabase redirect allowlist must include the extension callback URL
- production and local unpacked extension IDs may differ
- add dev and prod callback URLs separately when needed

## Session persistence

Use a Supabase storage adapter backed by:

- `chrome.storage.local`

This is the safest shared storage for popup, dashboard/options, and background contexts.
