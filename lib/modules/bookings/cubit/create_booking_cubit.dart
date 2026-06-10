import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/repositories/bookings_repository.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/create_booking_state.dart';

class CreateBookingCubit extends Cubit<CreateBookingState> {
  CreateBookingCubit({required BookingsRepository bookingsRepository})
      : _repo = bookingsRepository,
        super(const CreateBookingInitial());

  final BookingsRepository _repo;

  Future<void> book({
    required String venueId,
    required String slotStartUtc,
  }) async {
    emit(const CreateBookingSubmitting());
    final result = await _repo.createBooking(
      venueId: venueId,
      slotStartUtc: slotStartUtc,
    );
    result.fold(
      (booking) => emit(CreateBookingSuccess(booking)),
      (failure) => emit(CreateBookingFailureState(failure)),
    );
  }
}
