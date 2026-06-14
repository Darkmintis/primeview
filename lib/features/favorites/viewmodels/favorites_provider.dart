import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/models/channel_model.dart';
import '../services/favorites_service.dart';
import '../../playlist/viewmodels/playlist_provider.dart';

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesService _service;

  FavoritesNotifier(this._service) : super({}) {
    _load();
  }

  void _load() {
    state = _service.getFavorites();
  }

  Future<void> toggle(String channelId) async {
    await _service.toggle(channelId);
    state = _service.getFavorites();
  }

  bool isFavorite(String channelId) {
    return _service.isFavorite(channelId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  return FavoritesNotifier(sl<FavoritesService>());
});

final favoriteChannelsProvider = Provider<List<ChannelModel>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  final channels = ref.watch(channelsProvider);
  return channels.where((c) => favoriteIds.contains(c.id)).toList();
});

final isFavoriteProvider = Provider.family<bool, String>((ref, channelId) {
  return ref.watch(favoritesProvider).contains(channelId);
});
