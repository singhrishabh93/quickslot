import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/modules/venues/widgets/slot_tile.dart';

void main() {
  Slot makeSlot({required int hour, required bool isBooked}) {
    return Slot(
      venueId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      hour: hour,
      slotStartUtc: DateTime.utc(2026, 6, 11, hour - 5, 30),
      slotEndUtc: DateTime.utc(2026, 6, 11, hour - 4, 30),
      isBooked: isBooked,
      bookingId: isBooked ? 'b1' : null,
    );
  }

  testWidgets(
      'SlotTile shows BOOKED label and is non-tappable when isBooked=true',
      (tester) async {
    var tapped = false;
    final slot = makeSlot(hour: 9, isBooked: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlotTile(slot: slot, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('BOOKED'), findsOneWidget);
    expect(find.text('OPEN'), findsNothing);

    await tester.tap(find.byType(SlotTile));
    await tester.pumpAndSettle();
    expect(tapped, isFalse, reason: 'Booked slots must not fire onTap');
  });

  testWidgets(
      'SlotTile shows OPEN label and fires onTap when isBooked=false',
      (tester) async {
    var tapped = false;
    final slot = makeSlot(hour: 18, isBooked: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SlotTile(slot: slot, onTap: () => tapped = true),
        ),
      ),
    );

    expect(find.text('OPEN'), findsOneWidget);
    expect(find.text('BOOKED'), findsNothing);

    await tester.tap(find.byType(SlotTile));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });
}
