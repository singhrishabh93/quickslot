import { Module } from '@nestjs/common';
import { UserHeaderGuard } from '../common/auth/user-header.guard';
import { BookingsController } from './bookings.controller';
import { BookingsService } from './bookings.service';
import { UserBookingsController } from './user-bookings.controller';

@Module({
  controllers: [BookingsController, UserBookingsController],
  providers: [BookingsService, UserHeaderGuard],
})
export class BookingsModule {}
