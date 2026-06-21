import { Injectable } from '@nestjs/common';
import { VenuesService } from '../venues/venues.service';
import {
  BannerComponent,
  ScreenComponent,
  VenueRowComponent,
  VerticalStackComponent,
} from './sdui.types';

/**
 * Builds the screen trees the Flutter client renders.
 *
 * The whole point of SDUI lives here: change the shape, copy, or
 * ordering of what this method returns and the client UI updates on
 * next screen open — no app rebuild required.
 *
 * Try this once it's deployed:
 *   - reorder venues (sort by price desc instead of name asc)
 *   - change the banner copy or tone
 *   - insert a second banner between the 2nd and 3rd venue row
 *   - drop the banner entirely
 * Each change is server-side only.
 */
@Injectable()
export class SduiService {
  constructor(private readonly venuesService: VenuesService) {}

  async buildVenuesScreen(): Promise<ScreenComponent> {
    const venues = await this.venuesService.list();

    const venueRows: VenueRowComponent[] = venues.map((v) => ({
      type: 'venue_row',
      venue_id: v.id,
      name: v.name,
      sport: v.sport,
      location: v.location,
      price_per_hour: v.price_per_hour,
      opens_at_hour: v.opens_at_hour,
      closes_at_hour: v.closes_at_hour,
      on_tap: {
        action: 'navigate',
        to: '/venue-detail',
        params: { venue_id: v.id },
      },
    }));

    const banner: BannerComponent = {
      type: 'banner',
      tone: 'info',
      text: '⚡ This screen is rendered from server JSON',
    };

    const list: VerticalStackComponent = {
      type: 'vertical_stack',
      spacing: 12,
      children: venueRows,
    };

    return {
      type: 'screen',
      title: 'VENUES',
      children: [banner, list],
    };
  }
}
