import {
  CanActivate,
  ExecutionContext,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UUID_RE } from '../utils/uuid';

@Injectable()
export class UserHeaderGuard implements CanActivate {
  constructor(private readonly supabase: SupabaseService) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const req = ctx.switchToHttp().getRequest<{
      headers: Record<string, string | string[] | undefined>;
      userId?: string;
    }>();

    const raw = req.headers['x-user-id'];
    const userId = Array.isArray(raw) ? raw[0] : raw;

    if (!userId || !UUID_RE.test(userId)) {
      throw new UnauthorizedException(
        'Valid X-User-Id header (UUID) is required',
      );
    }

    const { data, error } = await this.supabase.client
      .from('users')
      .select('id')
      .eq('id', userId)
      .maybeSingle();

    if (error) throw new InternalServerErrorException(error.message);
    if (!data) throw new UnauthorizedException('Unknown user');

    req.userId = userId;
    return true;
  }
}
