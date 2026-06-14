import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

class FavoritesRepository {
  FavoritesRepository();

  Set<String> getAll() {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final list = box.get(AppConstants.hiveFavoritesKey, defaultValue: <String>[]) as List;
      return Set<String>.from(list);
    } catch (e) {
      AppLogger.error('Failed to read favorites', error: e);
      return {};
    }
  }

  Future<void> add(String channelId) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final favorites = getAll();
      favorites.add(channelId);
      await box.put(AppConstants.hiveFavoritesKey, favorites.toList());
    } catch (e) {
      AppLogger.error('Failed to add favorite', error: e);
      rethrow;
    }
  }

  Future<void> remove(String channelId) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final favorites = getAll();
      favorites.remove(channelId);
      await box.put(AppConstants.hiveFavoritesKey, favorites.toList());
    } catch (e) {
      AppLogger.error('Failed to remove favorite', error: e);
      rethrow;
    }
  }

  bool exists(String channelId) {
    return getAll().contains(channelId);
  }
}
