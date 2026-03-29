# Extension Base Repo

This repository is an **opinionated starter + reference base** for new Chrome extension projects that use Supabase, Vite, shared analytics conventions, and reusable marketing tooling.

It is **not** intended to be a live shared dependency between extensions.

Use it like this:

1. copy this repo into a new extension repo
2. rename and rebrand the project
3. keep developing independently

That avoids cross-project breakage while still giving every new extension a strong starting point.

## Starter vs reference

Use these words intentionally in this repo:

- `starter`
  - code or folders meant to be copied into a real extension project
- `reference`
  - docs, migrations, and decision records that should be read and adapted, not blindly copied

## What is included

- an opinionated Supabase + Vite starter for Chrome extensions
- Supabase multi-app schema docs and migration
- Chrome-extension-friendly Supabase Auth starter
- app-scoped social client starter
- analytics starter
- reusable screenshot / clip / montage tooling
- setup docs written so another AI can continue from this repo cleanly

## Repo sections

- [docs](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs)
- [docs/supabase](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/supabase)
- [supabase/migrations](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/supabase/migrations)
- [extension-marketing-kit](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/extension-marketing-kit)
- [templates/chrome-extension-supabase-vite](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/templates/chrome-extension-supabase-vite)

## Important rule

This repo should remain generic.

Do not turn it into a product-specific repo for one extension.  
Instead:

- keep reusable patterns here
- keep real app logic inside each extension's own repo

## Recommended workflow

1. pick a new extension slug and `APP_ID`
2. copy `templates/chrome-extension-supabase-vite`
3. apply branding and product logic
4. wire Supabase envs
5. run the multi-app schema in Supabase if not already installed
6. use the extension marketing kit to generate store screenshots and promo videos

If the extension opens a website hub route, use a consistent handoff query shape:

- `source=chrome-extension`
- `appId=<APP_ID>`
- `clientId=<client-id>`
- `accountId=<signed-in-account-id>`
- `email=<signed-in-email>`

## First files another AI should read

- [docs/GETTING_STARTED.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/GETTING_STARTED.md)
- [docs/REPO_STRUCTURE.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/REPO_STRUCTURE.md)
- [docs/ARCHITECTURE_DECISIONS.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/ARCHITECTURE_DECISIONS.md)
- [docs/CREATE_NEW_EXTENSION.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/CREATE_NEW_EXTENSION.md)
- [docs/supabase/MULTI_APP_SOCIAL_SCHEMA.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/supabase/MULTI_APP_SOCIAL_SCHEMA.md)
- [templates/chrome-extension-supabase-vite/README.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/templates/chrome-extension-supabase-vite/README.md)
