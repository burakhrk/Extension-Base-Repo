# Repo Structure

Use this as the default layout for new extension repos that start from this base.

## Philosophy

- keep source code predictable
- keep generated artifacts in known places
- keep marketing material separate from runtime code
- keep `starter` folders copyable and familiar across extensions

## Recommended structure

```text
your-extension/
|- docs/
|- public/
|  \- icons/
|- src/
|  |- background/
|  |- content/
|  |- dashboard/
|  |- popup/
|  |- lib/
|  |- types/
|  \- example/
|- scripts/
|- store-assets/
|  |- screenshots/
|  |- promo/
|  |- video-clips/
|  \- icons-export/
|- dist/
|- package.json
|- manifest.json
\- vite.config.ts
```

## Folder rules

### `src/`

Runtime code for the extension.

Suggested split:

- `background/`
- `content/`
- `dashboard/`
- `popup/`
- `lib/`
- `types/`

Not every extension needs every surface on day one, but using the same names keeps repos easier to scan.

### `public/icons/`

Source icons and extension icon files.

Keep icon work here so store/export tasks have a predictable place to read from.

### `scripts/`

Automation and build helpers that belong to the actual extension repo.

This is where copied marketing or release scripts should usually live after customization.

### `store-assets/`

Generated or curated Chrome Web Store material.

Recommended subfolders:

- `screenshots/`
- `promo/`
- `video-clips/`
- `icons-export/`

### `dist/`

Generated build output.

Important:

- treat `dist/` as generated
- do not store hand-edited source files there
- usually do not commit it unless your release workflow explicitly requires it

## What should stay out of the starter

- product-specific billing logic
- product-specific copy
- private API secrets
- real production screenshots
- one-off experimental folders with unclear naming

## Safe default

If in doubt, prefer this split:

- runtime code in `src/`
- docs in `docs/`
- generated marketing media in `store-assets/`
- generated build output in `dist/`
