# Analytics Guide

Recommended baseline events for new extensions:

- `Extension Installed`
- `Signed In`
- `Signed Out`
- `Loaded Social State`
- `Sent Friend Request`
- `Accepted Friend Request`
- `Rejected Friend Request`
- `Started Session`
- `Ended Session`
- `Updated Preferences`
- `Opened Paywall`
- `Opened Website Pricing`

Recommended shared properties:

- `appId`
- `screen`
- `surface`
- `result`
- `mode`
- `targetUserId` when relevant

## Multi-app isolation rule

If multiple extensions share the same Supabase project or analytics storage:

- every event must include the extension `appId`
- every admin analytics query must also carry the target `appId`
- dashboards must filter by `appId` before rendering summaries, events, funnels, or user lists
- never show mixed events from different extensions in one shared panel by default

The safe default is:

- one extension selected
- one `appId` loaded
- one isolated analytics response rendered

## Recommended admin analytics contract

If an extension exposes admin analytics over HTTP, prefer this contract:

- endpoint:
  - `GET /api/admin/analytics?appId={appId}`
- required header:
  - `x-admin-passcode`
- recommended extra header:
  - `x-extension-app-id`

Recommended response fields:

- `appId`
- `summary`
- `aiUsage`
- `funnels`
- `topEvents`
- `screenCounts`
- `recentEvents`
- `uninstallFeedback`

And for item-level safety:

- each event record should also include `appId`
- each uninstall feedback record should also include `appId`

## What not to collect

Do not collect:

- message content
- drawing payloads
- raw canvas/image data
- private freeform content

Use interaction telemetry only.
