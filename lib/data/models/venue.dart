import 'package:equatable/equatable.dart';

enum Sport { badminton, turf, unknown }

Sport _sportFromString(String s) => switch (s) {
      'badminton' => Sport.badminton,
      'turf' => Sport.turf,
      _ => Sport.unknown,
    };

class Venue extends Equatable {
  const Venue({
    required this.id,
    required this.name,
    required this.sport,
    required this.location,
    required this.pricePerHour,
    required this.opensAtHour,
    required this.closesAtHour,
  });

  factory Venue.fromJson(Map<String, dynamic> json) {
    return Venue(
      id: json['id'] as String,
      name: json['name'] as String,
      sport: _sportFromString(json['sport'] as String),
      location: json['location'] as String,
      pricePerHour: json['price_per_hour'] as int,
      opensAtHour: (json['opens_at_hour'] as int?) ?? 6,
      closesAtHour: (json['closes_at_hour'] as int?) ?? 22,
    );
  }

  final String id;
  final String name;
  final Sport sport;
  final String location;
  final int pricePerHour;
  final int opensAtHour;
  final int closesAtHour;

  @override
  List<Object?> get props =>
      [id, name, sport, location, pricePerHour, opensAtHour, closesAtHour];
}
