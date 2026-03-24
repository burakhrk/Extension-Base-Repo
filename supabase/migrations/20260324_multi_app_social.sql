create extension if not exists pgcrypto;

create table if not exists public.apps (
  id text primary key,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create table if not exists public.app_users (
  app_id text not null references public.apps(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  extension_enabled boolean not null default true,
  appear_online boolean not null default true,
  allow_surprise boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (app_id, user_id)
);

create table if not exists public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  app_id text not null references public.apps(id) on delete cascade,
  requester_id uuid not null references auth.users(id) on delete cascade,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  status text not null check (status in ('pending', 'accepted', 'rejected', 'cancelled')),
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now()),
  check (requester_id <> recipient_id)
);

create table if not exists public.friendships (
  id uuid primary key default gen_random_uuid(),
  app_id text not null references public.apps(id) on delete cascade,
  user_low uuid not null references auth.users(id) on delete cascade,
  user_high uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  unique (app_id, user_low, user_high),
  check (user_low < user_high)
);

create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  app_id text not null references public.apps(id) on delete cascade,
  initiator_id uuid not null references auth.users(id) on delete cascade,
  recipient_id uuid not null references auth.users(id) on delete cascade,
  mode text not null check (mode in ('send', 'live')),
  status text not null check (status in ('active', 'ended')),
  created_at timestamptz not null default timezone('utc', now()),
  ended_at timestamptz,
  check ((status = 'active' and ended_at is null) or (status = 'ended' and ended_at is not null))
);

create table if not exists public.blocks (
  id uuid primary key default gen_random_uuid(),
  app_id text not null references public.apps(id) on delete cascade,
  blocker_id uuid not null references auth.users(id) on delete cascade,
  blocked_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default timezone('utc', now()),
  unique (app_id, blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

create unique index if not exists friend_requests_one_pending_per_pair_idx
  on public.friend_requests (app_id, requester_id, recipient_id)
  where status = 'pending';

create index if not exists friend_requests_recipient_pending_idx
  on public.friend_requests (app_id, recipient_id, created_at desc)
  where status = 'pending';

create index if not exists friend_requests_requester_pending_idx
  on public.friend_requests (app_id, requester_id, created_at desc)
  where status = 'pending';

create index if not exists friendships_low_idx
  on public.friendships (app_id, user_low, created_at desc);

create index if not exists friendships_high_idx
  on public.friendships (app_id, user_high, created_at desc);

create index if not exists sessions_initiator_active_idx
  on public.sessions (app_id, initiator_id, created_at desc)
  where status = 'active';

create index if not exists sessions_recipient_active_idx
  on public.sessions (app_id, recipient_id, created_at desc)
  where status = 'active';

create index if not exists blocks_blocker_idx
  on public.blocks (app_id, blocker_id);

create index if not exists app_users_user_idx
  on public.app_users (user_id, app_id);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', new.raw_user_meta_data ->> 'name'),
    new.raw_user_meta_data ->> 'avatar_url'
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_auth_user();

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute procedure public.set_updated_at();

drop trigger if exists app_users_set_updated_at on public.app_users;
create trigger app_users_set_updated_at
before update on public.app_users
for each row execute procedure public.set_updated_at();

drop trigger if exists friend_requests_set_updated_at on public.friend_requests;
create trigger friend_requests_set_updated_at
before update on public.friend_requests
for each row execute procedure public.set_updated_at();

drop trigger if exists apps_set_updated_at on public.apps;
create trigger apps_set_updated_at
before update on public.apps
for each row execute procedure public.set_updated_at();

create or replace function public.ensure_profile_exists()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  insert into public.profiles (user_id)
  values (auth.uid())
  on conflict (user_id) do nothing;
end;
$$;

create or replace function public.ensure_app_user(p_app_id text)
returns public.app_users
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.app_users;
begin
  if auth.uid() is null then
    raise exception 'Authentication required';
  end if;

  if not exists (
    select 1
    from public.apps
    where id = p_app_id
      and is_active = true
  ) then
    raise exception 'Unknown or inactive app_id';
  end if;

  perform public.ensure_profile_exists();

  insert into public.app_users (app_id, user_id)
  values (p_app_id, auth.uid())
  on conflict (app_id, user_id) do update
    set updated_at = timezone('utc', now())
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function public.is_blocked_pair(p_app_id text, p_user_a uuid, p_user_b uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.blocks b
    where b.app_id = p_app_id
      and (
        (b.blocker_id = p_user_a and b.blocked_id = p_user_b)
        or
        (b.blocker_id = p_user_b and b.blocked_id = p_user_a)
      )
  );
$$;

create or replace function public.send_friend_request(p_app_id text, p_recipient_id uuid)
returns public.friend_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_sender uuid := auth.uid();
  v_request public.friend_requests;
begin
  if v_sender is null then
    raise exception 'Authentication required';
  end if;

  if p_recipient_id is null or p_recipient_id = v_sender then
    raise exception 'Invalid recipient';
  end if;

  perform public.ensure_app_user(p_app_id);

  if public.is_blocked_pair(p_app_id, v_sender, p_recipient_id) then
    raise exception 'This user cannot be contacted';
  end if;

  insert into public.app_users (app_id, user_id)
  values (p_app_id, p_recipient_id)
  on conflict (app_id, user_id) do nothing;

  if exists (
    select 1
    from public.friendships f
    where f.app_id = p_app_id
      and f.user_low = least(v_sender, p_recipient_id)
      and f.user_high = greatest(v_sender, p_recipient_id)
  ) then
    raise exception 'Already friends in this app';
  end if;

  begin
    insert into public.friend_requests (app_id, requester_id, recipient_id, status)
    values (p_app_id, v_sender, p_recipient_id, 'pending');
  exception
    when unique_violation then
      null;
  end;

  select *
  into v_request
  from public.friend_requests
  where app_id = p_app_id
    and requester_id = v_sender
    and recipient_id = p_recipient_id
    and status = 'pending'
  order by created_at desc
  limit 1;

  if v_request.id is null then
    raise exception 'Pending request already exists';
  end if;

  return v_request;
end;
$$;

create or replace function public.accept_friend_request(p_request_id uuid)
returns public.friendships
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_request public.friend_requests;
  v_friendship public.friendships;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  select *
  into v_request
  from public.friend_requests
  where id = p_request_id
    and status = 'pending';

  if v_request.id is null then
    raise exception 'Pending request not found';
  end if;

  if v_request.recipient_id <> v_user then
    raise exception 'Only the recipient can accept this request';
  end if;

  if public.is_blocked_pair(v_request.app_id, v_request.requester_id, v_request.recipient_id) then
    raise exception 'This friendship is blocked';
  end if;

  perform public.ensure_app_user(v_request.app_id);
  insert into public.app_users (app_id, user_id)
  values (v_request.app_id, v_request.requester_id)
  on conflict (app_id, user_id) do nothing;

  insert into public.friendships (app_id, user_low, user_high)
  values (
    v_request.app_id,
    least(v_request.requester_id, v_request.recipient_id),
    greatest(v_request.requester_id, v_request.recipient_id)
  )
  on conflict (app_id, user_low, user_high) do nothing
  returning * into v_friendship;

  if v_friendship.id is null then
    select *
    into v_friendship
    from public.friendships
    where app_id = v_request.app_id
      and user_low = least(v_request.requester_id, v_request.recipient_id)
      and user_high = greatest(v_request.requester_id, v_request.recipient_id);
  end if;

  update public.friend_requests
  set status = 'accepted'
  where id = p_request_id;

  return v_friendship;
end;
$$;

create or replace function public.reject_friend_request(p_request_id uuid)
returns public.friend_requests
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_request public.friend_requests;
  v_next_status text;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  select *
  into v_request
  from public.friend_requests
  where id = p_request_id
    and status = 'pending';

  if v_request.id is null then
    raise exception 'Pending request not found';
  end if;

  if v_request.recipient_id = v_user then
    v_next_status := 'rejected';
  elsif v_request.requester_id = v_user then
    v_next_status := 'cancelled';
  else
    raise exception 'You are not part of this request';
  end if;

  update public.friend_requests
  set status = v_next_status
  where id = p_request_id
  returning * into v_request;

  return v_request;
end;
$$;

create or replace function public.start_session(p_app_id text, p_target_user_id uuid, p_mode text)
returns public.sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_target public.app_users;
  v_own public.app_users;
  v_session public.sessions;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  if p_mode not in ('send', 'live') then
    raise exception 'Invalid mode';
  end if;

  if p_target_user_id is null or p_target_user_id = v_user then
    raise exception 'Invalid target user';
  end if;

  v_own := public.ensure_app_user(p_app_id);

  select *
  into v_target
  from public.app_users
  where app_id = p_app_id
    and user_id = p_target_user_id;

  if v_target.user_id is null then
    raise exception 'Target user is not available in this app yet';
  end if;

  if public.is_blocked_pair(p_app_id, v_user, p_target_user_id) then
    raise exception 'This user cannot be contacted';
  end if;

  if not exists (
    select 1
    from public.friendships f
    where f.app_id = p_app_id
      and f.user_low = least(v_user, p_target_user_id)
      and f.user_high = greatest(v_user, p_target_user_id)
  ) then
    raise exception 'Users must be friends before starting a session';
  end if;

  if v_own.extension_enabled = false then
    raise exception 'Enable the extension before starting sessions';
  end if;

  if v_target.extension_enabled = false then
    raise exception 'Target user has disabled extension access';
  end if;

  if p_mode = 'send' and v_target.allow_surprise = false then
    raise exception 'Target user does not allow surprise interactions';
  end if;

  select *
  into v_session
  from public.sessions
  where app_id = p_app_id
    and status = 'active'
    and (
      (initiator_id = v_user and recipient_id = p_target_user_id)
      or
      (initiator_id = p_target_user_id and recipient_id = v_user)
    )
  order by created_at desc
  limit 1;

  if v_session.id is not null then
    return v_session;
  end if;

  insert into public.sessions (app_id, initiator_id, recipient_id, mode, status)
  values (p_app_id, v_user, p_target_user_id, p_mode, 'active')
  returning * into v_session;

  return v_session;
end;
$$;

create or replace function public.end_session(p_session_id uuid)
returns public.sessions
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_session public.sessions;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  update public.sessions
  set status = 'ended',
      ended_at = timezone('utc', now())
  where id = p_session_id
    and status = 'active'
    and (initiator_id = v_user or recipient_id = v_user)
  returning * into v_session;

  if v_session.id is null then
    raise exception 'Active session not found';
  end if;

  return v_session;
end;
$$;

create or replace function public.set_app_preferences(
  p_app_id text,
  p_extension_enabled boolean default null,
  p_appear_online boolean default null,
  p_allow_surprise boolean default null
)
returns public.app_users
language plpgsql
security definer
set search_path = public
as $$
declare
  v_row public.app_users;
begin
  v_row := public.ensure_app_user(p_app_id);

  update public.app_users
  set extension_enabled = coalesce(p_extension_enabled, extension_enabled),
      appear_online = coalesce(p_appear_online, appear_online),
      allow_surprise = coalesce(p_allow_surprise, allow_surprise)
  where app_id = p_app_id
    and user_id = auth.uid()
  returning * into v_row;

  return v_row;
end;
$$;

create or replace function public.get_social_state(p_app_id text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user uuid := auth.uid();
  v_app_user public.app_users;
begin
  if v_user is null then
    raise exception 'Authentication required';
  end if;

  v_app_user := public.ensure_app_user(p_app_id);

  return jsonb_build_object(
    'app_id', p_app_id,
    'own_profile',
      (
        select to_jsonb(p)
        from public.profiles p
        where p.user_id = v_user
      ),
    'preferences',
      to_jsonb(v_app_user),
    'incoming_requests',
      coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', fr.id,
            'requester_id', fr.requester_id,
            'status', fr.status,
            'created_at', fr.created_at,
            'updated_at', fr.updated_at,
            'profile', jsonb_build_object(
              'display_name', p.display_name,
              'avatar_url', p.avatar_url
            )
          )
          order by fr.created_at desc
        )
        from public.friend_requests fr
        join public.profiles p on p.user_id = fr.requester_id
        where fr.app_id = p_app_id
          and fr.recipient_id = v_user
          and fr.status = 'pending'
      ), '[]'::jsonb),
    'outgoing_requests',
      coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', fr.id,
            'recipient_id', fr.recipient_id,
            'status', fr.status,
            'created_at', fr.created_at,
            'updated_at', fr.updated_at,
            'profile', jsonb_build_object(
              'display_name', p.display_name,
              'avatar_url', p.avatar_url
            )
          )
          order by fr.created_at desc
        )
        from public.friend_requests fr
        join public.profiles p on p.user_id = fr.recipient_id
        where fr.app_id = p_app_id
          and fr.requester_id = v_user
          and fr.status = 'pending'
      ), '[]'::jsonb),
    'accepted_friends',
      coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'friendship_id', f.id,
            'friend_user_id', friend.user_id,
            'created_at', f.created_at,
            'profile', jsonb_build_object(
              'display_name', p.display_name,
              'avatar_url', p.avatar_url
            ),
            'preferences', jsonb_build_object(
              'extension_enabled', au.extension_enabled,
              'appear_online', au.appear_online,
              'allow_surprise', au.allow_surprise
            ),
            'visible_online', (au.extension_enabled and au.appear_online)
          )
          order by f.created_at desc
        )
        from public.friendships f
        cross join lateral (
          select case when f.user_low = v_user then f.user_high else f.user_low end as user_id
        ) friend
        join public.profiles p on p.user_id = friend.user_id
        join public.app_users au on au.app_id = f.app_id and au.user_id = friend.user_id
        where f.app_id = p_app_id
          and (f.user_low = v_user or f.user_high = v_user)
      ), '[]'::jsonb),
    'active_sessions',
      coalesce((
        select jsonb_agg(
          jsonb_build_object(
            'id', s.id,
            'mode', s.mode,
            'status', s.status,
            'created_at', s.created_at,
            'ended_at', s.ended_at,
            'initiator_id', s.initiator_id,
            'recipient_id', s.recipient_id
          )
          order by s.created_at desc
        )
        from public.sessions s
        where s.app_id = p_app_id
          and s.status = 'active'
          and (s.initiator_id = v_user or s.recipient_id = v_user)
      ), '[]'::jsonb)
  );
end;
$$;

alter table public.apps enable row level security;
alter table public.profiles enable row level security;
alter table public.app_users enable row level security;
alter table public.friend_requests enable row level security;
alter table public.friendships enable row level security;
alter table public.sessions enable row level security;
alter table public.blocks enable row level security;

drop policy if exists "apps_read_active" on public.apps;
create policy "apps_read_active"
on public.apps
for select
to authenticated
using (is_active = true);

drop policy if exists "profiles_select_self" on public.profiles;
create policy "profiles_select_self"
on public.profiles
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "profiles_insert_self" on public.profiles;
create policy "profiles_insert_self"
on public.profiles
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "profiles_update_self" on public.profiles;
create policy "profiles_update_self"
on public.profiles
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "app_users_select_self" on public.app_users;
create policy "app_users_select_self"
on public.app_users
for select
to authenticated
using (auth.uid() = user_id);

drop policy if exists "app_users_insert_self" on public.app_users;
create policy "app_users_insert_self"
on public.app_users
for insert
to authenticated
with check (auth.uid() = user_id);

drop policy if exists "app_users_update_self" on public.app_users;
create policy "app_users_update_self"
on public.app_users
for update
to authenticated
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

drop policy if exists "friend_requests_select_participant" on public.friend_requests;
create policy "friend_requests_select_participant"
on public.friend_requests
for select
to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id);

drop policy if exists "friend_requests_insert_requester" on public.friend_requests;
create policy "friend_requests_insert_requester"
on public.friend_requests
for insert
to authenticated
with check (auth.uid() = requester_id);

drop policy if exists "friend_requests_update_participant" on public.friend_requests;
create policy "friend_requests_update_participant"
on public.friend_requests
for update
to authenticated
using (auth.uid() = requester_id or auth.uid() = recipient_id)
with check (auth.uid() = requester_id or auth.uid() = recipient_id);

drop policy if exists "friendships_select_participant" on public.friendships;
create policy "friendships_select_participant"
on public.friendships
for select
to authenticated
using (auth.uid() = user_low or auth.uid() = user_high);

drop policy if exists "friendships_insert_participant" on public.friendships;
create policy "friendships_insert_participant"
on public.friendships
for insert
to authenticated
with check (auth.uid() = user_low or auth.uid() = user_high);

drop policy if exists "sessions_select_participant" on public.sessions;
create policy "sessions_select_participant"
on public.sessions
for select
to authenticated
using (auth.uid() = initiator_id or auth.uid() = recipient_id);

drop policy if exists "sessions_insert_initiator" on public.sessions;
create policy "sessions_insert_initiator"
on public.sessions
for insert
to authenticated
with check (auth.uid() = initiator_id);

drop policy if exists "sessions_update_participant" on public.sessions;
create policy "sessions_update_participant"
on public.sessions
for update
to authenticated
using (auth.uid() = initiator_id or auth.uid() = recipient_id)
with check (auth.uid() = initiator_id or auth.uid() = recipient_id);

drop policy if exists "blocks_select_participant" on public.blocks;
create policy "blocks_select_participant"
on public.blocks
for select
to authenticated
using (auth.uid() = blocker_id or auth.uid() = blocked_id);

drop policy if exists "blocks_insert_blocker" on public.blocks;
create policy "blocks_insert_blocker"
on public.blocks
for insert
to authenticated
with check (auth.uid() = blocker_id);

drop policy if exists "blocks_delete_blocker" on public.blocks;
create policy "blocks_delete_blocker"
on public.blocks
for delete
to authenticated
using (auth.uid() = blocker_id);

grant execute on function public.ensure_profile_exists() to authenticated;
grant execute on function public.ensure_app_user(text) to authenticated;
grant execute on function public.send_friend_request(text, uuid) to authenticated;
grant execute on function public.accept_friend_request(uuid) to authenticated;
grant execute on function public.reject_friend_request(uuid) to authenticated;
grant execute on function public.start_session(text, uuid, text) to authenticated;
grant execute on function public.end_session(uuid) to authenticated;
grant execute on function public.set_app_preferences(text, boolean, boolean, boolean) to authenticated;
grant execute on function public.get_social_state(text) to authenticated;

insert into public.apps (id, name, is_active)
values ('deep-note', 'Deep Note', true)
on conflict (id) do update
set name = excluded.name,
    is_active = excluded.is_active,
    updated_at = timezone('utc', now());
