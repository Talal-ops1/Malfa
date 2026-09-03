-- 4th recurrence of the "revoke from anon != revoke from PUBLIC" bug in this
-- project (see has_active_paid_plan / activate_trial_plan / summarize-journey
-- migrations for the first 3). enforce_collection_book_owner() had anon and
-- authenticated explicitly revoked but never PUBLIC, so anon still inherited
-- EXECUTE through the PUBLIC pseudo-role. Low real-world exploitability (it's
-- a trigger function, so a direct RPC call errors out) but closes the pattern
-- for good.
revoke execute on function public.enforce_collection_book_owner() from public;

-- has_active_paid_plan(uuid) was correctly locked to authenticated-only, but
-- had no relationship check, letting any signed-in user probe an arbitrary
-- user's paid-plan status. Scope it to: the caller's own id, or a user the
-- caller has an existing reading_invites relationship with (sender or
-- recipient, any status) — the only two legitimate call patterns already
-- used by invites_sender_insert / invites_recipient_update / shared_reading_progress().
create or replace function public.has_active_paid_plan(target_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path to 'public'
as $$
  select
    auth.uid() is not null
    and (
      target_user_id = auth.uid()
      or exists (
        select 1 from public.reading_invites
        where (from_user_id = auth.uid() and to_user_id = target_user_id)
           or (to_user_id = auth.uid() and from_user_id = target_user_id)
      )
    )
    and exists (
      select 1 from public.user_plans
      where user_id = target_user_id
        and plan_id <> 'free'
        and status in ('active','trial')
        and (expiry_date is null or expiry_date > now())
    );
$$;
revoke execute on function public.has_active_paid_plan(uuid) from anon;
revoke execute on function public.has_active_paid_plan(uuid) from public;
grant execute on function public.has_active_paid_plan(uuid) to authenticated;
