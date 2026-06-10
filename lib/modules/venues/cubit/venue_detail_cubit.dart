import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/network/booking_events_service.dart';
import 'package:swades_hackathon_app/data/repositories/venues_repository.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_state.dart';

class VenueDetailCubit extends Cubit<VenueDetailState> {
  VenueDetailCubit({
    required Venue venue,
    required VenuesRepository venuesRepository,
    required BookingEventsService eventsService,
  })  : _repo = venuesRepository,
        _events = eventsService,
        super(
          VenueDetailState(
            venue: venue,
            selectedDate: _today(),
          ),
        );

  final VenuesRepository _repo;
  final BookingEventsService _events;
  StreamSubscription<BookingEvent>? _eventsSub;

  Future<void> init() async {
    _subscribeToRealtime();
    await _fetchSlots();
  }

  Future<void> changeDate(DateTime date) async {
    if (_isSameDay(date, state.selectedDate)) return;
    emit(state.copyWith(selectedDate: date));
    await _fetchSlots();
  }

  Future<void> refresh() => _fetchSlots();

  void changeFilter(TimeOfDayFilter filter) {
    if (filter == state.filter) return;
    emit(state.copyWith(filter: filter));
  }

  void _subscribeToRealtime() {
    _eventsSub?.cancel();
    _eventsSub = _events.watchVenue(state.venue.id).listen(_onEvent);
  }

  void _onEvent(BookingEvent event) {
    if (state.status != SlotsStatus.success) return;
    final idx = state.slots.indexWhere(
      (s) =>
          s.slotStartUtc.millisecondsSinceEpoch ==
          event.slotStartUtc.millisecondsSinceEpoch,
    );
    if (idx == -1) return;

    final slots = [...state.slots];
    switch (event) {
      case BookingConfirmed():
        slots[idx] =
            slots[idx].copyWith(isBooked: true, bookingId: event.bookingId);
      case BookingFreed():
        slots[idx] = slots[idx].copyWith(isBooked: false, clearBookingId: true);
    }
    emit(state.copyWith(slots: slots));
  }

  Future<void> _fetchSlots() async {
    emit(state.copyWith(status: SlotsStatus.loading, clearFailure: true));
    final dateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate);
    final result = await _repo.listSlots(
      venueId: state.venue.id,
      date: dateStr,
    );
    result.fold(
      (slots) => emit(state.copyWith(slots: slots, status: SlotsStatus.success)),
      (failure) =>
          emit(state.copyWith(status: SlotsStatus.error, failure: failure)),
    );
  }

  @override
  Future<void> close() async {
    await _eventsSub?.cancel();
    return super.close();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
