import 'package:swades_hackathon_app/data/api/bookings_api.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/data/repositories/_dio_failure_mapper.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class BookingsRepository {
  BookingsRepository({required BookingsApi bookingsApi}) : _api = bookingsApi;

  final BookingsApi _api;

  Future<Result<Booking>> createBooking({
    required String venueId,
    required String slotStartUtc,
  }) async {
    try {
      final raw = await _api.createBooking(
        venueId: venueId,
        slotStartUtc: slotStartUtc,
      );
      return Success(Booking.fromJson(raw));
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }

  Future<Result<List<Booking>>> listUserBookings(String userId) async {
    try {
      final raw = await _api.listUserBookings(userId);
      return Success(raw.map(Booking.fromJson).toList());
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }

  Future<Result<Booking>> cancelBooking(String bookingId) async {
    try {
      final raw = await _api.cancelBooking(bookingId);
      return Success(Booking.fromJson(raw));
    } catch (e) {
      return FailureResult(mapDioError(e));
    }
  }
}
