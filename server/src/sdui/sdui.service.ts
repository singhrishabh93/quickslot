import { Injectable, NotFoundException } from '@nestjs/common';
import { BookingsService } from '../bookings/bookings.service';
import { UsersService } from '../users/users.service';
import { VenuesService } from '../venues/venues.service';
import {
  BookingTileComponent,
  DateChipComponent,
  ScreenComponent,
  SduiAction,
  SlotTileComponent,
  UserCardComponent,
  VenueRowComponent,
} from './sdui.types';

const IST_OFFSET = '+05:30';

@Injectable()
export class SduiService {
  constructor(
    private readonly venuesService: VenuesService,
    private readonly usersService: UsersService,
    private readonly bookingsService: BookingsService,
  ) {}

  // ─────────────────────────────────────────────────────────────
  // /sdui/login
  // ─────────────────────────────────────────────────────────────
  async buildLoginScreen(): Promise<ScreenComponent> {
    const users = await this.usersService.list();

    const userCards: UserCardComponent[] = users.map((u) => ({
      type: 'user_card',
      user_id: u.id,
      name: u.name,
      email: u.email,
      on_tap: [
        { action: 'set_session', user_id: u.id, name: u.name },
        { action: 'replace_all', to: '/venues' },
      ],
    }));

    return {
      type: 'screen',
      title: 'QUICKSLOT',
      children: [
        { type: 'spacer', height: 8 },
        {
          type: 'horizontal_stack',
          alignment: 'start',
          children: [
            { type: 'pill', label: 'QUICKSLOT', tone: 'info' },
          ],
        },
        { type: 'spacer', height: 28 },
        { type: 'text', value: 'BOOK A COURT.', style: 'display' },
        {
          type: 'text',
          value: 'PLAY TONIGHT.',
          style: 'display',
          color: 'primary',
        },
        { type: 'spacer', height: 16 },
        {
          type: 'text',
          value:
            "Sports slot booking for Bangalore. Pick a venue, pick an hour, you're in.",
          style: 'body',
          color: 'subtle',
        },
        { type: 'spacer', height: 32 },
        { type: 'text', value: "WHO'S PLAYING", style: 'label' },
        { type: 'spacer', height: 12 },
        { type: 'vertical_stack', spacing: 12, children: userCards },
      ],
    };
  }

  // ─────────────────────────────────────────────────────────────
  // /sdui/venues  (X-User-Id required for personalisation)
  // ─────────────────────────────────────────────────────────────
  async buildVenuesScreen(userId: string): Promise<ScreenComponent> {
    const [venues, users] = await Promise.all([
      this.venuesService.list(),
      this.usersService.list(),
    ]);
    const me = users.find((u) => u.id === userId);

    const venueRows: VenueRowComponent[] = venues.map((v) => ({
      type: 'venue_row',
      venue_id: v.id,
      name: v.name,
      sport: v.sport,
      location: v.location,
      price_per_hour: v.price_per_hour,
      opens_at_hour: v.opens_at_hour,
      closes_at_hour: v.closes_at_hour,
      on_tap: [
        {
          action: 'navigate',
          to: '/venue-detail',
          params: { venue_id: v.id },
        },
      ],
    }));

    return {
      type: 'screen',
      title: 'VENUES',
      children: [
        {
          type: 'text',
          value: me ? `PLAYER · ${me.name.toUpperCase()}` : 'PLAYER',
          style: 'label',
        },
        { type: 'spacer', height: 6 },
        { type: 'text', value: 'TONIGHT?', style: 'display' },
        { type: 'spacer', height: 4 },
        {
          type: 'text',
          value: 'Pick a venue, pick a slot.',
          style: 'body',
          color: 'subtle',
        },
        { type: 'spacer', height: 24 },
        {
          type: 'banner',
          tone: 'info',
          text: '⚡ This whole screen is rendered from server JSON',
        },
        { type: 'spacer', height: 16 },
        { type: 'vertical_stack', spacing: 12, children: venueRows },
        { type: 'spacer', height: 32 },
      ],
    };
  }

  // ─────────────────────────────────────────────────────────────
  // /sdui/venue-detail?venue_id=...&date=YYYY-MM-DD
  // ─────────────────────────────────────────────────────────────
  async buildVenueDetailScreen(
    venueId: string,
    dateStr: string,
  ): Promise<ScreenComponent> {
    const venues = await this.venuesService.list();
    const venue = venues.find((v) => v.id === venueId);
    if (!venue) throw new NotFoundException('Venue not found');

    const slots = await this.venuesService.getSlots(venueId, dateStr);
    const today = new Date();
    const daysAhead = 7;
    const dateChips: DateChipComponent[] = Array.from(
      { length: daysAhead },
      (_, i) => {
        const d = new Date(today);
        d.setDate(today.getDate() + i);
        const y = d.getFullYear();
        const m = String(d.getMonth() + 1).padStart(2, '0');
        const day = String(d.getDate()).padStart(2, '0');
        const iso = `${y}-${m}-${day}`;
        const dayLabel = d
          .toLocaleDateString('en-US', { weekday: 'short' })
          .toUpperCase();
        return {
          type: 'date_chip',
          day_label: dayLabel,
          date_label: String(d.getDate()),
          selected: iso === dateStr,
          on_tap: [
            {
              action: 'replace_all',
              to: '/venue-detail',
              params: { venue_id: venueId, date: iso },
            },
          ],
        };
      },
    );

    const slotTiles: SlotTileComponent[] = slots.map((s) => ({
      type: 'slot_tile',
      hour: s.hour,
      status: s.is_booked ? 'booked' : 'open',
      slot_start_utc: s.slot_start_utc,
      on_tap: s.is_booked
        ? []
        : [
            {
              action: 'open_sheet',
              url: `/sdui/sheets/confirm-booking?venue_id=${venueId}&slot_start_utc=${encodeURIComponent(
                s.slot_start_utc,
              )}`,
            },
          ],
    }));

    return {
      type: 'screen',
      title: 'SLOTS',
      children: [
        {
          type: 'venue_header',
          name: venue.name,
          sport: venue.sport,
          location: venue.location,
          price_per_hour: venue.price_per_hour,
          opens_at_hour: venue.opens_at_hour,
          closes_at_hour: venue.closes_at_hour,
        },
        { type: 'spacer', height: 16 },
        { type: 'text', value: 'PICK A DAY', style: 'label' },
        { type: 'spacer', height: 8 },
        {
          type: 'horizontal_stack',
          spacing: 8,
          padding: 0,
          scrollable: true,
          children: dateChips,
        },
        { type: 'spacer', height: 24 },
        {
          type: 'grid',
          columns: 2,
          spacing: 10,
          aspect_ratio: 1.35,
          children: slotTiles,
        },
        { type: 'spacer', height: 32 },
      ],
    };
  }

  // ─────────────────────────────────────────────────────────────
  // /sdui/my-bookings  (X-User-Id required)
  // ─────────────────────────────────────────────────────────────
  async buildMyBookingsScreen(userId: string): Promise<ScreenComponent> {
    const bookings = await this.bookingsService.listByUser(userId);

    const tiles: BookingTileComponent[] = bookings.map((b) => {
      const local = new Date(b.slot_start_utc);
      const istLocal = new Date(local.getTime() + 5.5 * 60 * 60 * 1000);
      const day = istLocal
        .toLocaleDateString('en-US', { weekday: 'short' })
        .toUpperCase();
      const date = istLocal
        .toLocaleDateString('en-US', { day: 'numeric', month: 'short' })
        .toUpperCase();
      const startH = istLocal.getUTCHours();
      const endH = (startH + 1) % 24;
      const pad = (n: number) => String(n).padStart(2, '0');

      const cancelAction: SduiAction[] = [
        {
          action: 'show_dialog',
          url: `/sdui/dialogs/cancel-booking?booking_id=${b.id}`,
        },
      ];

      return {
        type: 'booking_tile',
        booking_id: b.id,
        venue_name: b.venue?.name ?? 'Unknown venue',
        sport: b.venue?.sport,
        location: b.venue?.location,
        date_label: `${day} · ${date}`,
        time_label: `${pad(startH)}:00 → ${pad(endH)}:00`,
        status: b.status,
        cancel_action: b.status === 'confirmed' ? cancelAction : [],
      };
    });

    const confirmedCount = bookings.filter(
      (b) => b.status === 'confirmed',
    ).length;

    return {
      type: 'screen',
      title: 'MY BOOKINGS',
      children: [
        { type: 'text', value: 'YOUR SCHEDULE', style: 'label' },
        { type: 'spacer', height: 6 },
        { type: 'text', value: `${confirmedCount} ACTIVE`, style: 'display' },
        { type: 'spacer', height: 24 },
        tiles.length === 0
          ? {
              type: 'vertical_stack',
              spacing: 8,
              children: [
                { type: 'text', value: '00', style: 'display', color: 'subtle' },
                { type: 'text', value: 'NO BOOKINGS YET', style: 'label' },
                {
                  type: 'text',
                  value: 'Pick a slot from any venue to fill this page.',
                  style: 'body',
                  color: 'subtle',
                },
              ],
            }
          : { type: 'vertical_stack', spacing: 12, children: tiles },
        { type: 'spacer', height: 32 },
      ],
    };
  }

  // ─────────────────────────────────────────────────────────────
  // /sdui/sheets/confirm-booking
  // ─────────────────────────────────────────────────────────────
  async buildConfirmBookingSheet(
    venueId: string,
    slotStartUtc: string,
  ): Promise<ScreenComponent> {
    const venues = await this.venuesService.list();
    const venue = venues.find((v) => v.id === venueId);
    if (!venue) throw new NotFoundException('Venue not found');

    const local = new Date(slotStartUtc);
    const istLocal = new Date(local.getTime() + 5.5 * 60 * 60 * 1000);
    const day = istLocal
      .toLocaleDateString('en-US', { weekday: 'short' })
      .toUpperCase();
    const date = istLocal
      .toLocaleDateString('en-US', { day: 'numeric', month: 'short' })
      .toUpperCase();
    const startH = istLocal.getUTCHours();
    const pad = (n: number) => String(n).padStart(2, '0');
    const timeLabel = `${pad(startH)}:00 → ${pad((startH + 1) % 24)}:00`;

    return {
      type: 'screen',
      title: 'CONFIRM BOOKING',
      children: [
        { type: 'spacer', height: 8 },
        { type: 'text', value: 'CONFIRM', style: 'label', color: 'primary' },
        { type: 'spacer', height: 4 },
        { type: 'text', value: 'BOOK THIS SLOT', style: 'display' },
        { type: 'spacer', height: 20 },
        {
          type: 'card',
          padding: 16,
          children: [
            { type: 'text', value: `VENUE  ${venue.name}`, style: 'body' },
            { type: 'divider' },
            { type: 'text', value: `DATE  ${day} · ${date}`, style: 'body' },
            { type: 'divider' },
            { type: 'text', value: `TIME  ${timeLabel}`, style: 'body' },
            { type: 'divider' },
            {
              type: 'text',
              value: `PRICE  ₹${venue.price_per_hour}`,
              style: 'body',
            },
          ],
        },
        { type: 'spacer', height: 20 },
        {
          type: 'button',
          label: 'CONFIRM BOOKING',
          variant: 'filled',
          full_width: true,
          on_tap: [
            {
              action: 'api_call',
              method: 'POST',
              url: '/bookings',
              body: {
                venue_id: venueId,
                slot_start_utc: slotStartUtc,
              },
              on_success: [
                { action: 'close_sheet' },
                {
                  action: 'show_snackbar',
                  text: 'Booking confirmed.',
                  tone: 'success',
                },
                { action: 'reload' },
              ],
              on_conflict: [
                { action: 'close_sheet' },
                {
                  action: 'show_snackbar',
                  text: 'Slot was just taken by someone else.',
                  tone: 'danger',
                },
                { action: 'reload' },
              ],
              on_error: [
                { action: 'close_sheet' },
                {
                  action: 'show_snackbar',
                  text: 'Booking failed. Please try again.',
                  tone: 'danger',
                },
              ],
            },
          ],
        },
        {
          type: 'button',
          label: 'CANCEL',
          variant: 'text',
          full_width: true,
          on_tap: [{ action: 'close_sheet' }],
        },
      ],
    };
  }

  // ─────────────────────────────────────────────────────────────
  // /sdui/dialogs/cancel-booking
  // ─────────────────────────────────────────────────────────────
  async buildCancelBookingDialog(bookingId: string): Promise<ScreenComponent> {
    return {
      type: 'screen',
      title: 'CANCEL BOOKING?',
      children: [
        {
          type: 'text',
          value: 'This frees the slot for someone else to book.',
          style: 'body',
        },
        { type: 'spacer', height: 20 },
        {
          type: 'horizontal_stack',
          spacing: 12,
          alignment: 'end',
          children: [
            {
              type: 'button',
              label: 'KEEP',
              variant: 'text',
              on_tap: [{ action: 'close_sheet' }],
            },
            {
              type: 'button',
              label: 'CANCEL BOOKING',
              variant: 'filled',
              on_tap: [
                {
                  action: 'api_call',
                  method: 'DELETE',
                  url: `/bookings/${bookingId}`,
                  on_success: [
                    { action: 'close_sheet' },
                    {
                      action: 'show_snackbar',
                      text: 'Booking cancelled.',
                      tone: 'success',
                    },
                    { action: 'reload' },
                  ],
                  on_error: [
                    { action: 'close_sheet' },
                    {
                      action: 'show_snackbar',
                      text: 'Cancel failed. Try again.',
                      tone: 'danger',
                    },
                  ],
                },
              ],
            },
          ],
        },
      ],
    };
  }
}
