import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({
    super.key,
    required this.venueId,
  });

  final String venueId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Venue')),
      body: Center(child: Text('Venue detail — Feature 8\n$venueId')),
    );
  }
}
