import {
  Controller,
  ForbiddenException,
  Get,
  Param,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';
import { CurrentUserId } from '../common/auth/current-user-id.decorator';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { BookingsService } from './bookings.service';

@Controller('users/:id/bookings')
@UseGuards(UserHeaderGuard)
export class UserBookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Get()
  list(
    @CurrentUserId() authedUserId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    if (authedUserId !== id) {
      throw new ForbiddenException('Cannot read another user\'s bookings');
    }
    return this.bookingsService.listByUser(id);
  }
}
