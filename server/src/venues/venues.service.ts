import {
  Injectable,
  InternalServerErrorException,
  NotFoundException,
} from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

const IST_OFFSET = '+05:30';

@Injectable()
export class VenuesService {
  constructor(private readonly supabase: SupabaseService) {}

  async list() {
    const { data, error } = await this.supabase.client
      .from('venues')
      .select('*')
      .order('name', { ascending: true });

    if (error) {
      throw new InternalServerErrorException(error.message);
    }
    return data ?? [];
  }

  async getSlots(venueId: string, date: string) {
    const { data: venue, error: vErr } = await this.supabase.client
      .from('venues')
      .select('id, name, opens_at_hour, closes_at_hour')
      .eq('id', venueId)
      .maybeSingle();

    if (vErr) throw new InternalServerErrorException(vErr.message);
    if (!venue) throw new NotFoundException('Venue not found');

    const slots = this.generateSlots(
      venueId,
      date,
      venue.opens_at_hour,
      venue.closes_at_hour,
    );

    const dayStartUtc = new Date(`${date}T00:00:00${IST_OFFSET}`).toISOString();
    const dayEndUtc = new Date(`${date}T23:59:59${IST_OFFSET}`).toISOString();

    const { data: bookings, error: bErr } = await this.supabase.client
      .from('bookings')
      .select('id, slot_start_utc')
      .eq('venue_id', venueId)
      .eq('status', 'confirmed')
      .gte('slot_start_utc', dayStartUtc)
      .lte('slot_start_utc', dayEndUtc);

    if (bErr) throw new InternalServerErrorException(bErr.message);

    const bookedByTimestamp = new Map<number, string>();
    for (const b of bookings ?? []) {
      bookedByTimestamp.set(new Date(b.slot_start_utc).getTime(), b.id);
    }

    return slots.map((s) => {
      const t = new Date(s.slot_start_utc).getTime();
      const bookingId = bookedByTimestamp.get(t);
      return {
        ...s,
        is_booked: bookingId !== undefined,
        booking_id: bookingId ?? null,
      };
    });
  }

  private generateSlots(
    venueId: string,
    date: string,
    opensAtHour: number,
    closesAtHour: number,
  ) {
    const slots: Array<{
      venue_id: string;
      hour: number;
      slot_start_utc: string;
      slot_end_utc: string;
    }> = [];

    for (let h = opensAtHour; h < closesAtHour; h++) {
      const startIst = `${date}T${String(h).padStart(2, '0')}:00:00${IST_OFFSET}`;
      const endIst = `${date}T${String(h + 1).padStart(2, '0')}:00:00${IST_OFFSET}`;
      slots.push({
        venue_id: venueId,
        hour: h,
        slot_start_utc: new Date(startIst).toISOString(),
        slot_end_utc: new Date(endIst).toISOString(),
      });
    }
    return slots;
  }
}
