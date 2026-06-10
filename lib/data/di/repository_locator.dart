import 'package:get_it/get_it.dart';
import 'package:swades_hackathon_app/data/repositories/bookings_repository.dart';
import 'package:swades_hackathon_app/data/repositories/users_repository.dart';
import 'package:swades_hackathon_app/data/repositories/venues_repository.dart';

void setupRepositoryLocator(GetIt getIt) {
  getIt
    ..registerLazySingleton<UsersRepository>(
      () => UsersRepository(usersApi: getIt()),
    )
    ..registerLazySingleton<VenuesRepository>(
      () => VenuesRepository(venuesApi: getIt()),
    )
    ..registerLazySingleton<BookingsRepository>(
      () => BookingsRepository(bookingsApi: getIt()),
    );
}
