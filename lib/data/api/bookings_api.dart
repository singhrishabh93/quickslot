import 'package:swades_hackathon_app/data/network/dio_client.dart';
import 'package:swades_hackathon_app/data/network/endpoint.dart';

class BookingsApi {
  BookingsApi({required DioClient dioClient}) : _dio = dioClient;

  final DioClient _dio;

  Future<Map<String, dynamic>> createBooking({
    required String venueId,
    required String slotStartUtc,
  }) async {
    final response = await _dio.raw.post<dynamic>(
      Endpoint.bookings,
      data: {
        'venue_id': venueId,
        'slot_start_utc': slotStartUtc,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> listUserBookings(String userId) async {
    final response = await _dio.raw.get<dynamic>(Endpoint.userBookings(userId));
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    final response = await _dio.raw.delete<dynamic>(
      Endpoint.bookingById(bookingId),
    );
    return response.data as Map<String, dynamic>;
  }
}
