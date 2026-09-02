-- activate_trial_plan() upserts on user_id, expecting exactly one current
-- plan row per user (matches how the admin dashboard already reads this
-- table — one active row assumed per user). No existing rows to conflict
-- with (table was empty).
alter table public.user_plans add constraint user_plans_user_id_uq unique (user_id);
