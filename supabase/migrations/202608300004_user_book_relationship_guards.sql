begin;

create or replace function public.enforce_user_book_relationship()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_book_id is not null and not exists (
    select 1 from public.user_books ub
    where ub.id = new.user_book_id and ub.owner_id = new.user_id
  ) then
    raise exception 'user book does not belong to row owner' using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function public.enforce_journey_media_relationship()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_book_id is not null and not exists (
    select 1 from public.user_books ub
    where ub.id = new.user_book_id and ub.owner_id = new.user_id
  ) then
    raise exception 'user book does not belong to row owner' using errcode = '42501';
  end if;
  if new.audio_path is not null and (
    split_part(new.audio_path, '/', 1) <> new.user_id::text
    or new.audio_mime not in ('audio/webm','audio/mp4','audio/ogg')
  ) then
    raise exception 'invalid journey audio ownership' using errcode = '42501';
  end if;
  if new.audio_path is null then new.audio_mime := null; end if;
  return new;
end;
$$;

create or replace function public.enforce_invite_book_owner()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.user_book_id is not null and not exists (
    select 1 from public.user_books ub
    where ub.id = new.user_book_id and ub.owner_id = new.from_user_id
  ) then
    raise exception 'invited user book does not belong to sender' using errcode = '42501';
  end if;
  return new;
end;
$$;

create or replace function public.enforce_cover_owner_path()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.cover_path is not null and (
    new.cover_path <> new.owner_id::text || '/' || new.id::text || '/cover.jpg'
    or new.cover_mime <> 'image/jpeg'
  ) then
    raise exception 'invalid cover ownership' using errcode = '42501';
  end if;
  if new.cover_path is null then new.cover_mime := null; end if;
  return new;
end;
$$;

drop trigger if exists enforce_library_user_book on public.library_entries;
create trigger enforce_library_user_book before insert or update on public.library_entries
for each row execute function public.enforce_user_book_relationship();

drop trigger if exists enforce_journey_user_book_media on public.journey_entries;
create trigger enforce_journey_user_book_media before insert or update on public.journey_entries
for each row execute function public.enforce_journey_media_relationship();

drop trigger if exists enforce_summary_user_book on public.journey_summaries;
create trigger enforce_summary_user_book before insert or update on public.journey_summaries
for each row execute function public.enforce_user_book_relationship();

drop trigger if exists enforce_invite_user_book on public.reading_invites;
create trigger enforce_invite_user_book before insert or update on public.reading_invites
for each row execute function public.enforce_invite_book_owner();

drop trigger if exists enforce_user_book_cover_path on public.user_books;
create trigger enforce_user_book_cover_path before insert or update on public.user_books
for each row execute function public.enforce_cover_owner_path();

revoke all on function public.enforce_user_book_relationship() from public, anon, authenticated;
revoke all on function public.enforce_journey_media_relationship() from public, anon, authenticated;
revoke all on function public.enforce_invite_book_owner() from public, anon, authenticated;
revoke all on function public.enforce_cover_owner_path() from public, anon, authenticated;

commit;
