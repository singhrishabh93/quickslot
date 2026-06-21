import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:swades_hackathon_app/modules/sdui/views/sdui_screen_view.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: SduiScreenView(path: '/sdui/login')),
    );
  }
}
