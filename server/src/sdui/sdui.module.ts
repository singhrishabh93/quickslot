import { Module } from '@nestjs/common';
import { BookingsModule } from '../bookings/bookings.module';
import { UsersModule } from '../users/users.module';
import { VenuesModule } from '../venues/venues.module';
import { SduiController } from './sdui.controller';
import { SduiService } from './sdui.service';

@Module({
  imports: [VenuesModule, UsersModule, BookingsModule],
  controllers: [SduiController],
  providers: [SduiService],
})
export class SduiModule {}
