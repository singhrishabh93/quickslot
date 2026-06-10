import 'failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        FailureResult<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        FailureResult<T>(:final failure) => failure,
      };

  R fold<R>(R Function(T data) onSuccess, R Function(Failure failure) onFailure) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      FailureResult<T>(:final failure) => onFailure(failure),
    };
  }
}

class Success<T> extends Result<T> {
  const Success(this.data, {this.isFromCache = false, this.cacheStamp});
  final T data;
  final bool isFromCache;
  final DateTime? cacheStamp;
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  final Failure failure;
}
