begin;

create table if not exists public.reading_preferences (
  user_id uuid primary key references auth.users(id) on delete cascade,
  daily_goal_minutes integer not null default 20 check (daily_goal_minutes between 1 and 480),
  reminder_enabled boolean not null default false,
  reminder_time time,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reading_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  book_id text references public.books(id) on delete restrict,
  user_book_id uuid references public.user_books(id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz,
  duration_sec integer not null default 0 check (duration_sec >= 0),
  page_start integer not null default 0 check (page_start >= 0),
  page_end integer not null default 0 check (page_end >= 0),
  pages_read integer not null default 0 check (pages_read >= 0),
  speed_pages_per_hour numeric(10,2) not null default 0 check (speed_pages_per_hour >= 0),
  note text check (note is null or char_length(note) <= 2000),
  pause_reason text check (pause_reason is null or pause_reason in ('manual','background','crash','other')),
  pause_count integer not null default 0 check (pause_count >= 0),
  completed boolean not null default true,
  goal_minutes_snapshot integer not null check (goal_minutes_snapshot between 1 and 480),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reading_sessions_one_book_chk check ((book_id is null) <> (user_book_id is null)),
  constraint reading_sessions_page_order_chk check (page_end >= page_start)
);

create index if not exists reading_sessions_user_started_idx
  on public.reading_sessions(user_id, started_at desc);
create index if not exists reading_sessions_book_idx
  on public.reading_sessions(user_id, book_id, started_at desc) where book_id is not null;
create index if not exists reading_sessions_user_book_idx
  on public.reading_sessions(user_id, user_book_id, started_at desc) where user_book_id is not null;

create or replace function public.secure_reading_preference()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then new.user_id := auth.uid(); end if;
  if tg_op = 'UPDATE' then new.created_at := old.created_at; end if;
  new.updated_at := now();
  return new;
end;
$$;

create or replace function public.secure_reading_session()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.role() <> 'service_role' then
    new.user_id := auth.uid();
    if tg_op = 'UPDATE' then
      if new.started_at is distinct from old.started_at
        or new.book_id is distinct from old.book_id
        or new.user_book_id is distinct from old.user_book_id
        or new.created_at is distinct from old.created_at then
        raise exception 'reading session identity cannot be changed' using errcode = '42501';
      end if;
    end if;
  end if;
  if new.user_book_id is not null and not exists (
    select 1 from public.user_books ub
    where ub.id = new.user_book_id and ub.owner_id = new.user_id
  ) then
    raise exception 'user book does not belong to session owner' using errcode = '42501';
  end if;
  new.page_end := greatest(new.page_end, new.page_start);
  new.pages_read := greatest(0, new.page_end - new.page_start);
  new.speed_pages_per_hour := case
    when new.duration_sec > 0 then round((new.pages_read * 3600.0 / new.duration_sec)::numeric, 2)
    else 0
  end;
  new.note := nullif(left(btrim(coalesce(new.note, '')), 2000), '');
  if tg_op = 'INSERT' then new.created_at := now(); end if;
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists secure_reading_preferences_write on public.reading_preferences;
create trigger secure_reading_preferences_write before insert or update on public.reading_preferences
for each row execute function public.secure_reading_preference();

drop trigger if exists secure_reading_sessions_write on public.reading_sessions;
create trigger secure_reading_sessions_write before insert or update on public.reading_sessions
for each row execute function public.secure_reading_session();

alter table public.reading_preferences enable row level security;
alter table public.reading_preferences force row level security;
alter table public.reading_sessions enable row level security;
alter table public.reading_sessions force row level security;

create policy reading_preferences_owner_select on public.reading_preferences
  for select to authenticated using (user_id = auth.uid());
create policy reading_preferences_owner_insert on public.reading_preferences
  for insert to authenticated with check (user_id = auth.uid());
create policy reading_preferences_owner_update on public.reading_preferences
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy reading_preferences_owner_delete on public.reading_preferences
  for delete to authenticated using (user_id = auth.uid());

create policy reading_sessions_owner_select on public.reading_sessions
  for select to authenticated using (user_id = auth.uid());
create policy reading_sessions_owner_insert on public.reading_sessions
  for insert to authenticated with check (user_id = auth.uid());
create policy reading_sessions_owner_update on public.reading_sessions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy reading_sessions_owner_delete on public.reading_sessions
  for delete to authenticated using (user_id = auth.uid());

revoke all on function public.secure_reading_preference() from public, anon, authenticated;
revoke all on function public.secure_reading_session() from public, anon, authenticated;
grant select, insert, update, delete on public.reading_preferences to authenticated;
grant select, insert, update, delete on public.reading_sessions to authenticated;

commit;
