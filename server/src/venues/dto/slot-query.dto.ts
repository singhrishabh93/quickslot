import { ApiProperty } from '@nestjs/swagger';
import { Matches } from 'class-validator';

export class SlotQueryDto {
  @ApiProperty({
    description: 'Date for which slots should be returned (IST calendar day)',
    example: '2026-06-11',
  })
  @Matches(/^\d{4}-\d{2}-\d{2}$/, {
    message: 'date must be in YYYY-MM-DD format',
  })
  date!: string;
}
