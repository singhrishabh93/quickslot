import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/modules/sdui/views/sdui_screen_view.dart';

@RoutePage()
class MyBookingsPage extends StatelessWidget {
  const MyBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MY BOOKINGS')),
      body: const SduiScreenView(path: '/sdui/my-bookings'),
    );
  }
}
