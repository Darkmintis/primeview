import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/logger.dart';
import '../repositories/favorites_repository.dart';
import '../../playlist/providers/playlist_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesRepository _repository;

  FavoritesNotifier(this._repository) : super({}) {
    _load();
  }

  void _load() {
    state = _repository.getFavorites();
  }

  Future<void> toggle(String channelId) async {
    try {
      await _repository.toggleFavorite(channelId);
      state = _repository.getFavorites();
      AppLogger.debug('Toggled favorite: $channelId');
    } catch (e) {
      AppLogger.error('Failed to toggle favorite', error: e);
    }
  }

  bool isFavorite(String channelId) {
    return state.contains(channelId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(sl<FavoritesRepository>());
});

final favoriteChannelsProvider = Provider<List<ChannelModel>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final channels = ref.watch(channelsProvider);
  return channels.where((c) => favoriteIds.contains(c.id)).toList();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, channelId) {
  return ref.watch(favoritesProvider).contains(channelId);
});
