# Multi-App Supabase Social Schema

This document describes a single-project Supabase schema for multiple extensions/apps isolated by `app_id`.

Migration:

- [20260324_multi_app_social.sql](C:/Users/burak/Desktop/Burakhrk/SideProjects/Extension-Base-Repo/supabase/migrations/20260324_multi_app_social.sql)

## Goal

- one Supabase project
- many extensions/apps
- every social record separated by `app_id`
- the same user can have different social graphs in different apps
- stable identity from `auth.users.id`

## Recommended `app_id` format

Use a short immutable slug:

- `deep-note`
- `drawing-office`
- `x-bookmark-organizer`

## Tables

- `apps`
- `profiles`
- `app_users`
- `friend_requests`
- `friendships`
- `sessions`
- `blocks`

## Included RPCs

- `send_friend_request(app_id, recipient_id)`
- `accept_friend_request(request_id)`
- `reject_friend_request(request_id)`
- `start_session(app_id, target_user_id, mode)`
- `end_session(session_id)`
- `get_social_state(app_id)`
- `set_app_preferences(app_id, extension_enabled, appear_online, allow_surprise)`

## Expected bootstrap principle

- restore auth session
- get authenticated user
- call `get_social_state(APP_ID)`
- let that app-scoped flow hydrate the UI

## Important

This shared schema is for social/auth state.  
Product-specific payloads should not be forced into these same tables unless they truly belong there.
