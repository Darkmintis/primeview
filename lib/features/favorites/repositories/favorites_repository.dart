import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

class FavoritesRepository {
  FavoritesRepository();

  Set<String> getFavorites() {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final list = box.get(AppConstants.hiveFavoritesKey, defaultValue: <String>[]) as List;
      return Set<String>.from(list);
    } catch (e) {
      AppLogger.error('Failed to read favorites', error: e);
      return {};
    }
  }

  Future<void> addFavorite(String channelId) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final favorites = getFavorites();
      favorites.add(channelId);
      await box.put(AppConstants.hiveFavoritesKey, favorites.toList());
    } catch (e) {
      AppLogger.error('Failed to add favorite', error: e);
      rethrow;
    }
  }

  Future<void> removeFavorite(String channelId) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final favorites = getFavorites();
      favorites.remove(channelId);
      await box.put(AppConstants.hiveFavoritesKey, favorites.toList());
    } catch (e) {
      AppLogger.error('Failed to remove favorite', error: e);
      rethrow;
    }
  }

  bool isFavorite(String channelId) {
    return getFavorites().contains(channelId);
  }

  Future<void> toggleFavorite(String channelId) async {
    if (isFavorite(channelId)) {
      await removeFavorite(channelId);
    } else {
      await addFavorite(channelId);
    }
  }
}
