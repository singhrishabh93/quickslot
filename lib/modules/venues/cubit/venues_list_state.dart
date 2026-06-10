import 'package:equatable/equatable.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/data/utils/failure.dart';

sealed class VenuesListState extends Equatable {
  const VenuesListState();

  @override
  List<Object?> get props => [];
}

class VenuesListInitial extends VenuesListState {
  const VenuesListInitial();
}

class VenuesListLoading extends VenuesListState {
  const VenuesListLoading();
}

class VenuesListSuccess extends VenuesListState {
  const VenuesListSuccess(this.venues);
  final List<Venue> venues;

  @override
  List<Object?> get props => [venues];
}

class VenuesListError extends VenuesListState {
  const VenuesListError(this.failure);
  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
