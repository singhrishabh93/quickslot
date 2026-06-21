import 'package:dio/dio.dart';
import 'package:swades_hackathon_app/data/network/dio_client.dart';

class SduiApi {
  SduiApi({required DioClient dioClient}) : _dio = dioClient;

  final DioClient _dio;

  /// Fetches an SDUI tree from a relative path on the backend.
  /// The path may include query parameters, e.g. '/sdui/venue-detail?venue_id=...'.
  Future<Map<String, dynamic>> fetchTree(String path) async {
    final response = await _dio.raw.get<dynamic>(path);
    return response.data as Map<String, dynamic>;
  }

  /// Generic API call used by the `api_call` action — relative path,
  /// any method, optional body. X-User-Id is added automatically by the
  /// dio interceptor.
  Future<Response<dynamic>> exec({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) {
    final options = Options(
      method: method,
      // Don't throw on non-2xx — the action handler branches on status
      validateStatus: (_) => true,
    );
    return _dio.raw.request<dynamic>(url, data: body, options: options);
  }
}
