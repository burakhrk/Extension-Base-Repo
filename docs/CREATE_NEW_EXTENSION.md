# Create New Extension

Use this when starting a brand-new extension from this base repo.

## 1. Product identity

- choose extension name
- choose route slug
- choose permanent `APP_ID`
- choose icon set
- choose support email or support path

Recommended:

- route slug example: `drawing-office`
- `APP_ID` example: `drawing-office`

Do not rename `APP_ID` later unless absolutely necessary.

## 2. Repo setup

- copy the starter from `templates/chrome-extension-supabase-vite`
- create a fresh extension repo
- move only the files you actually need
- keep this base repo as reference, not as a live dependency
- align the repo to [docs/REPO_STRUCTURE.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/REPO_STRUCTURE.md)

## 3. Supabase

- confirm the shared Supabase project is the intended one
- make sure the multi-app migration has already been applied
- insert a row into `public.apps` for the new extension
- confirm the new `APP_ID` exists in `public.apps`

Example:

```sql
insert into public.apps (id, name, is_active)
values ('drawing-office', 'Drawing Office', true)
on conflict (id) do update
set name = excluded.name,
    is_active = excluded.is_active,
    updated_at = timezone('utc', now());
```

## 4. Auth

- enable Google provider in Supabase Auth
- confirm Chrome extension redirect URL is allowlisted
- add `identity` permission in `manifest.json`
- use `chrome.identity.launchWebAuthFlow`
- persist Supabase session in `chrome.storage.local`

## 5. Env vars

If using Vite:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

Optional depending on the project:

- `VITE_API_URL`
- `VITE_PUBLIC_SITE_URL`

## 6. Bootstrap flow

On extension start:

1. restore auth session
2. get authenticated user
3. if signed in, call `get_social_state(APP_ID)`
4. hydrate UI
5. only update preferences when the user intentionally changes them

## 7. Analytics

Set the minimum event set:

- `Extension Installed`
- `Signed In`
- `Signed Out`
- `Loaded Social State`
- `Updated Preferences`
- `Opened Paywall`
- `Opened Website Pricing`

Add product-specific events only after the shared baseline is in place.

## 8. Website

- add the extension to the public hub site config
- create separate routes for:
  - overview
  - login
  - pricing
  - payment
  - privacy
  - terms
  - support
  - leave / uninstall feedback
- avoid mixing product copy with other extensions

## 9. Billing provider

If the extension uses Patreon-based tiers:

- keep app identity anchored to the extension account first
- do not treat Patreon as the only identity system unless the whole product is built that way
- prefer:
  - extension / website sign-in
  - then explicit `Connect Patreon`
  - then membership entitlement sync

Recommended backend envs for a Patreon-aware worker:

- `PATREON_CLIENT_ID`
- `PATREON_CLIENT_SECRET`
- `PATREON_REDIRECT_URI`
- `PATREON_APP_CONFIG_JSON`
- `PUBLIC_SITE_URL`

Recommended pattern for multi-extension Patreon billing:

- one mapping object keyed by `APP_ID`
- each app maps to its own Patreon package / tier IDs
- backend state stays scoped by `appId + accountId`
- one user can be Pro in one extension and free in another

## 10. Marketing starter kit

- copy `extension-marketing-kit` into the real extension repo if needed
- replace sample scenarios, colors, and texts
- regenerate screenshots and clips with product-specific scenarios

## 11. Final checks before real development

- `APP_ID` is fixed
- auth redirect works
- Supabase session persists
- `get_social_state(APP_ID)` returns successfully
- analytics helper is wired
- website route exists
- standard folders like `public/icons`, `scripts`, and `store-assets` exist
- support/legal placeholders are replaced if the product is going public
