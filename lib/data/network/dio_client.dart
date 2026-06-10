import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/network/endpoint.dart';

class DioClient {
  DioClient({required SessionStorage sessionStorage})
      : _sessionStorage = sessionStorage,
        _dio = Dio();

  final SessionStorage _sessionStorage;
  final Dio _dio;

  Dio get raw => _dio;

  void init() {
    _dio
      ..options.baseUrl = Endpoint.baseUrl
      ..options.connectTimeout = const Duration(seconds: 60)
      ..options.receiveTimeout = const Duration(seconds: 30)
      ..options.sendTimeout = const Duration(seconds: 30)
      ..options.responseType = ResponseType.json
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final userId = _sessionStorage.userId;
          if (userId != null) {
            options.headers['X-User-Id'] = userId;
          }
          handler.next(options);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: false,
          compact: true,
        ),
      );
    }
  }
}
