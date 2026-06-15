import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/utils/logger.dart';

class PlayerState {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final bool isPlaying;
  final bool isFullScreen;
  final Duration position;
  final Duration duration;
  final double volume;
  final bool isMuted;
  final double brightness;
  final double playbackSpeed;
  final bool showControls;
  final bool hasError;
  final String? errorMessage;
  final bool isLoading;

  const PlayerState({
    this.controller,
    this.isInitialized = false,
    this.isPlaying = false,
    this.isFullScreen = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.isMuted = false,
    this.brightness = 1.0,
    this.playbackSpeed = 1.0,
    this.showControls = true,
    this.hasError = false,
    this.errorMessage,
    this.isLoading = true,
  });

  PlayerState copyWith({
    VideoPlayerController? controller,
    bool? isInitialized,
    bool? isPlaying,
    bool? isFullScreen,
    Duration? position,
    Duration? duration,
    double? volume,
    bool? isMuted,
    double? brightness,
    double? playbackSpeed,
    bool? showControls,
    bool? hasError,
    String? errorMessage,
    bool? isLoading,
  }) {
    return PlayerState(
      controller: controller ?? this.controller,
      isInitialized: isInitialized ?? this.isInitialized,
      isPlaying: isPlaying ?? this.isPlaying,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      brightness: brightness ?? this.brightness,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      showControls: showControls ?? this.showControls,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PlayerViewModel extends StateNotifier<PlayerState> {
  PlayerViewModel() : super(const PlayerState());

  Future<void> initialize(String url) async {
    state = state.copyWith(isLoading: true, hasError: false, errorMessage: null);

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      state = state.copyWith(controller: controller);

      await controller.initialize();
      controller.addListener(_onControllerUpdate);
      controller.play();

      state = state.copyWith(
        isInitialized: true,
        isPlaying: true,
        isLoading: false,
        duration: controller.value.duration,
      );

      AppLogger.info('Player initialized: ${url.substring(0, min(80, url.length))}...');
    } catch (e) {
      AppLogger.error('Failed to initialize player', error: e);
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load stream. The URL may be invalid or the stream is offline.',
      );
    }
  }

  void _onControllerUpdate() {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.hasError) {
      AppLogger.error('Video player error: ${controller.value.errorDescription}');
      state = state.copyWith(
        hasError: true,
        errorMessage: controller.value.errorDescription ?? 'Playback error occurred',
        isPlaying: false,
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(
      isPlaying: controller.value.isPlaying,
      position: controller.value.position,
      duration: controller.value.duration,
      isLoading: false,
    );
  }

  void play() {
    final controller = state.controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state.hasError) return;
    controller.play();
    state = state.copyWith(isPlaying: true);
  }

  void pause() {
    state.controller?.pause();
    state = state.copyWith(isPlaying: false);
  }

  void togglePlayPause() {
    if (state.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void seekTo(Duration position) {
    state.controller?.seekTo(position);
  }

  void seekForward([int seconds = 10]) {
    final pos = state.position;
    final dur = state.duration;
    final target = pos + Duration(seconds: seconds);
    seekTo(target > dur ? dur : target);
  }

  void seekBackward([int seconds = 10]) {
    final pos = state.position;
    final target = pos - Duration(seconds: seconds);
    seekTo(target < Duration.zero ? Duration.zero : target);
  }

  void setVolume(double volume) {
    final clamped = volume.clamp(0.0, 1.0);
    state.controller?.setVolume(clamped);
    state = state.copyWith(volume: clamped, isMuted: clamped == 0);
  }

  void toggleMute() {
    final muted = !state.isMuted;
    state.controller?.setVolume(muted ? 0.0 : state.volume);
    state = state.copyWith(isMuted: muted);
  }

  void increaseVolume() {
    setVolume((state.volume + 0.1).clamp(0.0, 1.0));
  }

  void decreaseVolume() {
    setVolume((state.volume - 0.1).clamp(0.0, 1.0));
  }

  void setBrightness(double brightness) {
    state = state.copyWith(brightness: brightness.clamp(0.0, 1.0));
  }

  Future<void> switchChannel(String url) async {
    final oldController = state.controller;
    if (oldController != null) {
      oldController.removeListener(_onControllerUpdate);
      oldController.pause();
      oldController.dispose();
    }
    state = state.copyWith(
      controller: null,
      isInitialized: false,
      isPlaying: false,
      position: Duration.zero,
      duration: Duration.zero,
      hasError: false,
      errorMessage: null,
      isLoading: true,
      showControls: true,
    );
    await initialize(url);
  }

  void setPlaybackSpeed(double speed) {
    final clamped = speed.clamp(0.25, 2.0);
    state.controller?.setPlaybackSpeed(clamped);
    state = state.copyWith(playbackSpeed: clamped);
  }

  void toggleFullScreen() {
    state = state.copyWith(isFullScreen: !state.isFullScreen);
  }

  void showControls() {
    state = state.copyWith(showControls: true);
  }

  void hideControls() {
    state = state.copyWith(showControls: false);
  }

  void toggleControls() {
    state = state.copyWith(showControls: !state.showControls);
  }

  Future<void> retry(String url) async {
    final oldController = state.controller;
    if (oldController != null) {
      oldController.removeListener(_onControllerUpdate);
      oldController.pause();
      oldController.dispose();
    }
    state = const PlayerState();
    await initialize(url);
  }

  @override
  void dispose() {
    final controller = state.controller;
    if (controller != null) {
      controller.removeListener(_onControllerUpdate);
      controller.pause();
      controller.dispose();
    }
    super.dispose();
  }
}

final playerViewModelProvider = StateNotifierProvider.autoDispose<PlayerViewModel, PlayerState>((ref) {
  return PlayerViewModel();
});

int min(int a, int b) => a < b ? a : b;
