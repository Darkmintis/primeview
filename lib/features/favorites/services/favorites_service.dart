import '../repositories/favorites_repository.dart';

class FavoritesService {
  final FavoritesRepository _repository;

  FavoritesService(this._repository);

  Set<String> getFavorites() {
    return _repository.getAll();
  }

  bool isFavorite(String channelId) {
    return _repository.exists(channelId);
  }

  Future<void> toggle(String channelId) async {
    if (_repository.exists(channelId)) {
      await _repository.remove(channelId);
    } else {
      await _repository.add(channelId);
    }
  }
}
