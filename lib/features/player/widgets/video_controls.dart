import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../../../core/utils/platform_channels.dart';
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

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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
      if (mounted) {
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
          onDoubleTapDown: (details) {
            final dx = details.localPosition.dx;
            final width = context.size?.width ?? 1;
            final notifier = ref.read(playerViewModelProvider.notifier);
            if (dx < width / 3) {
              notifier.seekBackward(10);
            } else if (dx > width * 2 / 3) {
              notifier.seekForward(10);
            }
          },
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -200) {
              _openChannelSwitcher();
            }
          },
        ),
        if (show)
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xBB000000),
                      Colors.transparent,
                      Color(0xBB000000),
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
          child: _buildBottomBar(playerState),
        ),
        if (!show && !playerState.isPlaying)
          Center(
            child: GestureDetector(
              onTap: _onTap,
              child: Container(
                width: 64.w,
                height: 64.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  color: Colors.black26,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 36.sp),
              ),
            ),
          ),
      ],
    );
  }

  void _switchRelative(int offset) {
    final channels = ref.read(channelsProvider);
    final currentIdx = channels.indexWhere(
      (c) => c.id == widget.currentChannel.id,
    );
    if (currentIdx == -1) return;
    final targetIdx = (currentIdx + offset).clamp(0, channels.length - 1);
    if (targetIdx != currentIdx) {
      widget.onChannelChanged(channels[targetIdx]);
    }
  }

  Widget _buildTopBar(BuildContext context) {
    final playerState = ref.read(playerViewModelProvider);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.only(left: 4.w, top: 4.h, right: 4.w),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 26.sp),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Text(
                widget.channelName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _buildVolumeControl(playerState),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeControl(PlayerState playerState) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          Icons.picture_in_picture_alt,
          () => _enterPip(),
        ),
        SizedBox(width: 4.w),
        _buildIconButton(
          playerState.isFullScreen
              ? Icons.fullscreen_exit
              : Icons.fullscreen,
          () => ref.read(playerViewModelProvider.notifier).toggleFullScreen(),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () =>
              ref.read(playerViewModelProvider.notifier).toggleMute(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  playerState.isMuted || playerState.volume == 0
                      ? Icons.volume_off
                      : playerState.volume < 0.5
                          ? Icons.volume_down
                          : Icons.volume_up,
                  color: Colors.white,
                  size: 22.sp,
                ),
                SizedBox(width: 2.w),
                SizedBox(
                  width: 56.w,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3.h,
                      thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 6.r),
                      overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 14.r),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: playerState.isMuted ? 0 : playerState.volume,
                      onChanged: (v) {
                        _hideTimer?.cancel();
                        ref
                            .read(playerViewModelProvider.notifier)
                            .setVolume(v);
                      },
                      onChangeEnd: (_) => _startHideTimer(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w,
        height: 34.h,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: Colors.white, size: 20.sp),
      ),
    );
  }

  void _enterPip() {
    PlatformChannels.enterPip();
  }

  Widget _buildCenterControls(PlayerState playerState) {
    return Center(
      child: GestureDetector(
        onTap: () =>
            ref.read(playerViewModelProvider.notifier).togglePlayPause(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: playerState.isPlaying
                ? Colors.transparent
                : Colors.white.withValues(alpha: 0.15),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Icon(
            playerState.isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 44.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(PlayerState playerState) {
    if (!playerState.showControls) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: Center(
            child: Container(
              width: 32.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => _switchRelative(-1),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.skip_previous,
                          color: Colors.white70, size: 18.sp),
                      SizedBox(width: 4.w),
                      Text('Prev',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              GestureDetector(
                onTap: _openChannelSwitcher,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.list,
                          color: AppColors.primaryLight, size: 18.sp),
                      SizedBox(width: 6.w),
                      Text('Channels',
                          style: TextStyle(
                              color: AppColors.primaryLight, fontSize: 12.sp)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              GestureDetector(
                onTap: () => _switchRelative(1),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Text('Next',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 12.sp)),
                      SizedBox(width: 4.w),
                      Icon(Icons.skip_next,
                          color: Colors.white70, size: 18.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openChannelSwitcher() {
    _hideTimer?.cancel();
    final channels = ref.read(channelsProvider);
    var searchQuery = '';
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = searchQuery.isEmpty
                ? channels
                : channels
                    .where((c) => htmlDecode(c.name)
                        .toLowerCase()
                        .contains(searchQuery))
                    .toList();

            return Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 12.h,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.textMuted,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Container(
                          width: 36.w,
                          height: 36.h,
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Icon(Icons.list,
                              color: AppColors.primary, size: 20.sp),
                        ),
                        SizedBox(width: 12.w),
                        Text('Switch Channel',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold)),
                        Spacer(),
                        Text('${filtered.length}',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14.sp)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: TextField(
                        controller: searchController,
                        style: TextStyle(
                            color: Colors.white, fontSize: 14.sp),
                        decoration: InputDecoration(
                          hintText: 'Search channels...',
                          hintStyle: TextStyle(
                              color: AppColors.textMuted
                                  .withValues(alpha: 0.7),
                              fontSize: 14.sp),
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Icon(Icons.search,
                                color: AppColors.textMuted, size: 20.sp),
                          ),
                          suffixIcon: searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setSheetState(
                                        () => searchQuery = '');
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Icon(Icons.clear,
                                        color: AppColors.textMuted,
                                        size: 18.sp),
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 4.w, vertical: 12.h),
                        ),
                        onChanged: (v) => setSheetState(
                            () => searchQuery = v.toLowerCase()),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text('No channels found',
                                  style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 14.sp)),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, index) {
                                final channel = filtered[index];
                                final isCurrent = channel.id ==
                                    widget.currentChannel.id;
                                return _buildChannelItem(
                                    channel, isCurrent, index);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() => searchController.dispose());
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
        margin: EdgeInsets.symmetric(vertical: 3.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isCurrent ? AppColors.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                width: 44.w,
                height: 44.h,
                child: channel.logo != null && channel.logo!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: channel.logo!,
                        fit: BoxFit.contain,
                        placeholder: (_, _) => Container(
                          color: AppColors.surfaceLight,
                          child: Icon(Icons.tv,
                              color: AppColors.textMuted, size: 20.sp),
                        ),
                        errorWidget: (_, _, _) => Container(
                          color: AppColors.surfaceLight,
                          child: Icon(Icons.tv,
                              color: AppColors.textMuted, size: 20.sp),
                        ),
                      )
                    : Container(
                        color: AppColors.surfaceLight,
                        child: Icon(Icons.tv,
                            color: AppColors.textMuted, size: 20.sp),
                      ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    htmlDecode(channel.name),
                    style: TextStyle(
                      color: isCurrent ? AppColors.primary : Colors.white,
                      fontSize: 14.sp,
                      fontWeight:
                          isCurrent ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channel.category != null &&
                      channel.category!.isNotEmpty)
                    Text(
                      htmlDecode(channel.category!),
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 11.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (isCurrent)
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  gradient: AppColors.premiumGradient,
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text('LIVE',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
          ],
        ),
      ),
    );
  }
}
