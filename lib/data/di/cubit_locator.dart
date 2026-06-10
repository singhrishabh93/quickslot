import 'package:get_it/get_it.dart';
import 'package:swades_hackathon_app/data/models/venue.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/create_booking_cubit.dart';
import 'package:swades_hackathon_app/modules/bookings/cubit/my_bookings_cubit.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venue_detail_cubit.dart';
import 'package:swades_hackathon_app/modules/venues/cubit/venues_list_cubit.dart';

void setupCubitLocator(GetIt getIt) {
  getIt
    ..registerFactory<VenuesListCubit>(
      () => VenuesListCubit(venuesRepository: getIt()),
    )
    ..registerFactoryParam<VenueDetailCubit, Venue, void>(
      (venue, _) => VenueDetailCubit(
        venue: venue,
        venuesRepository: getIt(),
      ),
    )
    ..registerFactory<CreateBookingCubit>(
      () => CreateBookingCubit(bookingsRepository: getIt()),
    )
    ..registerFactory<MyBookingsCubit>(
      () => MyBookingsCubit(
        bookingsRepository: getIt(),
        sessionStorage: getIt(),
      ),
    );
}
