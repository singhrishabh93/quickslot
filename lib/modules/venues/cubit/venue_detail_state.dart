import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

enum SlotsStatus { initial, loading, success, error }

enum TimeOfDayFilter {
  all,
  morning,
  afternoon,
  evening;

  String get label => switch (this) {
        TimeOfDayFilter.all => 'ALL',
        TimeOfDayFilter.morning => 'MORNING',
        TimeOfDayFilter.afternoon => 'AFTERNOON',
        TimeOfDayFilter.evening => 'EVENING',
      };

  /// IST hour bounds: morning 6-12, afternoon 12-17, evening 17-22.
  bool matches(int hour) => switch (this) {
        TimeOfDayFilter.all => true,
        TimeOfDayFilter.morning => hour >= 6 && hour < 12,
        TimeOfDayFilter.afternoon => hour >= 12 && hour < 17,
        TimeOfDayFilter.evening => hour >= 17 && hour < 22,
      };
}

class VenueDetailState extends Equatable {
  const VenueDetailState({
    required this.venue,
    required this.selectedDate,
    this.slots = const [],
    this.status = SlotsStatus.initial,
    this.failure,
    this.filter = TimeOfDayFilter.all,
  });

  final Venue venue;
  final DateTime selectedDate;
  final List<Slot> slots;
  final SlotsStatus status;
  final Failure? failure;
  final TimeOfDayFilter filter;

  List<Slot> get visibleSlots =>
      slots.where((s) => filter.matches(s.hour)).toList(growable: false);

  VenueDetailState copyWith({
    DateTime? selectedDate,
    List<Slot>? slots,
    SlotsStatus? status,
    Failure? failure,
    TimeOfDayFilter? filter,
    bool clearFailure = false,
  }) {
    return VenueDetailState(
      venue: venue,
      selectedDate: selectedDate ?? this.selectedDate,
      slots: slots ?? this.slots,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props =>
      [venue, selectedDate, slots, status, failure, filter];
}
