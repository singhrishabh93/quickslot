import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { BookingsModule } from './bookings/bookings.module';
import { SupabaseModule } from './common/supabase/supabase.module';
import { HealthModule } from './health/health.module';
import { UsersModule } from './users/users.module';
import { VenuesModule } from './venues/venues.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    SupabaseModule,
    HealthModule,
    VenuesModule,
    UsersModule,
    BookingsModule,
  ],
})
export class AppModule {}
