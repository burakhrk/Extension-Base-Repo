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

## What not to collect

Do not collect:

- message content
- drawing payloads
- raw canvas/image data
- private freeform content

Use interaction telemetry only.
