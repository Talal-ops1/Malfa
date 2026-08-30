-- Keep a minimal, server-derived title snapshot on invitations so recipients
-- can understand a pending custom-book invitation without gaining SELECT
-- access to the sender's private user_books row.

alter table public.reading_invites
  add column if not exists book_title text;

create or replace function public.set_invite_book_title()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.book_id is not null then
    select b.title into new.book_title
    from public.books b
    where b.id = new.book_id;
  else
    select ub.title into new.book_title
    from public.user_books ub
    where ub.id = new.user_book_id
      and ub.owner_id = new.from_user_id;
  end if;

  if nullif(btrim(new.book_title), '') is null then
    raise exception 'invite_book_not_found';
  end if;
  new.book_title := left(btrim(new.book_title), 180);
  return new;
end;
$$;

revoke all on function public.set_invite_book_title() from public, anon, authenticated;
grant execute on function public.set_invite_book_title() to service_role;

drop trigger if exists set_invite_book_title on public.reading_invites;
create trigger set_invite_book_title
before insert on public.reading_invites
for each row execute function public.set_invite_book_title();

update public.reading_invites i
set book_title = coalesce(
  (select b.title from public.books b where b.id = i.book_id),
  (select ub.title from public.user_books ub
   where ub.id = i.user_book_id and ub.owner_id = i.from_user_id)
)
where nullif(btrim(i.book_title), '') is null;

alter table public.reading_invites
  drop constraint if exists reading_invites_book_title_present;

alter table public.reading_invites
  alter column book_title set not null;

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
    new.book_title is distinct from old.book_title or
    new.created_at is distinct from old.created_at
  ) then
    raise exception 'invitation identity cannot be changed' using errcode = '42501';
  end if;
  return new;
end;
$$;
