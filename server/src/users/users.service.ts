import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../common/supabase/supabase.service';

@Injectable()
export class UsersService {
  constructor(private readonly supabase: SupabaseService) {}

  async list() {
    const { data, error } = await this.supabase.client
      .from('users')
      .select('id, name, email')
      .order('name', { ascending: true });

    if (error) throw new InternalServerErrorException(error.message);
    return data ?? [];
  }
}
