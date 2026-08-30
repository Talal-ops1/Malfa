begin;

-- Trigger functions execute through their trigger owner and must never be
-- callable as public RPC endpoints.
revoke all on function public.secure_auth_event() from public, anon, authenticated;
grant execute on function public.secure_auth_event() to service_role;

commit;
