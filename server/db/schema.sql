-- QuickSlot schema
-- Run in Supabase SQL editor (Project → SQL Editor → New query → paste → Run)

create table if not exists venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sport text not null check (sport in ('badminton', 'turf')),
  location text not null,
  price_per_hour integer not null check (price_per_hour >= 0),
  opens_at_hour integer not null default 6 check (opens_at_hour between 0 and 23),
  closes_at_hour integer not null default 22 check (closes_at_hour between 1 and 24 and closes_at_hour > opens_at_hour),
  created_at timestamptz not null default now()
);

create table if not exists users (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists bookings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(id) on delete restrict,
  venue_id uuid not null references venues(id) on delete restrict,
  slot_start_utc timestamptz not null,
  status text not null check (status in ('confirmed', 'cancelled')),
  created_at timestamptz not null default now(),
  cancelled_at timestamptz
);

-- The concurrency guarantee:
-- exactly one CONFIRMED booking can exist per (venue, slot_start).
-- A cancelled row is ignored, so the slot frees up on cancel.
create unique index if not exists bookings_one_active_per_slot
  on bookings (venue_id, slot_start_utc)
  where status = 'confirmed';

create index if not exists bookings_user_created_idx
  on bookings (user_id, created_at desc);

create index if not exists bookings_venue_slot_idx
  on bookings (venue_id, slot_start_utc)
  where status = 'confirmed';
