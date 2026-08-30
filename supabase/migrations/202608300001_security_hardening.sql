begin;

alter table public.profiles add column if not exists handle text;
alter table public.profiles add column if not exists is_discoverable boolean not null default false;
update public.profiles
set handle = 'reader_' || substr(replace(id::text, '-', ''), 1, 12)
where handle is null or btrim(handle) = '';
alter table public.profiles alter column handle set not null;
alter table public.profiles alter column is_discoverable set default false;
create unique index if not exists profiles_handle_lower_uidx on public.profiles (lower(handle));
do $$ begin
  alter table public.profiles add constraint profiles_handle_format_chk
    check (handle ~ '^[a-z0-9_]{3,24}$');
exception when duplicate_object then null; end $$;

alter table public.user_books add column if not exists page_count integer;
alter table public.user_books add column if not exists cover_mime text;
do $$ begin
  alter table public.user_books add constraint user_books_page_count_chk
    check (page_count is null or page_count between 1 and 10000);
exception when duplicate_object then null; end $$;

alter table public.journey_entries add column if not exists audio_path text;
alter table public.journey_entries add column if not exists audio_mime text;
do $$ begin
  alter table public.journey_entries add constraint journey_audio_path_chk
    check (audio_path is null or audio_path ~ '^[0-9a-f-]{36}/[^/]+/[^/]+\.(webm|m4a|ogg)$');
exception when duplicate_object then null; end $$;

create table if not exists public.journey_summary_sources (
  summary_id uuid not null references public.journey_summaries(id) on delete cascade,
  entry_id uuid not null references public.journey_entries(id) on delete cascade,
  paragraph_index integer not null check (paragraph_index between 0 and 20),
  created_at timestamptz not null default now(),
  primary key (summary_id, entry_id, paragraph_index)
);

create table if not exists public.failed_login_attempts (
  id bigint generated always as identity primary key,
  email_fingerprint text not null check (length(email_fingerprint) = 64),
  ip_fingerprint text not null check (length(ip_fingerprint) = 64),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 days')
);

create table if not exists public.admin_actions (
  id bigint generated always as identity primary key,
  admin_id uuid not null references auth.users(id) on delete restrict,
  action text not null check (char_length(action) between 1 and 80),
  target_type text,
  target_id text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists journey_entries_user_created_idx on public.journey_entries(user_id, created_at desc);
create index if not exists journey_entries_book_created_idx on public.journey_entries(book_id, created_at desc) where book_id is not null;
create index if not exists journey_entries_user_book_created_idx on public.journey_entries(user_book_id, created_at desc) where user_book_id is not null;
create index if not exists library_entries_user_status_idx on public.library_entries(user_id, status);
create index if not exists reading_invites_from_status_idx on public.reading_invites(from_user_id, status, created_at desc);
create index if not exists reading_invites_to_status_idx on public.reading_invites(to_user_id, status, created_at desc);
create index if not exists summaries_user_created_idx on public.journey_summaries(user_id, created_at desc);
create index if not exists failed_login_email_created_idx on public.failed_login_attempts(email_fingerprint, created_at desc);
create index if not exists failed_login_ip_created_idx on public.failed_login_attempts(ip_fingerprint, created_at desc);
create index if not exists failed_login_expiry_idx on public.failed_login_attempts(expires_at);
create index if not exists admin_actions_admin_created_idx on public.admin_actions(admin_id, created_at desc);

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  requested_handle text;
begin
  requested_handle := lower(coalesce(nullif(btrim(new.raw_user_meta_data->>'handle'), ''),
    'reader_' || substr(replace(new.id::text, '-', ''), 1, 12)));
  if requested_handle !~ '^[a-z0-9_]{3,24}$' then
    requested_handle := 'reader_' || substr(replace(new.id::text, '-', ''), 1, 12);
  end if;
  insert into public.profiles (id, name, handle, is_discoverable)
  values (new.id, left(coalesce(nullif(btrim(new.raw_user_meta_data->>'name'), ''), 'قارئ مَلفى'), 80), requested_handle, false)
  on conflict (id) do nothing;
  return new;
end;
$$;
revoke all on function public.handle_new_user() from public, anon, authenticated;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists(select 1 from public.profiles p where p.id = auth.uid() and p.is_admin = true)
$$;
revoke all on function public.is_admin() from public, anon;
grant execute on function public.is_admin() to authenticated;

create or replace function public.prevent_owner_change()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' and new.user_id is distinct from old.user_id then
    raise exception 'ownership cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function public.prevent_book_owner_change()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' and new.owner_id is distinct from old.owner_id then
    raise exception 'ownership cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function public.lock_invite_identity()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' and (
    new.from_user_id is distinct from old.from_user_id or
    new.to_user_id is distinct from old.to_user_id or
    new.book_id is distinct from old.book_id or
    new.user_book_id is distinct from old.user_book_id or
    new.created_at is distinct from old.created_at
  ) then
    raise exception 'invitation identity cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function public.secure_auth_event()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then new.user_id := auth.uid(); end if;
  new.created_at := now();
  new.device := left(coalesce(new.device, ''), 24);
  new.platform := left(coalesce(new.platform, ''), 24);
  return new;
end;
$$;

drop trigger if exists lock_library_owner on public.library_entries;
create trigger lock_library_owner before update on public.library_entries for each row execute function public.prevent_owner_change();
drop trigger if exists lock_journey_owner on public.journey_entries;
create trigger lock_journey_owner before update on public.journey_entries for each row execute function public.prevent_owner_change();
drop trigger if exists lock_collection_owner on public.collections;
create trigger lock_collection_owner before update on public.collections for each row execute function public.prevent_owner_change();
drop trigger if exists lock_summary_owner on public.journey_summaries;
create trigger lock_summary_owner before update on public.journey_summaries for each row execute function public.prevent_owner_change();
drop trigger if exists lock_contribution_owner on public.contributions;
create trigger lock_contribution_owner before update on public.contributions for each row execute function public.prevent_owner_change();
drop trigger if exists lock_user_book_owner on public.user_books;
create trigger lock_user_book_owner before update on public.user_books for each row execute function public.prevent_book_owner_change();
drop trigger if exists lock_reading_invite_identity on public.reading_invites;
create trigger lock_reading_invite_identity before update on public.reading_invites for each row execute function public.lock_invite_identity();
drop trigger if exists secure_auth_events_insert on public.auth_events;
create trigger secure_auth_events_insert before insert on public.auth_events for each row execute function public.secure_auth_event();

do $$
declare t text;
begin
  foreach t in array array['profiles','books','library_entries','journey_entries','collections','collection_books',
    'auth_events','plans','user_plans','journey_summaries','journey_summary_sources','reading_invites','contributions',
    'user_books','failed_login_attempts','admin_actions']
  loop
    execute format('alter table public.%I enable row level security', t);
    execute format('alter table public.%I force row level security', t);
  end loop;
end $$;

do $$
declare r record;
begin
  for r in select schemaname, tablename, policyname from pg_policies
    where schemaname = 'public' and tablename = any(array['profiles','books','library_entries','journey_entries','collections',
      'collection_books','auth_events','plans','user_plans','journey_summaries','journey_summary_sources','reading_invites',
      'contributions','user_books','failed_login_attempts','admin_actions'])
  loop
    execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename);
  end loop;
end $$;

create policy profiles_select_self on public.profiles for select to authenticated using (id = auth.uid());
create policy profiles_update_self on public.profiles for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy books_read_authenticated on public.books for select to authenticated using (true);

create policy library_owner_select on public.library_entries for select to authenticated using (user_id = auth.uid());
create policy library_owner_insert on public.library_entries for insert to authenticated with check (user_id = auth.uid());
create policy library_owner_update on public.library_entries for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy library_owner_delete on public.library_entries for delete to authenticated using (user_id = auth.uid());

create policy journey_owner_select on public.journey_entries for select to authenticated using (user_id = auth.uid());
create policy journey_owner_insert on public.journey_entries for insert to authenticated with check (user_id = auth.uid());
create policy journey_owner_update on public.journey_entries for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy journey_owner_delete on public.journey_entries for delete to authenticated using (user_id = auth.uid());

create policy collections_owner_select on public.collections for select to authenticated using (user_id = auth.uid());
create policy collections_owner_insert on public.collections for insert to authenticated with check (user_id = auth.uid());
create policy collections_owner_update on public.collections for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy collections_owner_delete on public.collections for delete to authenticated using (user_id = auth.uid());
create policy collection_books_owner_all on public.collection_books for all to authenticated
  using (exists(select 1 from public.collections c where c.id = collection_id and c.user_id = auth.uid()))
  with check (exists(select 1 from public.collections c where c.id = collection_id and c.user_id = auth.uid()));

create policy user_books_owner_select on public.user_books for select to authenticated using (owner_id = auth.uid());
create policy user_books_owner_insert on public.user_books for insert to authenticated with check (owner_id = auth.uid());
create policy user_books_owner_update on public.user_books for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy user_books_owner_delete on public.user_books for delete to authenticated using (owner_id = auth.uid());

create policy summaries_owner_select on public.journey_summaries for select to authenticated using (user_id = auth.uid());
create policy summaries_owner_insert on public.journey_summaries for insert to authenticated with check (user_id = auth.uid());
create policy summaries_owner_update on public.journey_summaries for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy summaries_owner_delete on public.journey_summaries for delete to authenticated using (user_id = auth.uid());
create policy summary_sources_owner_select on public.journey_summary_sources for select to authenticated
  using (exists(select 1 from public.journey_summaries s where s.id = summary_id and s.user_id = auth.uid()));

create policy contributions_owner_select on public.contributions for select to authenticated using (user_id = auth.uid() or public.is_admin());
create policy contributions_owner_insert on public.contributions for insert to authenticated with check (user_id = auth.uid());
create policy contributions_owner_update on public.contributions for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy contributions_owner_delete on public.contributions for delete to authenticated using (user_id = auth.uid());

create policy invites_participant_select on public.reading_invites for select to authenticated
  using (from_user_id = auth.uid() or to_user_id = auth.uid());
create policy invites_sender_insert on public.reading_invites for insert to authenticated
  with check (from_user_id = auth.uid() and to_user_id <> auth.uid() and status = 'pending');
create policy invites_recipient_update on public.reading_invites for update to authenticated
  using (to_user_id = auth.uid() and status = 'pending')
  with check (to_user_id = auth.uid() and status in ('accepted','declined'));
create policy invites_sender_delete_pending on public.reading_invites for delete to authenticated
  using (from_user_id = auth.uid() and status = 'pending');

create policy auth_events_admin_select on public.auth_events for select to authenticated using (public.is_admin());
create policy auth_events_self_insert on public.auth_events for insert to authenticated
  with check (user_id = auth.uid() and event_type in ('sign_in','sign_out','register','password_reset'));
create policy plans_authenticated_select on public.plans for select to authenticated using (true);
create policy user_plans_self_or_admin_select on public.user_plans for select to authenticated using (user_id = auth.uid() or public.is_admin());
create policy admin_actions_admin_select on public.admin_actions for select to authenticated using (public.is_admin());

revoke all on public.failed_login_attempts from anon, authenticated;
revoke all on public.admin_actions from anon, authenticated;

drop function if exists public.search_profiles(text);
create function public.search_profiles(q text)
returns table(id uuid, name text, handle text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.name, p.handle
  from public.profiles p
  where auth.uid() is not null
    and p.id <> auth.uid()
    and p.is_discoverable = true
    and length(btrim(q)) between 2 and 40
    and (p.name ilike '%' || replace(replace(btrim(q), '%', '\%'), '_', '\_') || '%' escape '\'
      or p.handle ilike '%' || replace(replace(btrim(q), '%', '\%'), '_', '\_') || '%' escape '\')
  order by case when lower(p.handle) = lower(btrim(q)) then 0 else 1 end, p.name
  limit 20
$$;
revoke all on function public.search_profiles(text) from public, anon;
grant execute on function public.search_profiles(text) to authenticated;

drop function if exists public.profile_names(uuid[]);
create function public.profile_names(ids uuid[])
returns table(id uuid, name text, handle text)
language sql
stable
security definer
set search_path = public
as $$
  select p.id, p.name, p.handle
  from public.profiles p
  where auth.uid() is not null and p.id = any(ids)
    and (p.id = auth.uid() or p.is_discoverable = true or exists(
      select 1 from public.reading_invites i
      where (i.from_user_id = auth.uid() and i.to_user_id = p.id)
         or (i.to_user_id = auth.uid() and i.from_user_id = p.id)
    ))
  limit 50
$$;
revoke all on function public.profile_names(uuid[]) from public, anon;
grant execute on function public.profile_names(uuid[]) to authenticated;

create or replace function public.shared_reading_progress()
returns table(invite_id uuid, other_user_id uuid, other_name text, book_id text, user_book_id uuid, page integer, status text)
language sql
stable
security definer
set search_path = public
as $$
  select i.id,
    case when i.from_user_id = auth.uid() then i.to_user_id else i.from_user_id end,
    p.name, i.book_id, i.user_book_id, coalesce(le.page, 0), i.status
  from public.reading_invites i
  join public.profiles p on p.id = case when i.from_user_id = auth.uid() then i.to_user_id else i.from_user_id end
  left join public.library_entries le
    on le.user_id = p.id and le.book_id is not distinct from i.book_id and le.user_book_id is not distinct from i.user_book_id
  where auth.uid() is not null and i.status = 'accepted'
    and (i.from_user_id = auth.uid() or i.to_user_id = auth.uid())
$$;
revoke all on function public.shared_reading_progress() from public, anon;
grant execute on function public.shared_reading_progress() to authenticated;

create or replace function public.purge_expired_security_data()
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.failed_login_attempts where expires_at < now();
  delete from public.auth_events where created_at < now() - interval '90 days';
end;
$$;
revoke all on function public.purge_expired_security_data() from public, anon, authenticated;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('book-covers','book-covers',false,5242880,array['image/jpeg'])
on conflict (id) do update set public=false,file_size_limit=5242880,allowed_mime_types=array['image/jpeg'];
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('journey-audio','journey-audio',false,26214400,array['audio/webm','audio/mp4','audio/ogg'])
on conflict (id) do update set public=false,file_size_limit=26214400,allowed_mime_types=array['audio/webm','audio/mp4','audio/ogg'];

do $$
declare r record;
begin
  for r in select policyname from pg_policies where schemaname='storage' and tablename='objects'
    and policyname like 'malfa_%'
  loop execute format('drop policy if exists %I on storage.objects', r.policyname); end loop;
end $$;

create policy malfa_covers_select on storage.objects for select to authenticated
  using (bucket_id='book-covers' and (storage.foldername(name))[1]=auth.uid()::text);
create policy malfa_covers_insert on storage.objects for insert to authenticated
  with check (bucket_id='book-covers' and (storage.foldername(name))[1]=auth.uid()::text
    and (select count(*) from storage.objects o where o.bucket_id='book-covers' and (storage.foldername(o.name))[1]=auth.uid()::text) < 25);
create policy malfa_covers_delete on storage.objects for delete to authenticated
  using (bucket_id='book-covers' and (storage.foldername(name))[1]=auth.uid()::text);
create policy malfa_audio_select on storage.objects for select to authenticated
  using (bucket_id='journey-audio' and (storage.foldername(name))[1]=auth.uid()::text);
create policy malfa_audio_insert on storage.objects for insert to authenticated
  with check (bucket_id='journey-audio' and (storage.foldername(name))[1]=auth.uid()::text
    and (select count(*) from storage.objects o where o.bucket_id='journey-audio' and (storage.foldername(o.name))[1]=auth.uid()::text) < 500);
create policy malfa_audio_delete on storage.objects for delete to authenticated
  using (bucket_id='journey-audio' and (storage.foldername(name))[1]=auth.uid()::text);

commit;
