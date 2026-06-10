import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/booking.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

sealed class CreateBookingState extends Equatable {
  const CreateBookingState();

  @override
  List<Object?> get props => [];
}

class CreateBookingInitial extends CreateBookingState {
  const CreateBookingInitial();
}

class CreateBookingSubmitting extends CreateBookingState {
  const CreateBookingSubmitting();
}

class CreateBookingSuccess extends CreateBookingState {
  const CreateBookingSuccess(this.booking);
  final Booking booking;

  @override
  List<Object?> get props => [booking];
}

class CreateBookingFailureState extends CreateBookingState {
  const CreateBookingFailureState(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
