-- QuickSlot seed data
-- Run AFTER schema.sql, in Supabase SQL editor

-- Hardcoded test users (stable UUIDs so the Flutter app can reference them safely)
insert into users (id, name, email) values
  ('11111111-1111-1111-1111-111111111111', 'Alice', 'alice@quickslot.test'),
  ('22222222-2222-2222-2222-222222222222', 'Bob',   'bob@quickslot.test'),
  ('33333333-3333-3333-3333-333333333333', 'Charlie', 'charlie@quickslot.test')
on conflict (id) do nothing;

-- 4 venues: 2 badminton, 2 turf
insert into venues (id, name, sport, location, price_per_hour) values
  ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'SmashKing Badminton Arena', 'badminton', 'Indiranagar, Bangalore',  400),
  ('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'GreenField Turf',           'turf',      'Koramangala, Bangalore', 1200),
  ('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Shuttle Hub',               'badminton', 'HSR Layout, Bangalore',   350),
  ('dddddddd-dddd-dddd-dddd-dddddddddddd', 'TurfMaster Sports',         'turf',      'Whitefield, Bangalore',  1500)
on conflict (id) do nothing;
