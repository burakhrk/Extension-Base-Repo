# Extension Base Repo

This repository is a **template and reference base** for new Chrome extension projects.

It is **not** intended to be a live shared dependency between extensions.

Use it like this:

1. copy this repo into a new extension repo
2. rename and rebrand the project
3. keep developing independently

That avoids cross-project breakage while still giving every new extension a strong starting point.

## What is included

- Supabase multi-app schema docs and migration
- Chrome-extension-friendly Supabase Auth starter
- app-scoped social client starter
- analytics starter
- marketing screenshot / clip / montage tooling
- setup docs written so another AI can continue from this repo cleanly

## Repo sections

- [supabase](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/supabase)
- [marketing-assets](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/marketing-assets)
- [templates/chrome-extension-vite](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/templates/chrome-extension-vite)
- [docs](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs)

## Important rule

This repo should remain generic.

Do not turn it into a product-specific repo for one extension.  
Instead:

- keep reusable patterns here
- keep real app logic inside each extension's own repo

## Recommended workflow

1. pick a new extension slug and `APP_ID`
2. copy `templates/chrome-extension-vite`
3. apply branding and product logic
4. wire Supabase envs
5. run the multi-app schema in Supabase if not already installed
6. use the marketing assets kit to generate store screenshots and promo videos

## First files another AI should read

- [docs/START_HERE.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/START_HERE.md)
- [docs/DECISIONS.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/docs/DECISIONS.md)
- [supabase/docs/MULTI_APP_SOCIAL_SCHEMA.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/supabase/docs/MULTI_APP_SOCIAL_SCHEMA.md)
- [templates/chrome-extension-vite/README.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/templates/chrome-extension-vite/README.md)
