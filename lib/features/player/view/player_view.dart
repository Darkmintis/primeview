import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/player_viewmodel.dart';
import '../widgets/video_controls.dart';

class PlayerView extends ConsumerStatefulWidget {
  final ChannelModel channel;

  const PlayerView({super.key, required this.channel});

  @override
  ConsumerState<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends ConsumerState<PlayerView>
    with WidgetsBindingObserver {
  ChannelModel? _currentChannel;

  @override
  void initState() {
    super.initState();
    _currentChannel = widget.channel;
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _setLandscapePreferred();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(playerViewModelProvider.notifier).initialize(_currentChannel!.url);
    });
  }

  void _setLandscapePreferred() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    WakelockPlus.disable();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(playerViewModelProvider.notifier).pause();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(playerViewModelProvider.notifier).play();
    }
  }

  void _switchChannel(ChannelModel channel) {
    setState(() => _currentChannel = channel);
    ref.read(playerViewModelProvider.notifier).switchChannel(channel.url);
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.watch(playerViewModelProvider);
    final channel = _currentChannel!;

    if (playerState.isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: !playerState.isFullScreen,
        bottom: !playerState.isFullScreen,
        child: _buildContent(playerState, channel),
      ),
    );
  }

  Widget _buildContent(PlayerState playerState, ChannelModel channel) {
    if (playerState.hasError) {
      return _buildErrorView(playerState, channel);
    }

    if (playerState.isLoading && !playerState.isInitialized) {
      return _buildLoadingView(channel);
    }

    if (playerState.isInitialized && playerState.controller != null) {
      final controller = playerState.controller!;
      return LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          return Stack(
            children: [
              if (isLandscape)
                Positioned.fill(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: controller.value.size.width,
                      height: controller.value.size.height,
                      child: VideoPlayer(controller),
                    ),
                  ),
                )
              else
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              VideoControls(
                channelName: channel.name,
                currentChannel: channel,
                onChannelChanged: _switchChannel,
              ),
            ],
          );
        },
      );
    }

    return _buildLoadingView(channel);
  }

  Widget _buildLoadingView(ChannelModel channel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56.w,
            height: 56.h,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            channel.name,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Connecting to stream...',
            style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(PlayerState playerState, ChannelModel channel) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: 72.sp,
              color: AppColors.warning,
            ),
            SizedBox(height: 24.h),
            Text(
              'Unable to play stream',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              playerState.errorMessage ?? 'The stream could not be loaded.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              channel.url,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 11.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 32.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(playerViewModelProvider.notifier).retry(channel.url),
                  icon: const Icon(Icons.refresh),
                  label: Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.textMuted),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
