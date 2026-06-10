import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { SupabaseService } from '../common/supabase/supabase.service';

@ApiTags('Health')
@Controller('health')
export class HealthController {
  constructor(private readonly supabase: SupabaseService) {}

  @Get()
  @ApiOperation({ summary: 'Liveness + Supabase connection check' })
  @ApiOkResponse({
    schema: {
      example: {
        status: 'ok',
        service: 'quickslot-api',
        supabase: 'connected',
        timestamp: '2026-06-10T15:00:00.000Z',
      },
    },
  })
  check() {
    return {
      status: 'ok',
      service: 'quickslot-api',
      supabase: this.supabase.isReady ? 'connected' : 'not_configured',
      timestamp: new Date().toISOString(),
    };
  }
}
