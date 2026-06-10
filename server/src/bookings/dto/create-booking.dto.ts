import { IsISO8601, Matches } from 'class-validator';
import { UUID_RE } from '../../common/utils/uuid';

export class CreateBookingDto {
  @Matches(UUID_RE, { message: 'venue_id must be a UUID' })
  venue_id!: string;

  @IsISO8601()
  slot_start_utc!: string;
}
