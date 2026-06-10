import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Check your connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error. Please try again.']);
}

class SlotTakenFailure extends Failure {
  const SlotTakenFailure()
      : super('This slot was just taken by someone else.');
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found.']);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure([super.message = 'You do not have access to this.']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please log in again.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Something went wrong.']);
}
