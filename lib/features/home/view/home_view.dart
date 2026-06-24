import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_viewmodel.dart';
import '../../playlist/view/playlist_input_view.dart';
import '../../player/view/player_view.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/hero_banner.dart';
import '../../../shared/widgets/loading_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  final VoidCallback? onSearchTap;

  const HomeView({super.key, this.onSearchTap});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final channels = ref.watch(channelsProvider);
    final featured = ref.watch(featuredChannelProvider);

    if (playlistState == PlaylistState.loading ||
        playlistState == PlaylistState.idle) {
      return const ChannelLoadingSkeleton();
    }

    if (playlistState == PlaylistState.error) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tv_off, size: 72.sp, color: AppColors.textMuted),
                SizedBox(height: 16.h),
                Text(
                  'No channels available',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  ref.read(playlistProvider.notifier).errorMessage ??
                      'Failed to load channels.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PlaylistInputView(),
                    ),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (channels.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            'No channels found in playlist',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
          ),
        ),
      );
    }

    const crossAxisCount = 3;

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: AppConstants.heroBannerHeight,
            pinned: true,
            floating: false,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: featured != null
                  ? HeroBanner(channel: featured)
                  : Container(color: AppColors.background),
            ),
            title: Image.asset(
              'assets/primeview_logo.png',
              height: 28.h,
              color: AppColors.primary,
              errorBuilder: (_, _, _) => Text(
                'PrimeView',
                style: GoogleFonts.rubikDirt(
                  color: AppColors.primary,
                  fontSize: 26.sp,
                  letterSpacing: 1,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => widget.onSearchTap?.call(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  switch (value) {
                    case 'add_playlist':
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PlaylistInputView(),
                        ),
                      );
                    case 'about':
                      _showAbout(context);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'add_playlist',
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.textPrimary,
                        ),
                        SizedBox(width: 12.w),
                        Text('Add Playlist'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.textPrimary),
                        SizedBox(width: 12.w),
                        Text('About'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 12.h),
              child: Row(
                children: [
                  Text(
                    'All Channels',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${channels.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 0.7,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: channels.length,
              itemBuilder: (context, index) {
                return _ChannelGridCard(channel: channels[index]);
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      children: [const Text('A streaming application for IPTV playlists.')],
    );
  }
}

class _ChannelGridCard extends StatelessWidget {
  final ChannelModel channel;

  const _ChannelGridCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    final hasCountry = channel.country != null && channel.country!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => PlayerView(channel: channel)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(12.r),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1F1F3A), Color(0xFF181830)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: channel.logo != null && channel.logo!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: channel.logo!,
                              fit: BoxFit.contain,
                              placeholder: (_, _) => Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              errorWidget: (_, _, _) => _placeholderIcon(),
                            )
                          : _placeholderIcon(),
                    ),
                    if (hasCountry)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 5.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            channel.country!.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      bottom: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Icon(
                          Icons.play_circle_fill,
                          color: AppColors.primaryLight,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    htmlDecode(channel.name),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          htmlDecode(channel.category ?? ''),
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (channel.language != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: _buildMiniBadge(channel.language!),
                        ),
                      if (channel.quality != null)
                        Padding(
                          padding: EdgeInsets.only(left: 4.w),
                          child: _buildMiniBadge(channel.quality!),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Center(
      child: Icon(
        Icons.live_tv_rounded,
        color: AppColors.textMuted.withValues(alpha: 0.3),
        size: 36.sp,
      ),
    );
  }

  Widget _buildMiniBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 8.sp,
        ),
      ),
    );
  }
}
