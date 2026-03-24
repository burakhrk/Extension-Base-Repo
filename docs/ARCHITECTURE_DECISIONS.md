# Architecture Decisions

## Why this repo is a template and not a shared dependency

Because separate extensions should not break each other when one evolves.

So:

- this repo is copied
- each extension then lives independently

## Why Supabase is shared but app-scoped

One Supabase project can support many extensions if:

- each extension has a fixed `APP_ID`
- every social row is scoped by `app_id`
- auth identity comes from `auth.users.id`

## Why website hub is separate

Public product websites belong in their own repo.

This base repo is for:

- extension runtime patterns
- auth
- analytics
- social client setup
- marketing asset automation

not for the final public landing pages themselves.
