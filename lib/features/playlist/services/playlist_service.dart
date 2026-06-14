import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/m3u_parser.dart';
import '../repositories/playlist_repository.dart';

class PlaylistService {
  final PlaylistRepository _repository;

  PlaylistService(this._repository);

  List<ChannelModel>? loadFromCache() {
    return _repository.getCachedPlaylist();
  }

  Future<List<ChannelModel>> fetchFromIptvOrg() async {
    try {
      final content = await _repository.fetchRawPlaylist(AppConstants.defaultPlaylistUrl);
      final channels = M3uParser.parse(content);
      if (channels.isNotEmpty) {
        await _repository.cachePlaylist(channels);
        return channels;
      }
    } catch (e) {
      AppLogger.warning('Full playlist fetch failed, trying category playlists', error: e);
    }

    try {
      final allChannels = <ChannelModel>[];
      for (final url in AppConstants.categoryPlaylists) {
        try {
          final content = await _repository.fetchRawPlaylist(url);
          final channels = M3uParser.parse(content);
          allChannels.addAll(channels);
        } catch (_) {}
      }
      if (allChannels.isNotEmpty) {
        await _repository.cachePlaylist(allChannels);
        return allChannels;
      }
    } catch (e) {
      AppLogger.error('All playlist fetches failed', error: e);
    }

    return [];
  }

  Future<List<ChannelModel>> loadFromUrl(String url) async {
    final content = await _repository.fetchRawPlaylist(url);
    final channels = M3uParser.parse(content);
    if (channels.isNotEmpty) {
      await _repository.cachePlaylist(channels);
    }
    return channels;
  }

  Future<List<ChannelModel>> loadFromFile(String content) async {
    final channels = M3uParser.parse(content);
    if (channels.isNotEmpty) {
      await _repository.cachePlaylist(channels);
    }
    return channels;
  }
}
