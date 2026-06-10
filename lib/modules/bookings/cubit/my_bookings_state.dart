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
  });

  final List<Booking> bookings;
  final MyBookingsStatus status;
  final Failure? failure;
  final String? cancellingId;

  MyBookingsState copyWith({
    List<Booking>? bookings,
    MyBookingsStatus? status,
    Failure? failure,
    String? cancellingId,
    bool clearFailure = false,
    bool clearCancellingId = false,
  }) {
    return MyBookingsState(
      bookings: bookings ?? this.bookings,
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
      cancellingId:
          clearCancellingId ? null : (cancellingId ?? this.cancellingId),
    );
  }

  @override
  List<Object?> get props => [bookings, status, failure, cancellingId];
}
