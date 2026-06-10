import 'package:dio/dio.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

Failure mapDioError(Object error) {
  if (error is DioException) {
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }

    final status = error.response?.statusCode ?? 0;
    final body = error.response?.data;
    final message = _extractMessage(body);

    return switch (status) {
      401 => UnauthorizedFailure(message ?? 'Please log in again.'),
      403 => ForbiddenFailure(message ?? 'You do not have access to this.'),
      404 => NotFoundFailure(message ?? 'Not found.'),
      409 => const SlotTakenFailure(),
      >= 500 => ServerFailure(message ?? 'Server error. Please try again.'),
      _ => UnknownFailure(message ?? 'Something went wrong.'),
    };
  }
  return const UnknownFailure();
}

String? _extractMessage(Object? body) {
  if (body is Map<String, dynamic>) {
    final m = body['message'];
    if (m is String) return m;
    if (m is List && m.isNotEmpty) return m.first.toString();
  }
  return null;
}
