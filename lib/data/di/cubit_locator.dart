import 'package:get_it/get_it.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venues_list_cubit.dart';

void setupCubitLocator(GetIt getIt) {
  getIt.registerFactory<VenuesListCubit>(
    () => VenuesListCubit(venuesRepository: getIt()),
  );
}
