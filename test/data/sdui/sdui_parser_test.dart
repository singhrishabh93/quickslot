import 'package:flutter_test/flutter_test.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_action.dart';
import 'package:swades_hackathon_app/data/sdui/sdui_component.dart';

void main() {
  group('SduiComponent.fromJson — v2 happy path', () {
    test('parses a venues screen tree', () {
      final json = {
        'type': 'screen',
        'title': 'VENUES',
        'children': [
          {'type': 'banner', 'tone': 'info', 'text': 'hi'},
          {
            'type': 'vertical_stack',
            'spacing': 12,
            'children': [
              {
                'type': 'venue_row',
                'venue_id': 'aaa-aaa',
                'name': 'SmashKing',
                'sport': 'badminton',
                'location': 'Indiranagar',
                'price_per_hour': 400,
                'opens_at_hour': 6,
                'closes_at_hour': 22,
                'on_tap': [
                  {
                    'action': 'navigate',
                    'to': '/venue-detail',
                    'params': {'venue_id': 'aaa-aaa'},
                  },
                ],
              },
            ],
          },
        ],
      };

      final screen = SduiComponent.fromJson(json) as SduiScreen;
      expect(screen.title, 'VENUES');
      expect(screen.children, hasLength(2));
      expect(screen.children[0], isA<SduiBanner>());

      final stack = screen.children[1] as SduiVerticalStack;
      expect(stack.spacing, 12);
      final row = stack.children.first as SduiVenueRow;
      expect(row.name, 'SmashKing');
      expect(row.onTap, hasLength(1));
      expect(row.onTap.first, isA<SduiNavigate>());
      expect((row.onTap.first as SduiNavigate).to, '/venue-detail');
    });

    test('booking_tile parses cancel_action chain', () {
      final json = {
        'type': 'booking_tile',
        'booking_id': 'b1',
        'venue_name': 'GreenField Turf',
        'sport': 'turf',
        'date_label': 'WED · 11 JUN',
        'time_label': '10:00 → 11:00',
        'status': 'confirmed',
        'cancel_action': [
          {'action': 'show_dialog', 'url': '/sdui/dialogs/cancel?b=b1'},
        ],
      };
      final tile = SduiComponent.fromJson(json) as SduiBookingTile;
      expect(tile.status, SduiBookingStatus.confirmed);
      expect(tile.cancelAction.first, isA<SduiShowDialog>());
    });
  });

  group('Forward compatibility', () {
    test('unknown component type falls back', () {
      final result = SduiComponent.fromJson({'type': 'video_player'});
      expect(result, isA<SduiUnknownComponent>());
    });

    test('unknown action falls back', () {
      final result = SduiAction.fromJson({'action': 'open_browser'});
      expect(result, isA<SduiUnknownAction>());
    });

    test('sibling unknowns don\'t break parent', () {
      final screen = SduiComponent.fromJson({
        'type': 'screen',
        'children': [
          {'type': 'text', 'value': 'ok'},
          {'type': 'mystery'},
          {'type': 'banner', 'text': 'still here'},
        ],
      }) as SduiScreen;
      expect(screen.children, hasLength(3));
      expect(screen.children[1], isA<SduiUnknownComponent>());
    });
  });

  group('SduiAction.fromJson — v2 actions', () {
    test('api_call parses with on_success / on_conflict / on_error chains',
        () {
      final action = SduiAction.fromJson({
        'action': 'api_call',
        'method': 'POST',
        'url': '/bookings',
        'body': {'venue_id': 'aaa'},
        'on_success': [
          {'action': 'close_sheet'},
          {'action': 'show_snackbar', 'text': 'Booked', 'tone': 'success'},
          {'action': 'reload'},
        ],
        'on_conflict': [
          {'action': 'show_snackbar', 'text': 'Slot taken', 'tone': 'danger'},
        ],
      }) as SduiApiCall;

      expect(action.method, SduiHttpMethod.post);
      expect(action.url, '/bookings');
      expect(action.onSuccess, hasLength(3));
      expect(action.onSuccess[0], isA<SduiCloseSheet>());
      expect(action.onSuccess[1], isA<SduiShowSnackbar>());
      expect(action.onSuccess[2], isA<SduiReload>());
      expect(action.onConflict, hasLength(1));
      expect(action.onError, isEmpty);
    });

    test('set_session reads user_id and name', () {
      final action = SduiAction.fromJson({
        'action': 'set_session',
        'user_id': 'u1',
        'name': 'Alice',
      }) as SduiSetSession;
      expect(action.userId, 'u1');
      expect(action.name, 'Alice');
    });
  });
}
