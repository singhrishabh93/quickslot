import {
  Body,
  Controller,
  Delete,
  HttpCode,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiConflictResponse,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiSecurity,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentUserId } from '../common/auth/current-user-id.decorator';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';

const BOOKING_EXAMPLE = {
  id: 'ad44e692-43ce-4273-94bb-cd80f04ddaa0',
  user_id: '11111111-1111-1111-1111-111111111111',
  venue_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
  slot_start_utc: '2026-06-11T10:30:00.000Z',
  status: 'confirmed',
  created_at: '2026-06-10T15:23:22.422Z',
  cancelled_at: null,
  venue: {
    id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    name: 'SmashKing Badminton Arena',
    sport: 'badminton',
    location: 'Indiranagar, Bangalore',
    price_per_hour: 400,
  },
};

@ApiTags('Bookings')
@ApiSecurity('X-User-Id')
@Controller('bookings')
@UseGuards(UserHeaderGuard)
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @HttpCode(201)
  @ApiOperation({
    summary: 'Book a slot — concurrency-safe',
    description:
      'Inserts a confirmed booking. Postgres enforces the partial unique index (venue_id, slot_start_utc) WHERE status=confirmed, so concurrent attempts on the same slot yield exactly one 201 and the rest 409 SLOT_TAKEN.',
  })
  @ApiCreatedResponse({ schema: { example: BOOKING_EXAMPLE } })
  @ApiConflictResponse({
    description: 'Slot already booked',
    schema: {
      example: { statusCode: 409, message: 'SLOT_TAKEN', error: 'Conflict' },
    },
  })
  @ApiBadRequestResponse({ description: 'Invalid body or slot outside venue hours' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid X-User-Id' })
  @ApiNotFoundResponse({ description: 'Venue not found' })
  create(@CurrentUserId() userId: string, @Body() dto: CreateBookingDto) {
    return this.bookingsService.create(userId, dto.venue_id, dto.slot_start_utc);
  }

  @Delete(':id')
  @ApiOperation({
    summary: 'Cancel a booking',
    description:
      'Sets status=cancelled. The partial unique index excludes cancelled rows, so the slot becomes bookable again.',
  })
  @ApiOkResponse({
    schema: {
      example: { ...BOOKING_EXAMPLE, status: 'cancelled', cancelled_at: '2026-06-10T15:25:00.000Z' },
    },
  })
  @ApiForbiddenResponse({ description: 'Booking belongs to another user' })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid X-User-Id' })
  @ApiNotFoundResponse({ description: 'Booking not found' })
  cancel(
    @CurrentUserId() userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.cancel(userId, id);
  }
}
