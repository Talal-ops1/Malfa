-- CREATE FUNCTION grants EXECUTE to the PUBLIC pseudo-role by default, which
-- anon inherits through regardless of a targeted "revoke ... from anon" —
-- has to be revoked from PUBLIC explicitly, then re-granted to authenticated.
revoke execute on function public.activate_trial_plan(text) from public;
grant execute on function public.activate_trial_plan(text) to authenticated;
revoke execute on function public.my_menara_usage_this_month() from public;
grant execute on function public.my_menara_usage_this_month() to authenticated;
