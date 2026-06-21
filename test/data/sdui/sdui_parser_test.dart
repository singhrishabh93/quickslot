import 'package:flutter_test/flutter_test.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_action.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_component.dart';

void main() {
  group('SduiComponent.fromJson — happy path', () {
    test('parses a screen with a banner and a vertical stack of venue rows',
        () {
      final json = {
        'type': 'screen',
        'title': 'VENUES',
        'children': [
          {
            'type': 'banner',
            'tone': 'info',
            'text': '⚡ This screen is rendered from server JSON',
          },
          {
            'type': 'vertical_stack',
            'spacing': 12,
            'children': [
              {
                'type': 'venue_row',
                'venue_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
                'name': 'SmashKing Badminton Arena',
                'sport': 'badminton',
                'location': 'Indiranagar, Bangalore',
                'price_per_hour': 400,
                'opens_at_hour': 6,
                'closes_at_hour': 22,
                'on_tap': {
                  'action': 'navigate',
                  'to': '/venue-detail',
                  'params': {'venue_id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'},
                },
              },
            ],
          },
        ],
      };

      final tree = SduiComponent.fromJson(json);

      // 1. root is a screen with the right title
      expect(tree, isA<SduiScreen>());
      final screen = tree as SduiScreen;
      expect(screen.title, 'VENUES');
      expect(screen.children, hasLength(2));

      // 2. first child is the banner
      final banner = screen.children[0];
      expect(banner, isA<SduiBanner>());
      expect((banner as SduiBanner).tone, SduiBannerTone.info);
      expect(banner.text, contains('rendered from server JSON'));

      // 3. second child is a vertical stack
      final stack = screen.children[1];
      expect(stack, isA<SduiVerticalStack>());
      expect((stack as SduiVerticalStack).spacing, 12);
      expect(stack.children, hasLength(1));

      // 4. inside the stack: the venue row, with a navigate action
      final row = stack.children.first;
      expect(row, isA<SduiVenueRow>());
      final venueRow = row as SduiVenueRow;
      expect(venueRow.name, 'SmashKing Badminton Arena');
      expect(venueRow.sport, SduiSport.badminton);
      expect(venueRow.pricePerHour, 400);
      expect(venueRow.onTap, isA<SduiNavigate>());
      expect((venueRow.onTap! as SduiNavigate).to, '/venue-detail');
      expect((venueRow.onTap! as SduiNavigate).params['venue_id'],
          'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa');
    });

    test('applies sensible defaults when optional fields are omitted', () {
      final json = {
        'type': 'vertical_stack',
        // no spacing field
        'children': [
          {'type': 'text', 'value': 'hi'}, // no style field
          {'type': 'card', 'children': []}, // no padding, no on_tap
        ],
      };

      final stack =
          SduiComponent.fromJson(json) as SduiVerticalStack;

      expect(stack.spacing, 0, reason: 'spacing defaults to 0');
      final text = stack.children[0] as SduiText;
      expect(text.style, SduiTextStyleVariant.body,
          reason: 'style defaults to body');
      final card = stack.children[1] as SduiCard;
      expect(card.padding, 16, reason: 'card padding defaults to 16');
      expect(card.onTap, isNull);
    });
  });

  group('SduiComponent.fromJson — forward compatibility', () {
    test('unknown component type falls back to SduiUnknownComponent', () {
      // Imagine server v2 added a video_player component that v1 client
      // doesn't know yet. The parser must not crash.
      final json = {'type': 'video_player', 'url': 'https://x/y.mp4'};

      final result = SduiComponent.fromJson(json);

      expect(result, isA<SduiUnknownComponent>());
      expect((result as SduiUnknownComponent).type, 'video_player');
    });

    test('completely missing type falls back too', () {
      final result = SduiComponent.fromJson({'foo': 'bar'});

      expect(result, isA<SduiUnknownComponent>());
      expect((result as SduiUnknownComponent).type, 'unknown');
    });

    test('unknown nested component does not break the parent', () {
      final json = {
        'type': 'screen',
        'children': [
          {'type': 'banner', 'text': 'ok'},
          {'type': 'mystery_widget'}, // unknown — sibling should still parse
          {'type': 'text', 'value': 'still here'},
        ],
      };

      final screen = SduiComponent.fromJson(json) as SduiScreen;

      expect(screen.children, hasLength(3));
      expect(screen.children[0], isA<SduiBanner>());
      expect(screen.children[1], isA<SduiUnknownComponent>());
      expect(screen.children[2], isA<SduiText>());
    });
  });

  group('SduiAction.fromJson', () {
    test('parses a reload action', () {
      final action = SduiAction.fromJson({'action': 'reload'});
      expect(action, isA<SduiReload>());
    });

    test('parses navigate with no params (params defaults to {})', () {
      final action = SduiAction.fromJson({
        'action': 'navigate',
        'to': '/my-bookings',
      });
      expect(action, isA<SduiNavigate>());
      expect((action as SduiNavigate).to, '/my-bookings');
      expect(action.params, isEmpty);
    });

    test('unknown action type falls back to SduiUnknownAction', () {
      final action = SduiAction.fromJson({'action': 'open_browser'});
      expect(action, isA<SduiUnknownAction>());
      expect((action as SduiUnknownAction).action, 'open_browser');
    });
  });
}
