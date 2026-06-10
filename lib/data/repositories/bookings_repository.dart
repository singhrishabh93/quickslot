import 'package:swades_hackathon_app/data/api/bookings_api.dart';
import 'package:swades_hackathon_app/data/local/bookings_cache.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/data/repositories/_dio_failure_mapper.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';
import 'package:swades_hackathon_app/data/utils/result.dart';

class BookingsRepository {
  BookingsRepository({
    required BookingsApi bookingsApi,
    required BookingsCache cache,
  })  : _api = bookingsApi,
        _cache = cache;

  final BookingsApi _api;
  final BookingsCache _cache;

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
      await _cache.save(userId, raw);
      return Success(raw.map(Booking.fromJson).toList());
    } catch (e) {
      final failure = mapDioError(e);
      if (failure is NetworkFailure) {
        final cached = _cache.load(userId);
        if (cached != null) {
          return Success(
            cached.map(Booking.fromJson).toList(),
            isFromCache: true,
            cacheStamp: _cache.loadStamp(userId),
          );
        }
      }
      return FailureResult(failure);
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
