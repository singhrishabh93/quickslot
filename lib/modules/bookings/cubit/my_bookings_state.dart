import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

enum MyBookingsStatus { initial, loading, success, error }

class MyBookingsState extends Equatable {
  const MyBookingsState({
    this.bookings = const [],
    this.status = MyBookingsStatus.initial,
    this.failure,
    this.cancellingId,
    this.isFromCache = false,
    this.cacheStamp,
  });

  final List<Booking> bookings;
  final MyBookingsStatus status;
  final Failure? failure;
  final String? cancellingId;
  final bool isFromCache;
  final DateTime? cacheStamp;

  MyBookingsState copyWith({
    List<Booking>? bookings,
    MyBookingsStatus? status,
    Failure? failure,
    String? cancellingId,
    bool? isFromCache,
    DateTime? cacheStamp,
    bool clearFailure = false,
    bool clearCancellingId = false,
    bool clearCacheStamp = false,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      cancellingId:
          clearCancellingId ? null : (cancellingId ?? this.cancellingId),
      isFromCache: isFromCache ?? this.isFromCache,
      cacheStamp: clearCacheStamp ? null : (cacheStamp ?? this.cacheStamp),
    );
  }

  @override
  List<Object?> get props => [
        bookings,
        status,
        failure,
        cancellingId,
        isFromCache,
        cacheStamp,
      ];
}
