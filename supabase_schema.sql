-- Supabase SQL script to create the core database schema for the MTA_APP
-- Use this script in the Supabase SQL editor or CLI.

create extension if not exists "pgcrypto";

do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type user_role as enum (
      'sales_officer',
      'factory_officer',
      'company_officer',
      'responsible_officer'
    );
  end if;

  if not exists (select 1 from pg_type where typname = 'offer_status') then
    create type offer_status as enum (
      'draft',
      'submitted',
      'under_review',
      'approved',
      'rejected',
      'revised'
    );
  end if;
end $$;

alter type offer_status add value if not exists 'pending_factory';
alter type offer_status add value if not exists 'pending_installation';
alter type offer_status add value if not exists 'pending_resubmission';
alter type offer_status add value if not exists 'in_progress';
alter type offer_status add value if not exists 'cancelled';
alter type offer_status add value if not exists 'completed';
alter type user_role add value if not exists 'wood_factory_officer';

-- Important: some SQL runners execute this file in a single transaction.
-- Enum values must be committed before they can be used in later statements.
commit;

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  auth_id text unique not null,
  email text unique,
  phone text unique,
  full_name text,
  profile_image_url text,
  role user_role not null default 'sales_officer',
  created_at timestamptz not null default now(),
  constraint users_has_contact_info check (email is not null or phone is not null)
);

-- Keep existing databases aligned with current users constraints/defaults.
alter table users alter column role set default 'sales_officer';
alter table users alter column full_name set default 'User';
alter table users add column if not exists profile_image_url text;
update users
set full_name = 'User'
where btrim(coalesce(full_name, '')) = '';

-- Align existing databases that were created with older constraints.
alter table users alter column full_name drop not null;

create table if not exists offers (
  id uuid primary key default gen_random_uuid(),
  sales_officer_id uuid not null references users(id) on delete cascade,
  factory_officer_id uuid references users(id) on delete set null,
  requester_id uuid references users(id) on delete set null,
  reference_number text unique,
  sales_number text,
  request_type text not null default 'fabrication' check (request_type in ('fabrication', 'installation', 'both')),
  tile_code text,
  tile_image_url text,
  category text not null default 'kitchen',
  seller_name text not null default 'User',
  customer_name text not null default 'Customer',
  customer_phone text not null default '',
  customer_address text,
  customer_address_url text,
  pdf_url text,
  request_title text not null default 'New Request',
  handover_date date,
  assigned_role user_role,
  assigned_to uuid references users(id) on delete set null,
  reviewed_by uuid references users(id) on delete set null,
  last_reviewer_id uuid references users(id) on delete set null,
  needs_resubmission boolean not null default false,
  approved_at timestamptz,
  rejected_at timestamptz,
  cancelled_at timestamptz,
  cancellation_reason text,
  material text not null,
  quantity integer not null check (quantity > 0),
  unit text not null,
  unit_price numeric(14,2) not null check (unit_price >= 0),
  total_price numeric(16,2) generated always as (quantity * unit_price) stored,
  description text,
  status offer_status not null default 'draft',
  factory_comment text,
  rejection_reason text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table offers add column if not exists requester_id uuid references users(id) on delete set null;
alter table offers add column if not exists reference_number text;
alter table offers add column if not exists sales_number text;
alter table offers add column if not exists request_type text check (request_type in ('fabrication', 'installation', 'both'));
alter table offers add column if not exists tile_code text;
alter table offers add column if not exists tile_image_url text;
alter table offers add column if not exists category text;
alter table offers add column if not exists seller_name text;
alter table offers add column if not exists customer_name text;
alter table offers add column if not exists customer_phone text;
alter table offers add column if not exists customer_address text;
alter table offers add column if not exists customer_address_url text;
alter table offers add column if not exists pdf_url text;
alter table offers add column if not exists request_title text;
alter table offers add column if not exists handover_date date;
alter table offers add column if not exists assigned_role user_role;
alter table offers add column if not exists assigned_to uuid references users(id) on delete set null;
alter table offers add column if not exists reviewed_by uuid references users(id) on delete set null;
alter table offers add column if not exists last_reviewer_id uuid references users(id) on delete set null;
alter table offers add column if not exists needs_resubmission boolean;
alter table offers add column if not exists approved_at timestamptz;
alter table offers add column if not exists accepted_at timestamptz;
alter table offers add column if not exists rejected_at timestamptz;
alter table offers add column if not exists cancelled_at timestamptz;
alter table offers add column if not exists cancellation_reason text;
alter table offers add column if not exists rejected_by_name text;
alter table offers add column if not exists rejected_by_role text;
alter table offers add column if not exists edit_requested_by uuid references users(id) on delete set null;
alter table offers add column if not exists edit_request_reason text;
alter table offers add column if not exists edit_requested_at timestamptz;
alter table offers add column if not exists edit_approved boolean not null default false;

alter table offers alter column request_type set default 'fabrication';

-- Allow combined fabrication + installation requests ('both').
alter table offers drop constraint if exists offers_request_type_check;
alter table offers add constraint offers_request_type_check check (request_type in ('fabrication', 'installation', 'both'));
alter table offers alter column category set default 'kitchen';
alter table offers alter column seller_name set default 'User';
alter table offers alter column customer_name set default 'Customer';
alter table offers alter column customer_phone set default '';
alter table offers alter column request_title set default 'New Request';
alter table offers alter column needs_resubmission set default false;

update offers
set requester_id = sales_officer_id
where requester_id is null;

update offers
set reference_number = 'REQ-' || upper(left(replace(id::text, '-', ''), 8))
where btrim(coalesce(reference_number, '')) = '';

update offers
set request_type = 'fabrication'
where btrim(coalesce(request_type, '')) = '';

update offers
set category = 'kitchen'
where btrim(coalesce(category, '')) = '';

update offers
set seller_name = 'User'
where btrim(coalesce(seller_name, '')) = '';

update offers
set customer_name = 'Customer'
where btrim(coalesce(customer_name, '')) = '';

update offers
set customer_phone = ''
where customer_phone is null;

update offers
set request_title = coalesce(nullif(material, ''), 'New Request')
where btrim(coalesce(request_title, '')) = '';

update offers
set needs_resubmission = false
where needs_resubmission is null;

update offers
set assigned_role = case
  when request_type = 'installation' then 'company_officer'::user_role
  else 'factory_officer'::user_role
end
where assigned_role is null;

update offers
set status = case
  when request_type = 'installation' then 'pending_installation'::offer_status
  else 'pending_factory'::offer_status
end
where status = 'submitted';

update offers
set needs_resubmission = true
where status = 'rejected'
  and coalesce(rejection_reason, '') <> ''
  and needs_resubmission = false;

create table if not exists offer_history (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references offers(id) on delete cascade,
  performed_by uuid not null references users(id) on delete cascade,
  action text not null,
  comment text,
  from_status offer_status,
  to_status offer_status,
  created_at timestamptz not null default now()
);

create table if not exists audit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users(id) on delete set null,
  event_type text not null,
  details text,
  created_at timestamptz not null default now()
);

create table if not exists request_media (
  id uuid primary key default gen_random_uuid(),
  offer_id uuid not null references offers(id) on delete cascade,
  uploaded_by uuid not null references users(id) on delete cascade,
  stage text not null check (stage in ('tile', 'factory', 'installation', 'completion')),
  image_url text not null,
  note text,
  created_at timestamptz not null default now()
);

create index if not exists idx_request_media_offer_id on request_media(offer_id);

-- Sequential unique reference numbers (MT-0001, MT-0002, ...).
-- The counter is incremented atomically so no two offers get the same number.
create table if not exists reference_sequence (
  id int primary key default 1 check (id = 1),
  last_value bigint not null default 0
);

insert into reference_sequence (id, last_value)
select 1, (select count(*) from offers)
on conflict (id) do nothing;

update reference_sequence
set last_value = greatest(last_value, (select count(*) from offers))
where id = 1;

create or replace function public.next_reference_number()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  next_val bigint;
begin
  update reference_sequence
  set last_value = last_value + 1
  where id = 1
  returning last_value into next_val;

  if next_val is null then
    insert into reference_sequence (id, last_value)
    values (1, 1)
    on conflict (id) do update set last_value = reference_sequence.last_value + 1
    returning last_value into next_val;
  end if;

  return 'MT-' || lpad(next_val::text, 4, '0');
end;
$$;

revoke all on function public.next_reference_number() from public;
grant execute on function public.next_reference_number() to anon, authenticated;

-- Non-destructive preview: returns the next number WITHOUT incrementing the
-- counter. Used to display a stable number on the "new offer" screen; the
-- number is only actually reserved via next_reference_number() at submit time.
create or replace function public.current_reference_number()
returns text
language sql
security definer
set search_path = public
stable
as $$
  select 'MT-' || lpad((coalesce(last_value, 0) + 1)::text, 4, '0')
  from reference_sequence
  where id = 1;
$$;

revoke all on function public.current_reference_number() from public;
grant execute on function public.current_reference_number() to anon, authenticated;

-- Avatar storage bucket and policies.
insert into storage.buckets (id, name, public)
values ('user-avatars', 'user-avatars', true)
on conflict (id) do nothing;

insert into storage.buckets (id, name, public)
values ('request-media', 'request-media', true)
on conflict (id) do nothing;

drop policy if exists "Public can view avatars" on storage.objects;
create policy "Public can view avatars"
on storage.objects for select
using (bucket_id = 'user-avatars');

drop policy if exists "Users can upload their avatars" on storage.objects;
create policy "Users can upload their avatars"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'user-avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update their avatars" on storage.objects;
create policy "Users can update their avatars"
on storage.objects for update
to authenticated
using (
  bucket_id = 'user-avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'user-avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can delete their avatars" on storage.objects;
create policy "Users can delete their avatars"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'user-avatars'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Public can view request media" on storage.objects;
create policy "Public can view request media"
on storage.objects for select
using (bucket_id = 'request-media');

drop policy if exists "Users can upload request media" on storage.objects;
create policy "Users can upload request media"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'request-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can update request media" on storage.objects;
create policy "Users can update request media"
on storage.objects for update
to authenticated
using (
  bucket_id = 'request-media'
  and auth.uid()::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'request-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

drop policy if exists "Users can delete request media" on storage.objects;
create policy "Users can delete request media"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'request-media'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- Keep public.users in sync with newly created auth users.
-- This is idempotent and safe to re-run.
create or replace function public.sync_auth_user_to_public_users()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (auth_id, email, full_name, profile_image_url, role)
  values (
    new.id::text,
    new.email,
    coalesce(nullif(new.raw_user_meta_data ->> 'full_name', ''), 'User'),
    nullif(new.raw_user_meta_data ->> 'profile_image_url', ''),
    case
      when (new.raw_user_meta_data ->> 'role') in (
        'sales_officer',
        'factory_officer',
        'wood_factory_officer',
        'company_officer',
        'responsible_officer'
      ) then (new.raw_user_meta_data ->> 'role')::user_role
      else 'sales_officer'::user_role
    end
  )
  on conflict (auth_id) do update
  set
    email = excluded.email,
    full_name = coalesce(excluded.full_name, public.users.full_name),
    profile_image_url = coalesce(excluded.profile_image_url, public.users.profile_image_url);

  return new;
exception
  when others then
    -- Never block auth signup because of application-profile sync errors.
    return new;
end;
$$;

drop trigger if exists trg_sync_auth_user_to_public_users on auth.users;
drop trigger if exists trg_sync_auth_user on auth.users;
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.sync_auth_user_to_users();
drop function if exists public.handle_new_user();
create trigger trg_sync_auth_user_to_public_users
after insert on auth.users
for each row execute function public.sync_auth_user_to_public_users();

-- Backfill profiles for auth users that do not yet exist in public.users.
insert into public.users (auth_id, email, full_name, profile_image_url, role)
select
  a.id::text,
  a.email,
  coalesce(nullif(a.raw_user_meta_data ->> 'full_name', ''), 'User') as full_name,
  nullif(a.raw_user_meta_data ->> 'profile_image_url', '') as profile_image_url,
  case
    when (a.raw_user_meta_data ->> 'role') in (
      'sales_officer',
      'factory_officer',
      'wood_factory_officer',
      'company_officer',
      'responsible_officer'
    ) then (a.raw_user_meta_data ->> 'role')::user_role
    else 'sales_officer'::user_role
  end as role
from auth.users a
left join public.users u on u.auth_id = a.id::text
where u.auth_id is null;

-- Enable row level security if you intend to use Supabase Auth as the gatekeeper.
-- You can adapt these policies after the initial schema is created.

alter table users enable row level security;
drop policy if exists "Users can select their own record" on users;
drop policy if exists "Users can insert their own record" on users;
drop policy if exists "Users can update their own record" on users;
drop policy if exists "Users can delete their own record" on users;
create policy "Users can select their own record" on users for select using (auth_id = auth.uid()::text);
create policy "Users can insert their own record" on users for insert with check (auth_id = auth.uid()::text);
create policy "Users can update their own record" on users for update using (auth_id = auth.uid()::text) with check (auth_id = auth.uid()::text);
create policy "Users can delete their own record" on users for delete using (auth_id = auth.uid()::text);

alter table offers enable row level security;
drop policy if exists "Sales officer can insert own offers" on offers;
drop policy if exists "Sales officer can select own offers" on offers;
drop policy if exists "Factory officer can select offers assigned to them" on offers;
drop policy if exists "Sales officer can update draft or revised offers" on offers;
drop policy if exists "Users can select related offers" on offers;
drop policy if exists "Users can insert own requests" on offers;
drop policy if exists "Users can update related offers" on offers;
drop policy if exists "Responsible officers can delete offers" on offers;
create policy "Users can select related offers" on offers for select using (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and (
        u.role = 'responsible_officer'
        or sales_officer_id = u.id
        or requester_id = u.id
        or assigned_to = u.id
        or assigned_role = u.role
      )
  )
);
create policy "Users can insert own requests" on offers for insert with check (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and (
        u.role = 'responsible_officer'
        or sales_officer_id = u.id
        or requester_id = u.id
      )
  )
);
create policy "Users can update related offers" on offers for update using (
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
          and status in ('pending_factory', 'pending_installation', 'in_progress', 'pending_resubmission', 'approved', 'rejected', 'completed', 'cancelled')
        )
      )
  )
) with check (
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
          and status in ('pending_factory', 'pending_installation', 'in_progress', 'pending_resubmission', 'approved', 'rejected', 'completed', 'cancelled')
        )
      )
  )
);
create policy "Responsible officers can delete offers" on offers for delete using (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and u.role = 'responsible_officer'
  )
);

alter table offer_history enable row level security;
drop policy if exists "Users can insert offer history for their actions" on offer_history;
drop policy if exists "Related users can select offer history" on offer_history;
create policy "Users can insert offer history for their actions" on offer_history for insert with check (performed_by = (select id from users where auth_id = auth.uid()::text));
create policy "Related users can select offer history" on offer_history for select using (
  offer_id in (select id from offers where sales_officer_id = (select id from users where auth_id = auth.uid()::text) or factory_officer_id = (select id from users where auth_id = auth.uid()::text))
);

alter table audit_logs enable row level security;
drop policy if exists "Users can insert own audit logs" on audit_logs;
drop policy if exists "Users can select logs for their own actions" on audit_logs;
create policy "Users can insert own audit logs" on audit_logs for insert with check (user_id = (select id from users where auth_id = auth.uid()::text));
create policy "Users can select logs for their own actions" on audit_logs for select using (user_id = (select id from users where auth_id = auth.uid()::text));

alter table request_media enable row level security;
drop policy if exists "Users can select related request media" on request_media;
drop policy if exists "Users can insert request media" on request_media;
drop policy if exists "Users can update own request media" on request_media;
drop policy if exists "Responsible officers can delete request media" on request_media;
create policy "Users can select related request media" on request_media for select using (
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
        or o.assigned_role = u.role
      )
  )
);
create policy "Users can insert request media" on request_media for insert with check (
  uploaded_by = (select id from users where auth_id = auth.uid()::text)
  and exists (
    select 1
    from offers o
    join users u on u.auth_id = auth.uid()::text
    where o.id = offer_id
      and (
        u.role = 'responsible_officer'
        or o.sales_officer_id = u.id
        or o.requester_id = u.id
        or o.assigned_to = u.id
        or (
          o.assigned_role = u.role
          and o.status in ('pending_factory', 'pending_installation', 'in_progress', 'approved')
        )
      )
  )
);
create policy "Users can update own request media" on request_media for update using (
  uploaded_by = (select id from users where auth_id = auth.uid()::text)
) with check (
  uploaded_by = (select id from users where auth_id = auth.uid()::text)
);
create policy "Responsible officers can delete request media" on request_media for delete using (
  exists (
    select 1
    from users u
    where u.auth_id = auth.uid()::text
      and u.role = 'responsible_officer'
  )
);

-- ============================================================
-- Push notifications (Firebase Cloud Messaging)
-- ============================================================

-- Stores the FCM registration token for each device so the
-- push-notification edge function knows where to deliver messages.
create table if not exists device_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete cascade,
  token text not null unique,
  platform text not null default 'android',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_device_tokens_user_id on device_tokens(user_id);

alter table device_tokens enable row level security;

-- The app registers/unregisters its device token through these functions;
-- direct table access is not exposed to clients.
create or replace function public.upsert_device_token(p_token text, p_platform text)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
begin
  select id into v_user_id
  from public.users
  where auth_id = auth.uid()::text;

  if v_user_id is null then
    raise exception 'User profile not found';
  end if;

  insert into public.device_tokens (user_id, token, platform, updated_at)
  values (v_user_id, p_token, coalesce(p_platform, 'android'), now())
  on conflict (token)
  do update set
    user_id = excluded.user_id,
    platform = excluded.platform,
    updated_at = now();
end;
$$;

revoke all on function public.upsert_device_token from public;
grant execute on function public.upsert_device_token to authenticated;

create or replace function public.delete_device_token(p_token text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  delete from public.device_tokens dt
  where dt.token = p_token
    and dt.user_id in (
      select id from public.users where auth_id = auth.uid()::text
    );
end;
$$;

revoke all on function public.delete_device_token from public;
grant execute on function public.delete_device_token to authenticated;
