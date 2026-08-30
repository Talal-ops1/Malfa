begin;

create or replace function public.prevent_admin_action_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  raise exception 'admin audit records are immutable';
end;
$$;
revoke all on function public.prevent_admin_action_change() from public, anon, authenticated;

drop trigger if exists admin_actions_immutable on public.admin_actions;
create trigger admin_actions_immutable
before update or delete on public.admin_actions
for each row execute function public.prevent_admin_action_change();

-- Shared Menaras are exposed through a narrow authenticated RPC rather than a
-- broad table policy. Private profiles remain anonymous even when the reader
-- explicitly shares one Menara.
create or replace function public.shared_menaras()
returns table(
  id uuid,
  summary_text text,
  book_title text,
  display_name text,
  updated_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select s.id,
    s.summary_text,
    coalesce(b.title, ub.title, 'كتاب') as book_title,
    case when p.is_discoverable then p.name else 'قارئ مَلفى' end as display_name,
    s.updated_at
  from public.journey_summaries s
  join public.profiles p on p.id = s.user_id
  left join public.books b on b.id = s.book_id
  left join public.user_books ub on ub.id = s.user_book_id and ub.owner_id = s.user_id
  where auth.uid() is not null
    and s.is_shared = true
    and s.user_id <> auth.uid()
  order by s.updated_at desc
  limit 50
$$;
revoke all on function public.shared_menaras() from public, anon;
grant execute on function public.shared_menaras() to authenticated;

commit;
