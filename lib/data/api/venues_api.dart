import 'package:swades_hackathon_app/data/network/dio_client.dart';
import 'package:swades_hackathon_app/data/network/endpoint.dart';

class VenuesApi {
  VenuesApi({required DioClient dioClient}) : _dio = dioClient;

  final DioClient _dio;

  Future<List<Map<String, dynamic>>> listVenues() async {
    final response = await _dio.raw.get<dynamic>(Endpoint.venues);
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> listSlots({
    required String venueId,
    required String date,
  }) async {
    final response = await _dio.raw.get<dynamic>(
      Endpoint.venueSlots(venueId),
      queryParameters: {'date': date},
    );
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
