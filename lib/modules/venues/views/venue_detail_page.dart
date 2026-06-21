import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/modules/sdui/views/sdui_screen_view.dart';

@RoutePage()
class VenueDetailPage extends StatelessWidget {
  const VenueDetailPage({
    super.key,
    required this.venueId,
    this.date,
  });

  final String venueId;
  final String? date;

  String get _path {
    final dateParam = date != null ? '&date=$date' : '';
    return '/sdui/venue-detail?venue_id=$venueId$dateParam';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SLOTS')),
      body: SduiScreenView(key: ValueKey(_path), path: _path),
    );
  }
}
