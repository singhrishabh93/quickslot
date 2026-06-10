import {
  Controller,
  ForbiddenException,
  Get,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';
import {
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiParam,
  ApiSecurity,
  ApiTags,
  ApiUnauthorizedResponse,
} from '@nestjs/swagger';
import { CurrentUserId } from '../common/auth/current-user-id.decorator';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { BookingsService } from './bookings.service';

@ApiTags('Bookings')
@ApiSecurity('X-User-Id')
@Controller('users/:id/bookings')
@UseGuards(UserHeaderGuard)
export class UserBookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Get()
  @ApiOperation({ summary: "List a user's bookings (own only)" })
  @ApiParam({ name: 'id', description: 'User UUID (must match X-User-Id)' })
  @ApiOkResponse({
    schema: {
      example: [
        {
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
        },
      ],
    },
  })
  @ApiUnauthorizedResponse({ description: 'Missing or invalid X-User-Id' })
  @ApiForbiddenResponse({ description: "Cannot read another user's bookings" })
  list(
    @CurrentUserId() authedUserId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    if (authedUserId !== id) {
      throw new ForbiddenException("Cannot read another user's bookings");
    }
    return this.bookingsService.listByUser(id);
  }
}
