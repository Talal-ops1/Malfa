-- Run in Supabase SQL Editor as postgres. Every mutation is rolled back.
begin;

create temp table malfa_rls_users as
select (max(id::text) filter (where rn = 1))::uuid as account_a,
       (max(id::text) filter (where rn = 2))::uuid as account_b
from (
  select u.id, row_number() over (order by coalesce(p.is_admin,false) desc, u.created_at) rn
  from auth.users u join public.profiles p on p.id = u.id
) ranked
where rn <= 2;

do $$
begin
  if (select account_a is null or account_b is null from malfa_rls_users) then
    raise exception 'RLS test requires two accounts';
  end if;
end $$;
grant select on malfa_rls_users to authenticated;

select set_config('request.jwt.claim.sub',(select account_a::text from malfa_rls_users),true);
select set_config('request.jwt.claim.role','authenticated',true);
set local role authenticated;

do $$
declare
  a uuid := (select account_a from malfa_rls_users);
  b uuid := (select account_b from malfa_rls_users);
  ub uuid;
  collection_id uuid;
  entry_id uuid;
  summary_id uuid;
  v_invite_id uuid;
  affected integer;
begin
  if auth.uid() is distinct from a then raise exception 'account A claim failed'; end if;
  if (select count(*) from public.profiles where id = a) <> 1 then raise exception 'A cannot read own profile'; end if;
  if (select count(*) from public.profiles where id = b) <> 0 then raise exception 'A can read B profile'; end if;

  update public.profiles set name='MALFA RLS Probe',is_discoverable=true where id=a;
  get diagnostics affected = row_count;
  if affected <> 1 then raise exception 'A cannot update own profile'; end if;

  insert into public.user_books(owner_id,title,author,page_count)
  values(a,'__malfa_rls_book__','اختبار',120) returning id into ub;
  insert into public.library_entries(user_id,user_book_id,status,page)
  values(a,ub,'reading',12);
  insert into public.journey_entries(user_id,user_book_id,note,duration_sec,page_from,page_to)
  values(a,ub,'__malfa_rls_note__',9,1,12) returning id into entry_id;
  insert into public.collections(user_id,title)
  values(a,'__malfa_rls_collection__') returning id into collection_id;
  insert into public.collection_books(collection_id,book_id)
  select collection_id,id from public.books order by id limit 1;
  insert into public.journey_summaries(user_id,user_book_id,summary_text)
  values(a,ub,'__malfa_rls_menara__') returning id into summary_id;
  insert into public.contributions(user_id,text) values(a,'__malfa_rls_contribution__');
  insert into storage.objects(bucket_id,name,owner,owner_id,metadata)
  values('book-covers',a::text||'/__rls__/cover.jpg',a,a::text,'{"mimetype":"image/jpeg"}'::jsonb);
  insert into storage.objects(bucket_id,name,owner,owner_id,metadata)
  values('journey-audio',a::text||'/__rls__/recording.webm',a,a::text,'{"mimetype":"audio/webm"}'::jsonb);

  insert into public.auth_events(user_id,event_type,status,device,platform)
  values(b,'sign_in','success','rls-test','web');
  if not exists(select 1 from public.auth_events where user_id=a and device='rls-test') then
    raise exception 'auth event user id was forgeable';
  end if;

  insert into public.reading_invites(user_book_id,from_user_id,to_user_id,status)
  values(ub,a,b,'pending') returning id into v_invite_id;

  begin
    insert into public.user_books(owner_id,title) values(b,'__forged_owner__');
    raise exception 'A inserted B user book';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.library_entries(user_id,user_book_id,status,page) values(b,ub,'reading',1);
    raise exception 'A inserted B library row';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.journey_entries(user_id,user_book_id,note) values(b,ub,'forged');
    raise exception 'A inserted B journey row';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.journey_summary_sources(summary_id,entry_id,paragraph_index) values(summary_id,entry_id,0);
    raise exception 'client wrote server-only Menara provenance';
  exception when insufficient_privilege then null;
  end;
end $$;

reset role;
select set_config('request.jwt.claim.sub',(select account_b::text from malfa_rls_users),true);
select set_config('request.jwt.claim.role','authenticated',true);
set local role authenticated;

do $$
declare
  a uuid := (select account_a from malfa_rls_users);
  b uuid := (select account_b from malfa_rls_users);
  ub uuid;
  v_invite_id uuid;
  affected integer;
begin
  if auth.uid() is distinct from b then raise exception 'account B claim failed'; end if;
  if (select count(*) from public.profiles where id=a) <> 0 then raise exception 'B can read A profile directly'; end if;
  if (select count(*) from public.user_books where title='__malfa_rls_book__') <> 0 then raise exception 'B can read A book'; end if;
  if (select count(*) from public.library_entries where user_id=a) <> 0 then raise exception 'B can read A library'; end if;
  if (select count(*) from public.journey_entries where note='__malfa_rls_note__') <> 0 then raise exception 'B can read A journey'; end if;
  if (select count(*) from public.collections where title='__malfa_rls_collection__') <> 0 then raise exception 'B can read A collection'; end if;
  if (select count(*) from public.journey_summaries where summary_text='__malfa_rls_menara__') <> 0 then raise exception 'B can read A private Menara'; end if;
  if (select count(*) from public.contributions where text='__malfa_rls_contribution__') <> 0 then raise exception 'B can read A contribution'; end if;
  if (select count(*) from public.auth_events where device='rls-test') <> 0 then raise exception 'B can read private auth events'; end if;
  if (select count(*) from storage.objects where name like a::text||'/%') <> 0 then raise exception 'B can read A storage'; end if;

  select id into ub from public.user_books where title='__malfa_rls_book__';
  if ub is not null then raise exception 'B resolved A private book id'; end if;

  update public.library_entries set page=99 where user_id=a;
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'B updated A library'; end if;
  delete from public.journey_entries where note='__malfa_rls_note__';
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'B deleted A journey'; end if;
  update public.collections set title='forged' where title='__malfa_rls_collection__';
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'B updated A collection'; end if;
  delete from public.journey_summaries where summary_text='__malfa_rls_menara__';
  get diagnostics affected = row_count;
  if affected <> 0 then raise exception 'B deleted A Menara'; end if;
  begin
    insert into storage.objects(bucket_id,name,owner,owner_id,metadata)
    values('book-covers',a::text||'/__rls__/forged.jpg',b,b::text,'{"mimetype":"image/jpeg"}'::jsonb);
    raise exception 'B inserted into A storage folder';
  exception when insufficient_privilege then null;
  end;

  if not exists(select 1 from public.search_profiles('MALFA RLS Probe') where id=a) then
    raise exception 'discoverable profile search failed';
  end if;

  select id into v_invite_id from public.reading_invites where from_user_id=a and to_user_id=b and status='pending';
  if v_invite_id is null then raise exception 'recipient cannot read invitation'; end if;
  begin
    update public.reading_invites set from_user_id=b where id=v_invite_id;
    raise exception 'recipient changed invitation identity';
  exception when insufficient_privilege then null;
  end;
  update public.reading_invites set status='accepted' where id=v_invite_id;
  get diagnostics affected = row_count;
  if affected <> 1 then raise exception 'recipient cannot accept invitation'; end if;
  if not exists(select 1 from public.shared_reading_progress() sp where sp.invite_id=v_invite_id and sp.other_user_id=a and sp.page=12) then
    raise exception 'authorized shared progress failed';
  end if;
end $$;

reset role;
rollback;

select 'RLS TWO-ACCOUNT CRUD OK' as result;
