import {
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';
import {
  ApiBadRequestResponse,
  ApiNotFoundResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiTags,
} from '@nestjs/swagger';
import { SlotQueryDto } from './dto/slot-query.dto';
import { VenuesService } from './venues.service';

@ApiTags('Venues')
@Controller('venues')
export class VenuesController {
  constructor(private readonly venuesService: VenuesService) {}

  @Get()
  @ApiOperation({ summary: 'List all venues' })
  @ApiOkResponse({
    schema: {
      example: [
        {
          id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          name: 'SmashKing Badminton Arena',
          sport: 'badminton',
          location: 'Indiranagar, Bangalore',
          price_per_hour: 400,
          opens_at_hour: 6,
          closes_at_hour: 22,
          created_at: '2026-06-10T15:00:00.000Z',
        },
      ],
    },
  })
  list() {
    return this.venuesService.list();
  }

  @Get(':id/slots')
  @ApiOperation({
    summary: 'Get hourly slots for a venue on a given date',
    description:
      'Slots are logical — generated from venue.opens_at_hour..closes_at_hour, then overlaid with confirmed bookings. is_booked flips to true if a confirmed booking exists for that slot_start_utc.',
  })
  @ApiParam({ name: 'id', description: 'Venue UUID' })
  @ApiOkResponse({
    schema: {
      example: [
        {
          venue_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
          hour: 6,
          slot_start_utc: '2026-06-11T00:30:00.000Z',
          slot_end_utc: '2026-06-11T01:30:00.000Z',
          is_booked: false,
          booking_id: null,
        },
      ],
    },
  })
  @ApiBadRequestResponse({ description: 'Invalid date format or venue UUID' })
  @ApiNotFoundResponse({ description: 'Venue not found' })
  getSlots(
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: SlotQueryDto,
  ) {
    return this.venuesService.getSlots(id, query.date);
  }
}
