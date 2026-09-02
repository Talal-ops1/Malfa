-- Real pricing structure (replaces the earlier clearly-labeled trial
-- prices): مجاني free, مَلفى+ 9.66 SAR/month, 96.60 SAR/year — 9.66 chosen
-- to echo Saudi Arabia's +966 country code, per explicit product direction.
-- No longer trial-labeled: these are the real prices to display everywhere,
-- pending nearest-permitted App Store price points on the native apps.
update public.plans set
  price_amount = 0, is_trial_pricing = false,
  tagline = 'كل أساسيات القراءة، بلا حدود.',
  features = '["إضافة الكتب وإدارة المكتبة","متابعة تقدم القراءة","روتين القراءة","أيام القراءة","كتابة «سجل رحلتك»","الإحصاءات الأساسية","المزامنة الأساسية بين الموقع والتطبيق"]'::jsonb
where id = 'free';

update public.plans set
  price_amount = 9.66, is_trial_pricing = false,
  tagline = 'لقارئ يرجع لمَلفى كل أسبوع.',
  features = '["كل مزايا الباقة المجانية","إنشاء «منارة» من سجل الرحلة","التسجيل الصوتي وتحويله إلى نص","صياغة «منارة» بصوت القارئ وضمير المتكلم","القراءة مع شخص","الإحصاءات المتقدمة","التصدير وتصاميم المشاركة","الحصاد السنوي عند توفره"]'::jsonb
where id = 'malfa-plus-monthly';

update public.plans set
  price_amount = 96.60, is_trial_pricing = false,
  tagline = 'نفس مزايا مَلفى+، بأقل من نص السعر الشهري.',
  features = '["كل مزايا مَلفى+ الشهري","شهران مجانًا مقارنة بالاشتراك الشهري","بسعر شهري فعلي أقل"]'::jsonb
where id = 'malfa-plus-annual';

-- Narrow, safe cross-user plan check for the shared-reading paywall: needs
-- SECURITY DEFINER since checking whether *another* user (an invite sender
-- or recipient) currently holds a paid plan requires reading past their own
-- user_plans row, which normal RLS would not allow. Returns only a boolean,
-- never plan details, so it cannot be used to leak another user's billing
-- data — only whether they're currently entitled to paid features.
create or replace function public.has_active_paid_plan(target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $$
  select exists(
    select 1 from public.user_plans
    where user_id = target_user_id
      and plan_id <> 'free'
      and status in ('active','trial')
      and (expiry_date is null or expiry_date > now())
  );
$$;
revoke execute on function public.has_active_paid_plan(uuid) from public;
grant execute on function public.has_active_paid_plan(uuid) to authenticated;

-- القراءة مع شخص is a مَلفى+ feature. Enforce it server-side, not only in
-- the client: sending an invite requires the sender to currently hold a
-- paid plan; accepting one requires BOTH participants to currently hold a
-- paid plan (declining stays open regardless, so a free recipient can
-- always dismiss an invite they can't act on). This replaces the RLS
-- policies from 202608300001_security_hardening.sql with paid-gated ones.
drop policy if exists invites_sender_insert on public.reading_invites;
create policy invites_sender_insert on public.reading_invites for insert to authenticated
  with check (
    from_user_id = auth.uid() and to_user_id <> auth.uid() and status = 'pending'
    and public.has_active_paid_plan(auth.uid())
  );

drop policy if exists invites_recipient_update on public.reading_invites;
create policy invites_recipient_update on public.reading_invites for update to authenticated
  using (to_user_id = auth.uid() and status = 'pending')
  with check (
    to_user_id = auth.uid()
    and (
      status = 'declined'
      or (status = 'accepted' and public.has_active_paid_plan(auth.uid()) and public.has_active_paid_plan(from_user_id))
    )
  );

-- Live shared-reading progress is only ever computed for pairs where BOTH
-- sides currently hold a paid plan — if either side's subscription lapses,
-- this simply stops returning that row (the underlying reading_invites and
-- library_entries/journey_entries rows are untouched, so access silently
-- restores the moment they resubscribe; nothing is ever deleted).
create or replace function public.shared_reading_progress()
returns table(invite_id uuid, other_user_id uuid, other_name text, book_id text, user_book_id uuid, page integer, status text)
language sql
stable security definer
set search_path to 'public'
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
    and public.has_active_paid_plan(i.from_user_id)
    and public.has_active_paid_plan(i.to_user_id)
$$;
