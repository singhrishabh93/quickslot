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
import { CurrentUserId } from '../common/auth/current-user-id.decorator';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { BookingsService } from './bookings.service';
import { CreateBookingDto } from './dto/create-booking.dto';

@Controller('bookings')
@UseGuards(UserHeaderGuard)
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  @Post()
  @HttpCode(201)
  create(@CurrentUserId() userId: string, @Body() dto: CreateBookingDto) {
    return this.bookingsService.create(userId, dto.venue_id, dto.slot_start_utc);
  }

  @Delete(':id')
  cancel(
    @CurrentUserId() userId: string,
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.bookingsService.cancel(userId, id);
  }
}
