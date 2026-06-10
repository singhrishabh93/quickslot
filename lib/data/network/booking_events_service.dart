import 'dart:async';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';

sealed class BookingEvent {
  const BookingEvent({
    required this.venueId,
    required this.slotStartUtc,
    required this.bookingId,
  });

  final String venueId;
  final DateTime slotStartUtc;
  final String bookingId;
}

class BookingConfirmed extends BookingEvent {
  const BookingConfirmed({
    required super.venueId,
    required super.slotStartUtc,
    required super.bookingId,
  });
}

class BookingFreed extends BookingEvent {
  const BookingFreed({
    required super.venueId,
    required super.slotStartUtc,
    required super.bookingId,
  });
}

class BookingEventsService {
  BookingEventsService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Stream<BookingEvent> watchVenue(String venueId) {
    final controller = StreamController<BookingEvent>();
    final channelId =
        'venue-$venueId-${DateTime.now().microsecondsSinceEpoch}';
    developer.log('[Realtime] Creating channel: $channelId', name: 'Realtime');
    final channel = _client.channel(channelId);

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'venue_id',
            value: venueId,
          ),
          callback: (payload) {
            developer.log(
              '[Realtime] INSERT received: ${payload.newRecord}',
              name: 'Realtime',
            );
            final event = _mapInsert(payload.newRecord);
            if (event != null) controller.add(event);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'venue_id',
            value: venueId,
          ),
          callback: (payload) {
            developer.log(
              '[Realtime] UPDATE received: ${payload.newRecord}',
              name: 'Realtime',
            );
            final event = _mapUpdate(payload.newRecord);
            if (event != null) controller.add(event);
          },
        )
        .subscribe((status, [error]) {
          developer.log(
            '[Realtime] Subscribe status=$status error=$error',
            name: 'Realtime',
          );
        });

    controller.onCancel = () async {
      developer.log(
        '[Realtime] Removing channel: $channelId',
        name: 'Realtime',
      );
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  BookingEvent? _mapInsert(Map<String, dynamic> row) {
    if (row['status'] != 'confirmed') return null;
    return BookingConfirmed(
      venueId: row['venue_id'] as String,
      slotStartUtc: DateTime.parse(row['slot_start_utc'] as String),
      bookingId: row['id'] as String,
    );
  }

  BookingEvent? _mapUpdate(Map<String, dynamic> row) {
    if (row['status'] == 'cancelled') {
      return BookingFreed(
        venueId: row['venue_id'] as String,
        slotStartUtc: DateTime.parse(row['slot_start_utc'] as String),
        bookingId: row['id'] as String,
      );
    }
    if (row['status'] == 'confirmed') {
      return BookingConfirmed(
        venueId: row['venue_id'] as String,
        slotStartUtc: DateTime.parse(row['slot_start_utc'] as String),
        bookingId: row['id'] as String,
      );
    }
    return null;
  }
}
