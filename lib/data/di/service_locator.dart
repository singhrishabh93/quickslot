import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swades_hackathon_app/data/di/api_locator.dart';
import 'package:swades_hackathon_app/data/di/cubit_locator.dart';
import 'package:swades_hackathon_app/data/di/repository_locator.dart';
import 'package:swades_hackathon_app/data/local/session_storage.dart';
import 'package:swades_hackathon_app/data/network/dio_client.dart';
import 'package:swades_hackathon_app/router/app_router.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  getIt
    ..registerSingleton<AppRouter>(AppRouter())
    ..registerLazySingleton<SessionStorage>(() => SessionStorage(getIt()))
    ..registerLazySingleton<DioClient>(
      () => DioClient(sessionStorage: getIt()),
    );

  setupApiLocator(getIt);
  setupRepositoryLocator(getIt);
  setupCubitLocator(getIt);

  getIt<DioClient>().init();
}
