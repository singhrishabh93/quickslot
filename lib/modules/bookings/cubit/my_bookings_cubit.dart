import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/repositories/bookings_repository.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_state.dart';

class MyBookingsCubit extends Cubit<MyBookingsState> {
  MyBookingsCubit({
    required BookingsRepository bookingsRepository,
    required SessionStorage sessionStorage,
  })  : _repo = bookingsRepository,
        _session = sessionStorage,
        super(const MyBookingsState());

  final BookingsRepository _repo;
  final SessionStorage _session;

  Future<void> load() async {
    final userId = _session.userId;
    if (userId == null) {
      emit(
        state.copyWith(
          status: MyBookingsStatus.error,
          failure: const UnauthorizedFailure(),
        ),
      );
      return;
    }

    if (state.status != MyBookingsStatus.success) {
      emit(state.copyWith(status: MyBookingsStatus.loading, clearFailure: true));
    }

    final result = await _repo.listUserBookings(userId);
    switch (result) {
      case Success(:final data, :final isFromCache, :final cacheStamp):
        emit(
          state.copyWith(
            bookings: data,
            status: MyBookingsStatus.success,
            clearFailure: true,
            clearCancellingId: true,
            isFromCache: isFromCache,
            cacheStamp: cacheStamp,
            clearCacheStamp: !isFromCache,
          ),
        );
      case FailureResult(:final failure):
        emit(
          state.copyWith(status: MyBookingsStatus.error, failure: failure),
        );
    }
  }

  Future<void> refresh() => load();

  /// Returns true on success, false on failure (caller can show snackbar).
  Future<bool> cancelBooking(String bookingId) async {
    emit(state.copyWith(cancellingId: bookingId));
    final result = await _repo.cancelBooking(bookingId);
    return result.fold(
      (_) async {
        await load();
        return true;
      },
      (failure) {
        emit(
          state.copyWith(
            failure: failure,
            clearCancellingId: true,
          ),
        );
        return false;
      },
    );
  }
}
