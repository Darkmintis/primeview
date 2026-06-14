import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/player_viewmodel.dart';

class VideoControls extends ConsumerStatefulWidget {
  const VideoControls({super.key});

  @override
  ConsumerState<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends ConsumerState<VideoControls>
    with SingleTickerProviderStateMixin {
  Timer? _hideTimer;
  AnimationController? _animController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeInOut,
    );
    _animController!.forward();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _animController?.reverse();
        ref.read(playerViewModelProvider.notifier).hideControls();
      }
    });
  }

  void _onTap() {
    final playerState = ref.read(playerViewModelProvider);
    if (playerState.hasError) return;

    if (!playerState.showControls) {
      ref.read(playerViewModelProvider.notifier).showControlsTemporarily();
      _animController?.forward();
      _startHideTimer();
    } else {
      ref.read(playerViewModelProvider.notifier).togglePlayPause();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final controller = playerState.controller;

    if (controller == null || !playerState.isInitialized || playerState.hasError) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: _onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (playerState.showControls)
            FadeTransition(
              opacity: _fadeAnimation!,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent, Colors.black54],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          if (playerState.showControls) ...[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          playerState.isFullScreen
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          ref.read(playerViewModelProvider.notifier).toggleFullScreen();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () => ref.read(playerViewModelProvider.notifier).togglePlayPause(),
                child: AnimatedOpacity(
                  opacity: playerState.showControls ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black38,
                    ),
                    child: Icon(
                      playerState.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      _buildProgressBar(controller, playerState),
                      const SizedBox(height: 4),
                      _buildBottomRow(playerState),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      VideoPlayerController controller, PlayerState playerState) {
    if (playerState.duration.inSeconds <= 0) {
      return LinearProgressIndicator(
        backgroundColor: AppColors.divider,
        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      );
    }

    return VideoProgressIndicator(
      controller,
      allowScrubbing: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      colors: const VideoProgressColors(
        playedColor: AppColors.primary,
        bufferedColor: AppColors.surfaceLight,
        backgroundColor: AppColors.divider,
      ),
    );
  }

  Widget _buildBottomRow(PlayerState playerState) {
    return Row(
      children: [
        Text(
          _formatDuration(playerState.position),
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        if (playerState.duration.inSeconds > 0) ...[
          const Spacer(),
          Text(
            _formatDuration(playerState.duration),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
