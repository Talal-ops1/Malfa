-- Additive: collections previously could only hold catalog books. This lets
-- a private collection also hold the owner's manually-added (user_books)
-- titles, without deleting or renaming any existing row.
alter table public.collection_books drop constraint collection_books_pkey;
alter table public.collection_books add column id uuid not null default gen_random_uuid();
alter table public.collection_books add column user_book_id uuid null references public.user_books(id);
alter table public.collection_books alter column book_id drop not null;
alter table public.collection_books add constraint collection_books_pkey primary key (id);
alter table public.collection_books add constraint collection_books_one_book_ck
  check ((book_id is not null) <> (user_book_id is not null));
create unique index collection_books_book_uq on public.collection_books(collection_id, book_id) where book_id is not null;
create unique index collection_books_userbook_uq on public.collection_books(collection_id, user_book_id) where user_book_id is not null;

create or replace function public.enforce_collection_book_owner()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $$
begin
  if new.user_book_id is not null and not exists (
    select 1 from public.user_books ub
    join public.collections c on c.id = new.collection_id
    where ub.id = new.user_book_id and ub.owner_id = c.user_id
  ) then
    raise exception 'collection book does not belong to collection owner' using errcode = '42501';
  end if;
  return new;
end;
$$;

create trigger enforce_collection_book_owner_trg
before insert or update on public.collection_books
for each row execute function public.enforce_collection_book_owner();
