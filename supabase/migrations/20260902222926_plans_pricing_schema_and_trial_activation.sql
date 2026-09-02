-- Extend plans with the real fields a pricing UI needs. price_amount is
-- numeric (SAR), null on the free tier. is_trial_pricing marks every row as
-- not-yet-final pricing (per explicit product decision — no payment
-- processor exists yet), queryable by the client rather than only a UI label.
alter table public.plans
  add column price_amount numeric null check (price_amount is null or price_amount >= 0),
  add column currency text not null default 'SAR',
  add column billing_period text null check (billing_period is null or billing_period in ('month','year')),
  add column tagline text null,
  add column features jsonb not null default '[]'::jsonb,
  add column is_recommended boolean not null default false,
  add column sort_order integer not null default 0,
  add column is_trial_pricing boolean not null default false;

-- Pricing must be visible to signed-out visitors on the homepage too.
create policy plans_anon_select on public.plans for select to anon using (true);

insert into public.plans (id, name, status, price_amount, currency, billing_period, tagline, features, is_recommended, sort_order, is_trial_pricing) values
('free', 'مجاني', 'active', 0, 'SAR', null,
  'كل أساسيات القراءة، بلا حدود.',
  '["أضف كتبك بلا حد", "سجّل رحلتك صوتيًا أو كتابيًا", "حتى 3 منارات كل شهر", "مزامنة كاملة بين الجوال والويب"]'::jsonb,
  false, 1, true),
('malfa-plus-monthly', 'مَلفى+ شهري', 'active', 19, 'SAR', 'month',
  'لقارئ يرجع لمَلفى كل أسبوع.',
  '["كل مزايا الباقة المجانية", "منارة بلا حدود", "دعم مباشر لتطوير مَلفى"]'::jsonb,
  false, 2, true),
('malfa-plus-annual', 'مَلفى+ سنوي', 'active', 149, 'SAR', 'year',
  'نفس المزايا، بأقل من نص السعر الشهري.',
  '["كل مزايا مَلفى+ الشهري", "وفّر أكثر من 30% مقارنة بالاشتراك الشهري"]'::jsonb,
  true, 3, true);

-- Real usage log for the one honest free/paid differentiator that exists in
-- the product today: منارة calls a paid LLM API, everything else is just
-- database rows. Written only by summarize-journey (service role); read by
-- its own owner to show "X of Y this month".
create table public.menara_generation_log (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
alter table public.menara_generation_log enable row level security;
alter table public.menara_generation_log force row level security;
create policy menara_generation_log_owner_select on public.menara_generation_log
  for select to authenticated using (user_id = auth.uid());
-- no insert/update/delete policy for authenticated/anon: only the
-- service-role Edge Function writes here.

create or replace function public.my_menara_usage_this_month()
returns integer
language sql
stable
security definer
set search_path to 'public'
as $$
  select count(*)::integer from public.menara_generation_log
  where user_id = auth.uid()
    and created_at >= date_trunc('month', now());
$$;
revoke execute on function public.my_menara_usage_this_month() from anon;
grant execute on function public.my_menara_usage_this_month() to authenticated;

-- Self-service "trial activation" — a real row, honestly labelled as a
-- trial with no payment taken (there is no payment processor integrated).
-- SECURITY DEFINER so the write path is centralized/validated server-side
-- rather than opening a broad client insert policy on user_plans.
create or replace function public.activate_trial_plan(target_plan_id text)
returns public.user_plans
language plpgsql
security definer
set search_path to 'public'
as $$
declare
  p public.plans;
  row_out public.user_plans;
  span interval;
begin
  if auth.uid() is null then
    raise exception 'must be signed in' using errcode = '42501';
  end if;
  select * into p from public.plans where id = target_plan_id and status = 'active';
  if not found then
    raise exception 'unknown plan' using errcode = '22023';
  end if;
  span := case p.billing_period when 'year' then interval '1 year' when 'month' then interval '1 month' else null end;
  insert into public.user_plans (user_id, plan_id, status, start_date, expiry_date, renewal_status)
  values (auth.uid(), p.id, case when p.price_amount is null or p.price_amount = 0 then 'active' else 'trial' end,
    now(), case when span is null then null else now() + span end,
    case when p.price_amount is null or p.price_amount = 0 then null else 'trial_no_payment' end)
  on conflict (user_id) do update set
    plan_id = excluded.plan_id, status = excluded.status, start_date = excluded.start_date,
    expiry_date = excluded.expiry_date, renewal_status = excluded.renewal_status
  returning * into row_out;
  insert into public.auth_events (user_id, event_type, status, device, platform)
  values (auth.uid(), 'plan_change', 'success', 'web', 'web');
  return row_out;
end;
$$;
revoke execute on function public.activate_trial_plan(text) from anon;
grant execute on function public.activate_trial_plan(text) to authenticated;
