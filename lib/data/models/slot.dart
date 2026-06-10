import 'package:equatable/equatable.dart';

class Slot extends Equatable {
  const Slot({
    required this.venueId,
    required this.hour,
    required this.slotStartUtc,
    required this.slotEndUtc,
    required this.isBooked,
    this.bookingId,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    return Slot(
      venueId: json['venue_id'] as String,
      hour: json['hour'] as int,
      slotStartUtc: DateTime.parse(json['slot_start_utc'] as String),
      slotEndUtc: DateTime.parse(json['slot_end_utc'] as String),
      isBooked: json['is_booked'] as bool,
      bookingId: json['booking_id'] as String?,
    );
  }

  final String venueId;
  final int hour;
  final DateTime slotStartUtc;
  final DateTime slotEndUtc;
  final bool isBooked;
  final String? bookingId;

  String get displayRange {
    final start = hour.toString().padLeft(2, '0');
    final end = (hour + 1).toString().padLeft(2, '0');
    return '$start:00 – $end:00';
  }

  Slot copyWith({
    bool? isBooked,
    String? bookingId,
    bool clearBookingId = false,
  }) {
    return Slot(
      venueId: venueId,
      hour: hour,
      slotStartUtc: slotStartUtc,
      slotEndUtc: slotEndUtc,
      isBooked: isBooked ?? this.isBooked,
      bookingId: clearBookingId ? null : (bookingId ?? this.bookingId),
    );
  }

  @override
  List<Object?> get props =>
      [venueId, hour, slotStartUtc, slotEndUtc, isBooked, bookingId];
}
