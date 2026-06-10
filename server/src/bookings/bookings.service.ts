import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

@Injectable()
export class BookingsService {
  constructor(private readonly supabase: SupabaseService) {}

  async create(userId: string, venueId: string, slotStartUtc: string) {
    const { data: venue, error: vErr } = await this.supabase.client
      .from('venues')
      .select('id, opens_at_hour, closes_at_hour')
      .eq('id', venueId)
      .maybeSingle();

    if (vErr) throw new InternalServerErrorException(vErr.message);
    if (!venue) throw new NotFoundException('Venue not found');

    this.assertSlotWithinVenueHours(
      slotStartUtc,
      venue.opens_at_hour,
      venue.closes_at_hour,
    );

    const { data, error } = await this.supabase.client
      .from('bookings')
      .insert({
        user_id: userId,
        venue_id: venueId,
        slot_start_utc: slotStartUtc,
        status: 'confirmed',
      })
      .select('*, venue:venues(id, name, sport, location, price_per_hour)')
      .single();

    if (error) {
      if (error.code === '23505') {
        throw new ConflictException('SLOT_TAKEN');
      }
      throw new InternalServerErrorException(error.message);
    }
    return data;
  }

  async listByUser(userId: string) {
    const { data, error } = await this.supabase.client
      .from('bookings')
      .select('*, venue:venues(id, name, sport, location, price_per_hour)')
      .eq('user_id', userId)
      .order('slot_start_utc', { ascending: false });

    if (error) throw new InternalServerErrorException(error.message);
    return data ?? [];
  }

  async cancel(userId: string, bookingId: string) {
    const { data: existing, error: fetchErr } = await this.supabase.client
      .from('bookings')
      .select('id, user_id, status')
      .eq('id', bookingId)
      .maybeSingle();

    if (fetchErr) throw new InternalServerErrorException(fetchErr.message);
    if (!existing) throw new NotFoundException('Booking not found');
    if (existing.user_id !== userId) {
      throw new ForbiddenException('Not your booking');
    }
    if (existing.status === 'cancelled') {
      return existing;
    }

    const { data, error } = await this.supabase.client
      .from('bookings')
      .update({
        status: 'cancelled',
        cancelled_at: new Date().toISOString(),
      })
      .eq('id', bookingId)
      .select('*, venue:venues(id, name, sport, location, price_per_hour)')
      .single();

    if (error) throw new InternalServerErrorException(error.message);
    return data;
  }

  // Slot times come from /slots which generates them in IST.
  // 6 AM IST = 00:30 UTC, so UTC hour offset is -5.5h, but we compare the IST hour.
  private assertSlotWithinVenueHours(
    slotStartUtc: string,
    opensAtHour: number,
    closesAtHour: number,
  ) {
    const t = new Date(slotStartUtc);
    if (Number.isNaN(t.getTime())) {
      throw new BadRequestException('Invalid slot_start_utc');
    }
    const istMs = t.getTime() + 5.5 * 60 * 60 * 1000;
    const istHour = new Date(istMs).getUTCHours();
    if (istHour < opensAtHour || istHour >= closesAtHour) {
      throw new BadRequestException(
        `Slot must be between ${opensAtHour}:00 and ${closesAtHour}:00 IST`,
      );
    }
  }
}
