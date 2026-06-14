import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../favorites/viewmodels/favorites_provider.dart';
import '../../player/view/player_screen.dart';

class ChannelListItem extends ConsumerWidget {
  final ChannelModel channel;

  const ChannelListItem({super.key, required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(channel.id));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlayerScreen(channel: channel),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: channel.logo != null && channel.logo!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: channel.logo!,
                            fit: BoxFit.contain,
                            placeholder: (_, _) => _placeholder(),
                            errorWidget: (_, _, _) => _placeholder(),
                          )
                        : _placeholder(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        channel.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag(channel.category ?? 'Uncategorized'),
                          if (channel.language != null) ...[
                            const SizedBox(width: 8),
                            _buildTag(channel.language!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppColors.favorite : AppColors.textMuted,
                  ),
                  onPressed: () {
                    ref.read(favoritesProvider.notifier).toggle(channel.id);
                  },
                ),
                const Icon(
                  Icons.play_circle_fill,
                  color: AppColors.primary,
                  size: 36,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Icon(
        Icons.tv,
        color: AppColors.textMuted,
        size: 32,
      ),
    );
  }
}
