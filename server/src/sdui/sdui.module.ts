import { Module } from '@nestjs/common';
import { VenuesModule } from '../venues/venues.module';
import { SduiController } from './sdui.controller';
import { SduiService } from './sdui.service';

@Module({
  imports: [VenuesModule],
  controllers: [SduiController],
  providers: [SduiService],
})
export class SduiModule {}
