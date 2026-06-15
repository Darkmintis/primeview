import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_viewmodel.dart';
import '../viewmodels/player_viewmodel.dart';

class VideoControls extends ConsumerStatefulWidget {
  final String channelName;
  final ChannelModel currentChannel;
  final ValueChanged<ChannelModel> onChannelChanged;

  const VideoControls({
    super.key,
    required this.channelName,
    required this.currentChannel,
    required this.onChannelChanged,
  });

  @override
  ConsumerState<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends ConsumerState<VideoControls>
    with SingleTickerProviderStateMixin {
  Timer? _hideTimer;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  final bool _controlsLocked = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (mounted && !_controlsLocked) {
        ref.read(playerViewModelProvider.notifier).hideControls();
        _animController.reverse();
      }
    });
  }

  void _onTap() {
    final notifier = ref.read(playerViewModelProvider.notifier);
    final state = ref.read(playerViewModelProvider);
    if (state.hasError) return;

    if (state.showControls) {
      notifier.hideControls();
      _animController.reverse();
      _hideTimer?.cancel();
    } else {
      notifier.showControls();
      _animController.forward();
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final show = playerState.showControls;

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: _onTap,
        ),
        if (show)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.black54,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
        if (show)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTopBar(context),
            ),
          ),
        if (show)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildCenterControls(playerState),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildChannelSwitcherHandle(),
        ),
        if (!show && !playerState.isPlaying)
          _buildCenterPlayOverlay(playerState),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.only(left: 4, top: 4),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                widget.channelName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterControls(PlayerState playerState) {
    return Center(
      child: GestureDetector(
        onTap: () => ref.read(playerViewModelProvider.notifier).togglePlayPause(),
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          child: Icon(
            playerState.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 44,
          ),
        ),
      ),
    );
  }

  Widget _buildCenterPlayOverlay(PlayerState playerState) {
    return Center(
      child: GestureDetector(
        onTap: () => ref.read(playerViewModelProvider.notifier).togglePlayPause(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
        ),
      ),
    );
  }

  Widget _buildChannelSwitcherHandle() {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity! < -200) {
          _openChannelSwitcher();
        }
      },
      child: Container(
        height: 60,
        alignment: Alignment.center,
        child: Container(
          width: 32,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  void _openChannelSwitcher() {
    _hideTimer?.cancel();
    final channels = ref.read(channelsProvider);
    final currentIdx = channels.indexWhere(
      (c) => c.id == widget.currentChannel.id,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.textMuted,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Switch Channel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: channels.length,
                      itemBuilder: (ctx, index) {
                        final channel = channels[index];
                        final isCurrent = index == currentIdx;
                        return _buildChannelItem(channel, isCurrent, index);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChannelItem(ChannelModel channel, bool isCurrent, int index) {
    return GestureDetector(
      onTap: () {
        if (!isCurrent) {
          Navigator.of(context).pop();
          widget.onChannelChanged(channel);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrent ? AppColors.primary.withValues(alpha: 0.15) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                width: 44,
                height: 44,
                child: channel.logo != null && channel.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: channel.logo!,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.tv, color: AppColors.textMuted, size: 20),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surfaceLight,
                          child: const Icon(Icons.tv, color: AppColors.textMuted, size: 20),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceLight,
                        child: const Icon(Icons.tv, color: AppColors.textMuted, size: 20),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    htmlDecode(channel.name),
                    style: TextStyle(
                      color: isCurrent ? AppColors.primary : Colors.white,
                      fontSize: 14,
                      fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.category != null && channel.category!.isNotEmpty)
                    Text(
                      htmlDecode(channel.category!),
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
