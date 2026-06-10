import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/slot.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

enum SlotsStatus { initial, loading, success, error }

class VenueDetailState extends Equatable {
  const VenueDetailState({
    required this.venue,
    required this.selectedDate,
    this.slots = const [],
    this.status = SlotsStatus.initial,
    this.failure,
  });

  final Venue venue;
  final DateTime selectedDate;
  final List<Slot> slots;
  final SlotsStatus status;
  final Failure? failure;

  VenueDetailState copyWith({
    DateTime? selectedDate,
    List<Slot>? slots,
    SlotsStatus? status,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return VenueDetailState(
      venue: venue,
      selectedDate: selectedDate ?? this.selectedDate,
      slots: slots ?? this.slots,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [venue, selectedDate, slots, status, failure];
}
