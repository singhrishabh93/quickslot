# QuickSlot

Live sports slot booking. Flutter app + NestJS/Supabase backend.
Built for the Swades AI hiring hackathon — Wed 10 June 2026, 3-hour live build (extended into the same evening for polish + bonus).

The hard rule from the brief: **a slot can never be double-booked.** If two devices tap "Book" on the same slot at the same instant, exactly one succeeds, the other gets a clear in-app message. This README is mostly about how that rule is enforced and how I'd defend the choices.

---

## Live

| | |
|---|---|
| **Backend** | https://quickslot-api.onrender.com |
| **Swagger docs** | https://quickslot-api.onrender.com/api/docs |
| **Repo** | https://github.com/singhrishabh93/quickslot |

Render free tier sleeps after 15 min idle — first request may take ~50s.

---

## Screens

| Login | Venues | Venue detail |
|---|---|---|
| ![](docs/screenshots/01-login.png) | ![](docs/screenshots/02-venues.png) | ![](docs/screenshots/03-detail.png) |

| Confirm sheet | My bookings | Slot taken |
|---|---|---|
| ![](docs/screenshots/04-confirm.png) | ![](docs/screenshots/05-my-bookings.png) | ![](docs/screenshots/06-slot-taken.png) |

---

## The 30-second demo

```bash
# 20 parallel attempts on the same slot → exactly one 201, nineteen 409
seq 1 20 | xargs -P20 -I{} curl -s -o /dev/null -w "%{http_code}\n" \
  -X POST -H "X-User-Id: 11111111-1111-1111-1111-111111111111" \
  -H "Content-Type: application/json" \
  -d '{"venue_id":"aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa","slot_start_utc":"2026-06-11T13:30:00.000Z"}' \
  https://quickslot-api.onrender.com/bookings | sort | uniq -c
```

Expected: `1 201` and `19 409`. Run on a fresh `slot_start_utc` each time.

The live two-device version: open the venue detail screen on two simulators (or one simulator + one physical phone). Tap an open slot on device A → confirm. Device B's tile flips to "BOOKED" within ~1 second (Supabase Realtime). Tap the same slot on device B → "This slot was just taken" snackbar + grid auto-refresh.

---

## Stack

- **Mobile**: Flutter 3.27, `flutter_bloc` (cubits), `get_it` DI, `dio` with `X-User-Id` interceptor, `auto_route`, `supabase_flutter` (Realtime only), `google_fonts` (Bebas Neue display, IBM Plex Sans/Mono body).
- **Backend**: NestJS 11 (TypeScript), `@supabase/supabase-js` client, `class-validator` DTOs, Swagger/OpenAPI.
- **DB**: Supabase Postgres (managed).
- **Hosting**: Render (free tier, blueprint-deployed from `server/render.yaml`).

---

## Architecture (one paragraph)

Clean architecture, three layers each side. Flutter: `data/` (network → repositories → models, returning a sealed `Result<T, Failure>`), `modules/<feature>/` (cubit + state + views + widgets per feature — no business logic in widgets, sealed/single-state cubits chosen per case), `app/` (theme, router), `router/` (auto_route with type-safe args). DI is split into `service_locator` → `api_locator` / `repository_locator` / `cubit_locator` so each layer registers its own. Backend: `controllers → services → SupabaseService` with an `X-User-Id` guard, global validation pipe, and one centralised concurrency mechanism. The Flutter app calls REST via dio for reads/writes and subscribes to Supabase Realtime channels for live slot updates — the channel access path is independent of REST and uses the anon key, not the service-role key.

```
[Flutter app] --REST/dio (X-User-Id)-->  [NestJS on Render] --service_role--> [Supabase Postgres]
      |                                                                              ^
      +-- WebSocket via supabase_flutter (anon key) -----> [Supabase Realtime] -------+
```

---

## The concurrency story (the headline)

The guarantee lives in the database, not the app code:

```sql
create unique index bookings_one_active_per_slot
  on bookings (venue_id, slot_start_utc)
  where status = 'confirmed';
```

A *partial* unique index — it only constrains rows where `status='confirmed'`. The booking handler is three lines:

```ts
const { data, error } = await this.supabase.client
  .from('bookings')
  .insert({ user_id, venue_id, slot_start_utc, status: 'confirmed' })
  .select('*, venue:venues(...)').single();

if (error?.code === '23505') throw new ConflictException('SLOT_TAKEN');
```

Postgres serialises the unique check atomically. Twenty concurrent inserts → one wins, nineteen get `23505` → mapped to HTTP 409 with body `{"message":"SLOT_TAKEN"}`. Cancel sets `status='cancelled'`, the partial index ignores it, the slot becomes bookable again — `BookingStatus` flips back to confirmed on the next successful insert. No app-level locks, no race window, no `SELECT … FOR UPDATE` ceremony. The whole concurrency surface is one index and one `if` clause.

The Flutter side completes the loop: `BookingsRepository.createBooking` catches `DioException`, maps `statusCode == 409` to a typed `SlotTakenFailure`, the cubit emits `CreateBookingFailureState(SlotTakenFailure)`, the confirm sheet pops with `BookingSheetResult.slotTaken`, the page shows a snackbar and triggers `VenueDetailCubit.refresh()`. Type-driven from the database error code through to the UI message.

---

## Live updates (bonus)

`BookingEventsService.watchVenue(venueId)` exposes a `Stream<BookingEvent>` over Supabase Realtime Postgres Changes filtered by `venue_id`. `VenueDetailCubit` subscribes in `init()`, flips matching slots on insert (`BookingConfirmed`) or update→cancelled (`BookingFreed`), unsubscribes in `close()`. Slot matching is by millisecond-precise UTC timestamp so events for slots outside the current view (different date selected) are silently dropped. No polling.

---

## Setup

### Backend

```bash
cd server
cp .env.example .env
# Fill SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in .env

npm install
# Apply server/db/schema.sql and server/db/seed.sql in Supabase SQL editor
# Enable Realtime on the `bookings` table (Database → Publications → supabase_realtime → add bookings)
# Enable RLS on bookings + add anon SELECT policy (see below)

npm run start:dev
# http://localhost:3000/health → "supabase":"connected"
# http://localhost:3000/api/docs → Swagger UI
```

Required RLS policy for Realtime (run once in Supabase SQL editor):

```sql
alter table public.bookings enable row level security;
create policy "anon read bookings"
  on public.bookings for select to anon using (true);
```

The backend uses the service-role key which bypasses RLS, so writes/cancels keep working unchanged.

### Flutter app

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
# Set lib/data/network/supabase_config.dart anonKey to your project's anon/publishable key
flutter run
```

`lib/data/network/endpoint.dart` points at the deployed Render URL by default — change to `http://localhost:3000` (or `10.0.2.2` on Android emulator) for local backend dev.

---

## What I cut and why

- **No real auth.** Brief said "hardcoded users + X-User-Id is acceptable, do not burn time on full auth." Three seeded users, login = picker, header = identity. Owner checks on `DELETE /bookings/:id` and `GET /users/:id/bookings` (403 if header doesn't match), but no JWTs.
- **No payment.** Brief doesn't require it. A bookings model with `price_per_hour * 1` is enough for the rubric.
- **No bottom nav.** Considered for polish — concluded the editorial direction reads cleaner with an app-bar action (`event_note` icon) than a competing tab bar. App is shallow enough (4 screens) that a tab bar would be visual noise without information gain.
- **No offline cache.** Bonus item I deprioritised against Realtime, which I judged the higher-impact demo win.
- **No password / signup flow.** Considered briefly, rejected — brief is explicit about not burning time here. Adding it would have signalled I didn't read the brief.

---

## With one more day

- **Slot filter chips** — Morning / Afternoon / Evening on the venue detail page (one of the listed bonus items I had to skip for time).
- **Unit + widget tests** — at minimum `BookingsService.create` mocking `SupabaseService` to verify the `23505 → ConflictException` mapping is exercised, plus a widget test that the confirm sheet pops with `BookingSheetResult.slotTaken` when the cubit emits the failure state. Another listed bonus.
- **Dockerised backend** — `server/Dockerfile` + add to `render.yaml` for portable demos / offline judging.
- **Optimistic slot update on confirm** — currently we wait for the 201 to refresh the grid; a brief optimistic flip would feel snappier.
- **Replace the deprecated `anonKey` warning** with the new `publishableKey` parameter throughout (already done in main.dart, but worth a documentation note).
- **Backend timezone configurability** — IST offset is hardcoded; production would store `venues.timezone` and convert per-venue.

---

## AI usage note

I used AI (Claude) throughout — for scaffolding, design pattern boilerplate, code review on the concurrency strategy, and to keep momentum across the Flutter ↔ backend context-switch. Every line in this repo I reviewed and understood before committing; commits are scoped per feature so the history reads as actual decision points rather than a single dump.

**One thing I caught:** Realtime didn't fire even though my channel subscription returned `RealtimeSubscribeStatus.subscribed` and inserts were succeeding (201). The AI suggestion was that the subscription was working since the status was green; my instinct was that Supabase had tightened broadcast permissions at some point in the last year. I added subscribe-status and per-payload `dart:developer` logs to the `BookingEventsService`, confirmed the channel reached `subscribed` but no `INSERT received` log ever fired, and traced it to Supabase's requirement that **Postgres Changes broadcasts require RLS enabled on the table with an explicit SELECT policy for the subscribing role** — even when the source-of-truth writes come from a service-role client that bypasses RLS. Fixed with a five-line SQL block (`enable row level security` + `create policy "anon read bookings" … for select to anon using (true)`). The backend keeps working because service-role bypasses RLS by design. The diagnostic logs are still in `lib/data/network/booking_events_service.dart` for transparency during the defense round.

---

## Repo layout

```
swades_hackathon_project/
├── lib/                    # Flutter app
│   ├── app/                # theme, view (MaterialApp.router), widgets (skeleton, empty/error)
│   ├── data/               # network, models, api, repositories, di, local, utils
│   ├── modules/            # login, venues, bookings (each: cubit/, models/, views/, widgets/)
│   ├── router/             # auto_route
│   ├── bootstrap.dart
│   └── main.dart
├── server/                 # NestJS backend
│   ├── src/
│   │   ├── common/         # supabase service, auth guard, utils
│   │   ├── health/         # GET /health
│   │   ├── users/          # GET /users
│   │   ├── venues/         # GET /venues, GET /venues/:id/slots
│   │   └── bookings/       # POST /bookings, DELETE /bookings/:id, GET /users/:id/bookings
│   ├── db/                 # schema.sql, seed.sql
│   ├── render.yaml         # Render Blueprint config
│   └── .env.example
├── docs/screenshots/
└── README.md
```

---

## Commit history

`git log --oneline` shows feature-scoped commits at ~30-minute intervals. No "WIP" or "fix stuff", no single end-of-day dump — per the brief's explicit rule.
