import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../playlist/widgets/channel_list_item.dart';
import '../viewmodels/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteChannels = ref.watch(favoriteChannelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: favoriteChannels.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 72,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No favorites yet',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add channels to your favorites\nby tapping the heart icon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: favoriteChannels.length,
              itemBuilder: (context, index) {
                return ChannelListItem(channel: favoriteChannels[index]);
              },
            ),
    );
  }
}
