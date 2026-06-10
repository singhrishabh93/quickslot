import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { UsersService } from './users.service';

@ApiTags('Users')
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  @ApiOperation({
    summary: 'List hardcoded users — login picker data',
  })
  @ApiOkResponse({
    schema: {
      example: [
        {
          id: '11111111-1111-1111-1111-111111111111',
          name: 'Alice',
          email: 'alice@quickslot.test',
        },
      ],
    },
  })
  list() {
    return this.usersService.list();
  }
}
