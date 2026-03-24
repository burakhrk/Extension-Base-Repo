# Getting Started

If you are using this repo for a new extension, do this in order:

1. choose:
   - extension name
   - route slug
   - `APP_ID`
2. confirm whether the project is Vite-based
3. copy the starter under:
   - [templates/chrome-extension-supabase-vite](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/templates/chrome-extension-supabase-vite)
4. set Supabase env values
5. configure Google auth for Chrome extension redirects
6. connect analytics
7. only then start product-specific UI work

## If using shared Supabase

Use the multi-app model:

- every extension gets a fixed `APP_ID`
- all social records are isolated by `app_id`
- `auth.users.id` is the durable user identity

## If using the marketing kit

Start here:

- [extension-marketing-kit/README.md](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/extension-marketing-kit/README.md)

The scripts are meant to be copied into a real extension repo and then customized.
