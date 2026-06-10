import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/repositories/venues_repository.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_state.dart';

class VenueDetailCubit extends Cubit<VenueDetailState> {
  VenueDetailCubit({
    required Venue venue,
    required VenuesRepository venuesRepository,
  })  : _repo = venuesRepository,
        super(
          VenueDetailState(
            venue: venue,
            selectedDate: _today(),
          ),
        );

  final VenuesRepository _repo;

  Future<void> init() => _fetchSlots();

  Future<void> changeDate(DateTime date) async {
    if (_isSameDay(date, state.selectedDate)) return;
    emit(state.copyWith(selectedDate: date));
    await _fetchSlots();
  }

  Future<void> refresh() => _fetchSlots();

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

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
