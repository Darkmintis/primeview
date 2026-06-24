import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/logger.dart';

class SettingsState {
  final String playlistUrl;
  final bool useExternalPlayer;
  final bool autoPlay;
  final bool rememberLastChannel;

  const SettingsState({
    this.playlistUrl = AppConstants.defaultPlaylistUrl,
    this.useExternalPlayer = false,
    this.autoPlay = true,
    this.rememberLastChannel = true,
  });

  SettingsState copyWith({
    String? playlistUrl,
    bool? useExternalPlayer,
    bool? autoPlay,
    bool? rememberLastChannel,
  }) {
    return SettingsState(
      playlistUrl: playlistUrl ?? this.playlistUrl,
      useExternalPlayer: useExternalPlayer ?? this.useExternalPlayer,
      autoPlay: autoPlay ?? this.autoPlay,
      rememberLastChannel: rememberLastChannel ?? this.rememberLastChannel,
    );
  }
}

class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel() : super(const SettingsState()) {
    _load();
  }

  void _load() {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      state = SettingsState(
        playlistUrl: box.get('playlist_url', defaultValue: AppConstants.defaultPlaylistUrl),
        useExternalPlayer: box.get('use_external_player', defaultValue: false),
        autoPlay: box.get('auto_play', defaultValue: true),
        rememberLastChannel: box.get('remember_last_channel', defaultValue: true),
      );
    } catch (e) {
      AppLogger.warning('Failed to load settings from Hive', error: e);
    }
  }

  Future<void> setPlaylistUrl(String url) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      await box.put('playlist_url', url);
      state = state.copyWith(playlistUrl: url);
    } catch (e) {
      AppLogger.error('Failed to save playlist URL', error: e);
    }
  }

  Future<void> setUseExternalPlayer(bool value) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      await box.put('use_external_player', value);
      state = state.copyWith(useExternalPlayer: value);
    } catch (e) {
      AppLogger.error('Failed to save external player setting', error: e);
    }
  }

  Future<void> setAutoPlay(bool value) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      await box.put('auto_play', value);
      state = state.copyWith(autoPlay: value);
    } catch (e) {
      AppLogger.error('Failed to save auto-play setting', error: e);
    }
  }

  Future<void> setRememberLastChannel(bool value) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      await box.put('remember_last_channel', value);
      state = state.copyWith(rememberLastChannel: value);
    } catch (e) {
      AppLogger.error('Failed to save remember last channel setting', error: e);
    }
  }
}

final settingsProvider = StateNotifierProvider.autoDispose<SettingsViewModel, SettingsState>((ref) {
  return SettingsViewModel();
});
