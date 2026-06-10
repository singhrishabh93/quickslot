import 'package:flutter/widgets.dart';
import 'package:swades_hackathon_app/app/view/app.dart';
import 'package:swades_hackathon_app/bootstrap.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await bootstrap(() => const App());
}
