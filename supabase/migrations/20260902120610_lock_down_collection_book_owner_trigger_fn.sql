-- enforce_collection_book_owner() is a trigger function only; it has no
-- legitimate direct-RPC caller, matching the lockdown already applied to
-- the project's other trigger functions.
revoke execute on function public.enforce_collection_book_owner() from anon, authenticated;
