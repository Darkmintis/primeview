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

      AppLogger.info('Player initialized and playing: ${url.substring(0, min(80, url.length))}...');
    } catch (e) {
      AppLogger.error('Failed to initialize player for URL', error: e);
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
      isLoading: !controller.value.isInitialized,
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

  void setVolume(double volume) {
    state.controller?.setVolume(volume);
    state = state.copyWith(volume: volume);
  }

  void toggleFullScreen() {
    state = state.copyWith(isFullScreen: !state.isFullScreen);
  }

  void hideControls() {
    state = state.copyWith(showControls: false);
  }

  void showControlsTemporarily() {
    state = state.copyWith(showControls: true);
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
