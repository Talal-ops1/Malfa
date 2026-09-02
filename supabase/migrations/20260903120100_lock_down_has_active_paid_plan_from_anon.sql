-- This project grants EXECUTE to anon directly on new public-schema
-- functions (likely via ALTER DEFAULT PRIVILEGES set up early on), which a
-- "revoke ... from public" alone does not remove — anon needs its own
-- explicit revoke too. Same class of gotcha as the PUBLIC-pseudo-role bug
-- already documented for activate_trial_plan/my_menara_usage_this_month;
-- this is the anon-direct-grant variant of the same lesson.
revoke execute on function public.has_active_paid_plan(uuid) from anon;
revoke execute on function public.has_active_paid_plan(uuid) from public;
grant execute on function public.has_active_paid_plan(uuid) to authenticated;

revoke execute on function public.shared_reading_progress() from anon;
revoke execute on function public.shared_reading_progress() from public;
grant execute on function public.shared_reading_progress() to authenticated;
