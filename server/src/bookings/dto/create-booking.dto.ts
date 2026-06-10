import { ApiProperty } from '@nestjs/swagger';
import { IsISO8601, Matches } from 'class-validator';
import { UUID_RE } from '../../common/utils/uuid';

export class CreateBookingDto {
  @ApiProperty({
    description: 'Target venue UUID',
    example: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  })
  @Matches(UUID_RE, { message: 'venue_id must be a UUID' })
  venue_id!: string;

  @ApiProperty({
    description:
      'Slot start time as ISO 8601 UTC. Must match a slot returned by GET /venues/:id/slots.',
    example: '2026-06-11T10:30:00.000Z',
  })
  @IsISO8601()
  slot_start_utc!: string;
}
