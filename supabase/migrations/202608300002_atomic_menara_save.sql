begin;

-- Save the generated Menara and its paragraph-to-journey provenance in one
-- database transaction. Only the server-side service role may call this.
create or replace function public.save_menara_with_sources(
  p_user_id uuid,
  p_book_id text,
  p_user_book_id uuid,
  p_summary_text text,
  p_source_map jsonb
)
returns public.journey_summaries
language plpgsql
security definer
set search_path = public
as $$
declare
  saved public.journey_summaries;
  source_item jsonb;
  source_value jsonb;
  source_entry_id uuid;
  source_index integer;
  expected_paragraphs integer;
  mapped_paragraphs integer;
begin
  if p_user_id is null
     or ((p_book_id is null) = (p_user_book_id is null))
     or p_summary_text is null
     or length(btrim(p_summary_text)) < 1
     or length(p_summary_text) > 12000
     or jsonb_typeof(p_source_map) <> 'array'
     or jsonb_array_length(p_source_map) < 1
     or jsonb_array_length(p_source_map) > 21 then
    raise exception 'invalid_menara_payload';
  end if;

  expected_paragraphs := array_length(
    regexp_split_to_array(btrim(p_summary_text), E'\\n+'), 1
  );
  if expected_paragraphs is distinct from jsonb_array_length(p_source_map) then
    raise exception 'invalid_source_map';
  end if;

  select count(distinct (item.value->>'paragraph_index')::integer)
  into mapped_paragraphs
  from jsonb_array_elements(p_source_map) item;
  if mapped_paragraphs is distinct from expected_paragraphs then
    raise exception 'duplicate_paragraph_source_map';
  end if;

  for source_item in select value from jsonb_array_elements(p_source_map)
  loop
    if jsonb_typeof(source_item) <> 'object'
       or jsonb_typeof(source_item->'source_ids') <> 'array'
       or jsonb_array_length(source_item->'source_ids') < 1 then
      raise exception 'invalid_source_map';
    end if;

    source_index := (source_item->>'paragraph_index')::integer;
    if source_index < 0 or source_index >= expected_paragraphs then
      raise exception 'invalid_source_map';
    end if;

    for source_value in select value from jsonb_array_elements(source_item->'source_ids')
    loop
      source_entry_id := trim(both '"' from source_value::text)::uuid;
      if not exists (
        select 1
        from public.journey_entries entry
        where entry.id = source_entry_id
          and entry.user_id = p_user_id
          and entry.book_id is not distinct from p_book_id
          and entry.user_book_id is not distinct from p_user_book_id
      ) then
        raise exception 'unauthorized_source_entry';
      end if;
    end loop;
  end loop;

  select summary.* into saved
  from public.journey_summaries summary
  where summary.user_id = p_user_id
    and summary.book_id is not distinct from p_book_id
    and summary.user_book_id is not distinct from p_user_book_id
  for update;

  if saved.id is null then
    insert into public.journey_summaries (
      user_id, book_id, user_book_id, summary_text, updated_at
    ) values (
      p_user_id, p_book_id, p_user_book_id, p_summary_text, now()
    ) returning * into saved;
  else
    update public.journey_summaries
    set summary_text = p_summary_text, updated_at = now()
    where id = saved.id
    returning * into saved;
  end if;

  delete from public.journey_summary_sources where summary_id = saved.id;

  insert into public.journey_summary_sources (summary_id, entry_id, paragraph_index)
  select saved.id,
    trim(both '"' from source_id.value::text)::uuid,
    (paragraph.value->>'paragraph_index')::integer
  from jsonb_array_elements(p_source_map) paragraph
  cross join lateral jsonb_array_elements(paragraph.value->'source_ids') source_id;

  return saved;
end;
$$;

revoke all on function public.save_menara_with_sources(uuid, text, uuid, text, jsonb)
  from public, anon, authenticated;
grant execute on function public.save_menara_with_sources(uuid, text, uuid, text, jsonb)
  to service_role;

commit;
