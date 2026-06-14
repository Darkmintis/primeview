import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/html_utils.dart';
import '../repositories/playlist_repository.dart';

enum PlaylistState { idle, loading, loaded, error }

class PlaylistNotifier extends StateNotifier<PlaylistState> {
  final PlaylistRepository _repository;

  PlaylistNotifier(this._repository)
      : _channels = [],
        super(PlaylistState.idle) {
    _loadCachedThenRefresh();
  }

  List<ChannelModel> _channels;
  String? _errorMessage;

  List<ChannelModel> get channels => _channels;
  String? get errorMessage => _errorMessage;

  Future<void> _loadCachedThenRefresh() async {
    final cached = _repository.getCachedPlaylist();
    if (cached != null && cached.isNotEmpty) {
      _channels = cached;
      state = PlaylistState.loaded;
      AppLogger.info('Loaded ${_channels.length} channels from cache');
    } else {
      state = PlaylistState.loading;
    }

    _fetchFromIptvOrg().then((onlineChannels) {
      if (onlineChannels.isNotEmpty) {
        _channels = onlineChannels;
        state = PlaylistState.loaded;
        AppLogger.info('Updated to ${_channels.length} channels from iptv-org');
      }
    }).catchError((e) {
      if (_channels.isEmpty) {
        _errorMessage = 'Failed to load channels. Check your connection and add a playlist.';
        state = PlaylistState.error;
        AppLogger.error('Failed to fetch iptv-org playlist', error: e);
      } else {
        AppLogger.warning('Background refresh failed, using cached channels', error: e);
      }
    });
  }

  Future<List<ChannelModel>> _fetchFromIptvOrg() async {
    try {
      return await _repository.fetchAndParsePlaylist(AppConstants.defaultPlaylistUrl);
    } catch (e) {
      AppLogger.warning('Full playlist fetch failed, trying category playlists', error: e);
    }

    try {
      final allChannels = <ChannelModel>[];
      for (final url in AppConstants.categoryPlaylists) {
        try {
          final channels = await _repository.fetchAndParsePlaylist(url, isCategoryPlaylist: true);
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

  List<String> get categories {
    final cats = _channels.map((c) => htmlDecode(c.category ?? 'Uncategorized')).toSet().toList();
    cats.sort();
    return cats;
  }

  List<String> get languages {
    final langs = _channels
        .where((c) => c.language != null && c.language!.isNotEmpty)
        .map((c) => c.language!)
        .toSet()
        .toList();
    langs.sort();
    return langs;
  }

  int get channelCount => _channels.length;

  Future<void> loadFromUrl(String url) async {
    if (url.isEmpty) return;
    state = PlaylistState.loading;
    _errorMessage = null;

    try {
      _channels = await _repository.fetchAndParsePlaylist(url);
      state = PlaylistState.loaded;
      AppLogger.info('Loaded ${_channels.length} channels from URL');
    } catch (e) {
      _errorMessage = e.toString();
      state = PlaylistState.error;
      AppLogger.error('Failed to load playlist', error: e);
    }
  }

  Future<void> loadFromFile(String content) async {
    if (content.isEmpty) return;
    state = PlaylistState.loading;
    _errorMessage = null;

    try {
      _channels = await _repository.loadPlaylistFromFile(content);
      state = PlaylistState.loaded;
      AppLogger.info('Loaded ${_channels.length} channels from file');
    } catch (e) {
      _errorMessage = e.toString();
      state = PlaylistState.error;
      AppLogger.error('Failed to load local playlist', error: e);
    }
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, PlaylistState>((ref) {
  return PlaylistNotifier(sl<PlaylistRepository>());
});

final channelsProvider = Provider<List<ChannelModel>>((ref) {
  ref.watch(playlistProvider);
  return ref.watch(playlistProvider.notifier).channels;
});

final categoriesProvider = Provider<List<String>>((ref) {
  ref.watch(playlistProvider);
  return ref.watch(playlistProvider.notifier).categories;
});

final languagesProvider = Provider<List<String>>((ref) {
  ref.watch(playlistProvider);
  return ref.watch(playlistProvider.notifier).languages;
});
