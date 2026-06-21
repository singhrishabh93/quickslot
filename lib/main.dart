import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:swades_hackathon_app/app/view/app.dart';
import 'package:swades_hackathon_app/bootstrap.dart';
import 'package:swades_hackathon_app/data/di/service_locator.dart';
import 'package:swades_hackathon_app/data/network/supabase_config.dart';
import 'package:swades_hackathon_app/modules/sdui/views/sdui_screen_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.anonKey,
    );
  }

  await setupServiceLocator();
  registerSduiModalBuilder();
  await bootstrap(() => const App());
}
