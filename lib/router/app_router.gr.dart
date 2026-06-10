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
    required String venueId,
    List<PageRouteInfo>? children,
  }) : super(
         VenueDetailRoute.name,
         args: VenueDetailRouteArgs(key: key, venueId: venueId),
         initialChildren: children,
       );

  static const String name = 'VenueDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<VenueDetailRouteArgs>();
      return VenueDetailPage(key: args.key, venueId: args.venueId);
    },
  );
}

class VenueDetailRouteArgs {
  const VenueDetailRouteArgs({this.key, required this.venueId});

  final Key? key;

  final String venueId;

  @override
  String toString() {
    return 'VenueDetailRouteArgs{key: $key, venueId: $venueId}';
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
