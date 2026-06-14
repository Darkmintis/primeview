import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/models/channel_model.dart';
import '../../playlist/providers/playlist_provider.dart';
import '../../playlist/screens/playlist_input_screen.dart';
import '../providers/home_provider.dart';
import '../widgets/hero_banner.dart';
import '../widgets/channel_row.dart';
import '../widgets/category_tabs.dart';
import '../../../shared/widgets/loading_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playlistState = ref.watch(playlistProvider);
    final channels = ref.watch(channelsProvider);
    final categories = ref.watch(categoriesProvider);
    final homeState = ref.watch(homeProvider);

    final channelRows = _buildChannelRows(channels, categories);
    final orderedRows = channelRows.entries.toList(growable: false);
    final featured = channels.isNotEmpty ? channels.first : null;

    return Scaffold(
      body: _buildBody(
        playlistState, channels, orderedRows, featured, homeState,
      ),
    );
  }

  Map<String, List<ChannelModel>> _buildChannelRows(
    List<ChannelModel> channels,
    List<String> categories,
  ) {
    final rows = <String, List<ChannelModel>>{};
    for (final cat in categories) {
      final catChannels = channels.where((c) => c.category == cat).toList();
      if (catChannels.isNotEmpty) {
        rows[cat] = catChannels;
      }
    }
    return rows;
  }

  Widget _buildBody(
    PlaylistState playlistState,
    List<ChannelModel> channels,
    List<MapEntry<String, List<ChannelModel>>> orderedRows,
    ChannelModel? featured,
    HomeState homeState,
  ) {
    switch (playlistState) {
      case PlaylistState.idle:
      case PlaylistState.loading:
        return const ChannelLoadingSkeleton();

      case PlaylistState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.tv_off, size: 72, color: AppColors.textMuted),
                const SizedBox(height: 16),
                const Text(
                  'No channels available',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  ref.read(playlistProvider.notifier).errorMessage ?? 'Failed to load channels.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlaylistInputScreen()),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Playlist'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        );

      case PlaylistState.loaded:
        if (channels.isEmpty) {
          return const Center(
            child: Text(
              'No channels found in playlist',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          );
        }

        return CustomScrollView(
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
                height: 28,
                color: AppColors.primary,
                errorBuilder: (_, _, _) => const Text(
                  'PrimeView',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'add_playlist':
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PlaylistInputScreen()),
                        );
                      case 'about':
                        _showAbout(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'add_playlist',
                      child: Row(
                        children: [
                          Icon(Icons.add_circle_outline, color: AppColors.textPrimary),
                          SizedBox(width: 12),
                          Text('Add Playlist'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.textPrimary),
                          SizedBox(width: 12),
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
                padding: const EdgeInsets.only(left: 16, top: 24, right: 16, bottom: 4),
                child: Row(
                  children: [
                    const Text(
                      'Categories',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${channels.length} channels',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const CategoryTabs(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (homeState.selectedCategory == AppConstants.categoryAll)
              SliverList.builder(
                itemCount: orderedRows.length,
                itemBuilder: (context, index) {
                  final entry = orderedRows[index];
                  return ChannelRow(
                    title: entry.key,
                    channels: entry.value,
                  );
                },
              )
            else
              SliverToBoxAdapter(
                child: ChannelRow(
                  title: homeState.selectedCategory,
                  channels: channels
                      .where((c) => c.category == homeState.selectedCategory)
                      .toList(),
                ),
              ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        );
    }
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      children: [
        const Text('A streaming application for IPTV playlists.'),
      ],
    );
  }
}


