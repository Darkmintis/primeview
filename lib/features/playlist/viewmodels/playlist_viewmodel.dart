import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/di/injection_container.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/logger.dart';
import '../../../core/utils/html_utils.dart';
import '../services/playlist_service.dart';

enum PlaylistState { idle, loading, loaded, error }

class PlaylistViewModel extends StateNotifier<PlaylistState> {
  final PlaylistService _service;

  PlaylistViewModel(this._service)
      : _channels = [],
        super(PlaylistState.idle) {
    _loadCachedThenRefresh();
  }

  List<ChannelModel> _channels;
  String? _errorMessage;

  List<ChannelModel> get channels => _channels;
  String? get errorMessage => _errorMessage;

  Future<void> _loadCachedThenRefresh() async {
    final cached = _service.loadFromCache();
    if (cached != null && cached.isNotEmpty) {
      _channels = cached;
      state = PlaylistState.loaded;
      AppLogger.info('Loaded ${_channels.length} channels from cache');
    } else {
      state = PlaylistState.loading;
    }

    _service.fetchFromIptvOrg().then((onlineChannels) {
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

  List<String> get countries {
    final cntrs = _channels
        .where((c) => c.country != null && c.country!.isNotEmpty)
        .map((c) => htmlDecode(c.country!))
        .toSet()
        .toList();
    cntrs.sort();
    return cntrs;
  }

  int get channelCount => _channels.length;

  Future<void> loadFromUrl(String url) async {
    if (url.isEmpty) return;
    state = PlaylistState.loading;
    _errorMessage = null;

    try {
      _channels = await _service.loadFromUrl(url);
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
      _channels = await _service.loadFromFile(content);
      state = PlaylistState.loaded;
      AppLogger.info('Loaded ${_channels.length} channels from file');
    } catch (e) {
      _errorMessage = e.toString();
      state = PlaylistState.error;
      AppLogger.error('Failed to load local playlist', error: e);
    }
  }
}

final playlistProvider = StateNotifierProvider<PlaylistViewModel, PlaylistState>((ref) {
  return PlaylistViewModel(sl<PlaylistService>());
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

final countriesProvider = Provider<List<String>>((ref) {
  ref.watch(playlistProvider);
  return ref.watch(playlistProvider.notifier).countries;
});
