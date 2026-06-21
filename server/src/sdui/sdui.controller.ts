import { Controller, Get } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { SduiService } from './sdui.service';

@ApiTags('SDUI')
@Controller('sdui')
export class SduiController {
  constructor(private readonly sduiService: SduiService) {}

  @Get('venues')
  @ApiOperation({
    summary: 'Server-driven UI tree for the venues screen',
    description:
      'Returns a typed component tree that the Flutter client renders ' +
      'dynamically. Change this endpoint to change the screen without ' +
      'an app update.',
  })
  @ApiOkResponse({
    schema: {
      example: {
        type: 'screen',
        title: 'VENUES',
        children: [
          {
            type: 'banner',
            tone: 'info',
            text: '⚡ This screen is rendered from server JSON',
          },
          {
            type: 'vertical_stack',
            spacing: 12,
            children: [
              {
                type: 'venue_row',
                venue_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                name: 'SmashKing Badminton Arena',
                sport: 'badminton',
                location: 'Indiranagar, Bangalore',
                price_per_hour: 400,
                opens_at_hour: 6,
                closes_at_hour: 22,
                on_tap: {
                  action: 'navigate',
                  to: '/venue-detail',
                  params: {
                    venue_id: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                  },
                },
              },
            ],
          },
        ],
      },
    },
  })
  getVenuesScreen() {
    return this.sduiService.buildVenuesScreen();
  }
}
