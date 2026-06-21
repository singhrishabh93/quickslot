import {
  Controller,
  Get,
  Headers,
  ParseUUIDPipe,
  Query,
  UnauthorizedException,
  UseGuards,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUserId } from '../common/auth/current-user-id.decorator';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { SduiService } from './sdui.service';

@ApiTags('SDUI')
@Controller('sdui')
export class SduiController {
  constructor(private readonly sduiService: SduiService) {}

  // No auth — login picker needs to be reachable before there's a session
  @Get('login')
  @ApiOperation({ summary: 'Login screen tree (no auth required)' })
  getLoginScreen() {
    return this.sduiService.buildLoginScreen();
  }

  @Get('venues')
  @UseGuards(UserHeaderGuard)
  @ApiOperation({ summary: 'Venues list screen tree (personalised greeting)' })
  getVenuesScreen(@CurrentUserId() userId: string) {
    return this.sduiService.buildVenuesScreen(userId);
  }

  @Get('venue-detail')
  @UseGuards(UserHeaderGuard)
  @ApiOperation({ summary: 'Venue detail screen tree (date + slot grid)' })
  getVenueDetailScreen(
    @Query('venue_id', ParseUUIDPipe) venueId: string,
    @Query('date') date: string,
  ) {
    const dateStr =
      date && /^\d{4}-\d{2}-\d{2}$/.test(date) ? date : todayInIst();
    return this.sduiService.buildVenueDetailScreen(venueId, dateStr);
  }

  @Get('my-bookings')
  @UseGuards(UserHeaderGuard)
  @ApiOperation({ summary: "Current user's bookings as SDUI tree" })
  getMyBookingsScreen(@CurrentUserId() userId: string) {
    return this.sduiService.buildMyBookingsScreen(userId);
  }

  @Get('sheets/confirm-booking')
  @UseGuards(UserHeaderGuard)
  @ApiOperation({ summary: 'Bottom sheet for confirming a booking' })
  getConfirmBookingSheet(
    @Query('venue_id', ParseUUIDPipe) venueId: string,
    @Query('slot_start_utc') slotStartUtc: string,
  ) {
    if (!slotStartUtc) {
      throw new UnauthorizedException('slot_start_utc query is required');
    }
    return this.sduiService.buildConfirmBookingSheet(venueId, slotStartUtc);
  }

  @Get('dialogs/cancel-booking')
  @UseGuards(UserHeaderGuard)
  @ApiOperation({ summary: 'Alert dialog for confirming a cancellation' })
  getCancelBookingDialog(
    @Query('booking_id', ParseUUIDPipe) bookingId: string,
    @Headers() _headers: Record<string, string>,
  ) {
    return this.sduiService.buildCancelBookingDialog(bookingId);
  }
}

function todayInIst(): string {
  const now = new Date();
  // Shift to IST then format yyyy-mm-dd
  const ist = new Date(now.getTime() + 5.5 * 60 * 60 * 1000);
  const y = ist.getUTCFullYear();
  const m = String(ist.getUTCMonth() + 1).padStart(2, '0');
  const d = String(ist.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}
