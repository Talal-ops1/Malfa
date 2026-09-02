alter table public.reading_preferences
  add column selected_book_id text null references public.books(id),
  add column selected_user_book_id uuid null references public.user_books(id),
  add column weekly_days_goal integer null;

alter table public.reading_preferences
  add constraint reading_preferences_one_selected_ck
  check (selected_book_id is null or selected_user_book_id is null);

alter table public.reading_preferences
  add constraint reading_preferences_weekly_days_goal_ck
  check (weekly_days_goal is null or (weekly_days_goal >= 1 and weekly_days_goal <= 7));

create or replace function public.secure_reading_preference()
returns trigger
language plpgsql
set search_path to 'public'
as $$
begin
  if auth.role() <> 'service_role' then new.user_id := auth.uid(); end if;
  if tg_op = 'UPDATE' then new.created_at := old.created_at; end if;
  if new.selected_user_book_id is not null and not exists (
    select 1 from public.user_books ub
    where ub.id = new.selected_user_book_id and ub.owner_id = new.user_id
  ) then
    raise exception 'selected user book does not belong to preference owner' using errcode = '42501';
  end if;
  new.updated_at := now();
  return new;
end;
$$;
