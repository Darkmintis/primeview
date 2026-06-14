import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/playlist/repositories/playlist_repository.dart';
import '../../features/playlist/services/playlist_service.dart';
import '../../features/favorites/repositories/favorites_repository.dart';
import '../../features/favorites/services/favorites_service.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  try {
    final appDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDir.path);
    await Hive.openBox(AppConstants.hiveBoxName);

    sl.registerLazySingleton<PlaylistRepository>(() => PlaylistRepository());
    sl.registerLazySingleton<PlaylistService>(
      () => PlaylistService(sl<PlaylistRepository>()),
    );
    sl.registerLazySingleton<FavoritesRepository>(() => FavoritesRepository());
    sl.registerLazySingleton<FavoritesService>(
      () => FavoritesService(sl<FavoritesRepository>()),
    );

    AppLogger.info('Dependencies initialized successfully');
  } catch (e) {
    AppLogger.error('Failed to initialize dependencies', error: e);
    rethrow;
  }
}
