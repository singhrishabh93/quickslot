// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [LoginPage]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginPage();
    },
  );
}

/// generated route for
/// [MyBookingsPage]
class MyBookingsRoute extends PageRouteInfo<void> {
  const MyBookingsRoute({List<PageRouteInfo>? children})
    : super(MyBookingsRoute.name, initialChildren: children);

  static const String name = 'MyBookingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MyBookingsPage();
    },
  );
}

/// generated route for
/// [VenueDetailPage]
class VenueDetailRoute extends PageRouteInfo<VenueDetailRouteArgs> {
  VenueDetailRoute({
    Key? key,
    required Venue venue,
    List<PageRouteInfo>? children,
  }) : super(
         VenueDetailRoute.name,
         args: VenueDetailRouteArgs(key: key, venue: venue),
         initialChildren: children,
       );

  static const String name = 'VenueDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VenueDetailRouteArgs>();
      return VenueDetailPage(key: args.key, venue: args.venue);
    },
  );
}

class VenueDetailRouteArgs {
  const VenueDetailRouteArgs({this.key, required this.venue});

  final Key? key;

  final Venue venue;

  @override
  String toString() {
    return 'VenueDetailRouteArgs{key: $key, venue: $venue}';
  }
}

/// generated route for
/// [VenuesPage]
class VenuesRoute extends PageRouteInfo<void> {
  const VenuesRoute({List<PageRouteInfo>? children})
    : super(VenuesRoute.name, initialChildren: children);

  static const String name = 'VenuesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const VenuesPage();
    },
  );
}
