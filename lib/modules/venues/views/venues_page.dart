import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/modules/sdui/views/sdui_screen_view.dart';
import 'package:swades_hackathon_app/router/app_router.dart';

@RoutePage()
class VenuesPage extends StatelessWidget {
  const VenuesPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await getIt<SessionStorage>().clear();
    if (!context.mounted) return;
    await context.router.replaceAll([const LoginRoute()]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VENUES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.event_note_outlined),
            onPressed: () => context.router.push(const MyBookingsRoute()),
            tooltip: 'My bookings',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Switch user',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: const SduiScreenView(path: '/sdui/venues'),
    );
  }
}
