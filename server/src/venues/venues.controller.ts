import {
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Query,
} from '@nestjs/common';
import { SlotQueryDto } from './dto/slot-query.dto';
import { VenuesService } from './venues.service';

@Controller('venues')
export class VenuesController {
  constructor(private readonly venuesService: VenuesService) {}

  @Get()
  list() {
    return this.venuesService.list();
  }

  @Get(':id/slots')
  getSlots(
    @Param('id', ParseUUIDPipe) id: string,
    @Query() query: SlotQueryDto,
  ) {
    return this.venuesService.getSlots(id, query.date);
  }
}
