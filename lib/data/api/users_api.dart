import 'package:swades_hackathon_app/data/network/dio_client.dart';
import 'package:swades_hackathon_app/data/network/endpoint.dart';

class UsersApi {
  UsersApi({required DioClient dioClient}) : _dio = dioClient;

  final DioClient _dio;

  Future<List<Map<String, dynamic>>> listUsers() async {
    final response = await _dio.raw.get<dynamic>(Endpoint.users);
    return (response.data as List<dynamic>).cast<Map<String, dynamic>>();
  }
}
