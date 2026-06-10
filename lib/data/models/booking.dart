import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';

enum BookingStatus { confirmed, cancelled, unknown }

BookingStatus _statusFromString(String s) => switch (s) {
      'confirmed' => BookingStatus.confirmed,
      'cancelled' => BookingStatus.cancelled,
      _ => BookingStatus.unknown,
    };

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.slotStartUtc,
    required this.status,
    required this.createdAt,
    this.cancelledAt,
    this.venue,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      venueId: json['venue_id'] as String,
      slotStartUtc: DateTime.parse(json['slot_start_utc'] as String),
      status: _statusFromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      venue: json['venue'] == null
          ? null
          : Venue.fromJson(json['venue'] as Map<String, dynamic>),
    );
  }

  final String id;
  final String userId;
  final String venueId;
  final DateTime slotStartUtc;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final Venue? venue;

  @override
  List<Object?> get props => [
        id,
        userId,
        venueId,
        slotStartUtc,
        status,
        createdAt,
        cancelledAt,
        venue,
      ];
}
