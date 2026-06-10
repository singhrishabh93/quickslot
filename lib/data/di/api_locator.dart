import 'package:get_it/get_it.dart';
import 'package:swades_hackathon_app/data/api/bookings_api.dart';
import 'package:swades_hackathon_app/data/api/users_api.dart';
import 'package:swades_hackathon_app/data/api/venues_api.dart';

void setupApiLocator(GetIt getIt) {
  getIt
    ..registerLazySingleton<UsersApi>(() => UsersApi(dioClient: getIt()))
    ..registerLazySingleton<VenuesApi>(() => VenuesApi(dioClient: getIt()))
    ..registerLazySingleton<BookingsApi>(() => BookingsApi(dioClient: getIt()));
}
