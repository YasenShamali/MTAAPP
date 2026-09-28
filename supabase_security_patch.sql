-- ============================================================
-- MTA_APP — security hardening patch
-- Apply in Supabase Dashboard -> SQL Editor -> Run.
-- Idempotent: safe to run more than once.
-- ============================================================

-- ------------------------------------------------------------
-- 1) users: stop allowing self-deletion
-- ------------------------------------------------------------
-- offers.sales_officer_id is ON DELETE CASCADE, and so are
-- offer_history.performed_by and request_media.uploaded_by. The previous
-- policy let any authenticated user delete their own profile row, which
-- silently and permanently destroyed every order they had ever created
-- (plus its history and media). Profile removal is now admin-only.
drop policy if exists "Users can delete their own record" on users;
drop policy if exists "Responsible officers can delete user profiles" on users;

create policy "Responsible officers can delete user profiles"
on users for delete
using (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and u.role = 'responsible_officer'
  )
);

-- ------------------------------------------------------------
-- 2) users: safe cross-user profile lookup
-- ------------------------------------------------------------
-- The app needs a reviewer's display name and role to label rejected
-- orders, but must not be able to read anyone's email, phone or auth_id.
-- A security-definer projection keeps the table itself private while making
-- the lookup possible. Returns only id / full_name / role.
create or replace function public.profile_summary(p_user_id uuid)
returns table (
  id uuid,
  full_name text,
  role user_role
)
language sql
stable
security definer
set search_path = public
as $$
  select u.id, u.full_name, u.role
  from public.users u
  where u.id = p_user_id;
$$;

revoke all on function public.profile_summary(uuid) from public;
grant execute on function public.profile_summary(uuid) to authenticated;

-- ------------------------------------------------------------
-- 3) offers: block edits to finished orders
-- ------------------------------------------------------------
-- The role-based branch previously included 'approved', 'rejected',
-- 'completed' and 'cancelled', so any factory / installation officer could
-- rewrite an order that was already finished. It is now limited to the
-- statuses where a reviewer actually has work to do. The ownership branches
-- (creator, requester, current assignee, supervisor) are unchanged, so the
-- shared review queue keeps working.
drop policy if exists "Users can update related offers" on offers;

create policy "Users can update related offers"
on offers for update
using (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and (
        u.role = 'responsible_officer'
        or sales_officer_id = u.id
        or requester_id = u.id
        or assigned_to = u.id
        or (
          assigned_role = u.role
          and status in ('pending_factory', 'pending_installation', 'in_progress', 'pending_resubmission')
        )
      )
  )
)
with check (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and (
        u.role = 'responsible_officer'
        or sales_officer_id = u.id
        or requester_id = u.id
        or assigned_to = u.id
        or (
          assigned_role = u.role
          and status in ('pending_factory', 'pending_installation', 'in_progress', 'pending_resubmission')
        )
      )
  )
);

-- ------------------------------------------------------------
-- 4) offer_history: match the offers visibility rules
-- ------------------------------------------------------------
-- The old policy only matched sales_officer_id and factory_officer_id, so
-- supervisors, the requester, the current assignee and the installation /
-- wood-factory stages could not read the audit trail of orders they are
-- legitimately involved in.
drop policy if exists "Related users can select offer history" on offer_history;

create policy "Related users can select offer history"
on offer_history for select
using (
  exists (
    select 1
    from offers o
    join users u on u.auth_id = auth.uid()::text
    where o.id = offer_id
      and (
        u.role = 'responsible_officer'
        or o.sales_officer_id = u.id
        or o.requester_id = u.id
        or o.assigned_to = u.id
        or o.factory_officer_id = u.id
        or o.assigned_role = u.role
      )
  )
);
