import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/modules/bookings/views/my_bookings_page.dart';
import 'package:swades_hackathon_app/modules/login/views/login_page.dart';
import 'package:swades_hackathon_app/modules/venues/views/venue_detail_page.dart';
import 'package:swades_hackathon_app/modules/venues/views/venues_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: LoginRoute.page, initial: true, path: '/'),
        AutoRoute(page: VenuesRoute.page, path: '/venues'),
        AutoRoute(page: VenueDetailRoute.page, path: '/venue-detail'),
        AutoRoute(page: MyBookingsRoute.page, path: '/my-bookings'),
      ];
}
