import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swades_hackathon_app/data/repositories/venues_repository.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venues_list_state.dart';

class VenuesListCubit extends Cubit<VenuesListState> {
  VenuesListCubit({required VenuesRepository venuesRepository})
      : _repo = venuesRepository,
        super(const VenuesListInitial());

  final VenuesRepository _repo;

  Future<void> load() async {
    if (state is! VenuesListSuccess) {
      emit(const VenuesListLoading());
    }
    final result = await _repo.listVenues();
    result.fold(
      (venues) => emit(VenuesListSuccess(venues)),
      (failure) => emit(VenuesListError(failure)),
    );
  }

  Future<void> refresh() => load();
}
