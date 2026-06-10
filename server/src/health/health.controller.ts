import { Controller, Get } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

@Controller('health')
export class HealthController {
  constructor(private readonly supabase: SupabaseService) {}

  @Get()
  check() {
    return {
      status: 'ok',
      service: 'quickslot-api',
      supabase: this.supabase.isReady ? 'connected' : 'not_configured',
      timestamp: new Date().toISOString(),
    };
  }
}
