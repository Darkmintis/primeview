import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../playlist/providers/playlist_provider.dart';
import '../providers/search_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final languages = ref.watch(languagesProvider);
    final searchState = ref.watch(searchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryChip(
                label: 'All',
                isSelected: searchState.selectedCategory == null,
                onTap: () {
                  ref.read(searchProvider.notifier).setCategoryFilter(null);
                },
              ),
              ...categories.map((cat) {
                return _buildCategoryChip(
                  label: cat,
                  isSelected: searchState.selectedCategory == cat,
                  onTap: () {
                    ref.read(searchProvider.notifier).setCategoryFilter(cat);
                  },
                );
              }),
            ],
          ),
        ),
        if (languages.isNotEmpty)
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              children: [
                _buildLanguageChip(
                  label: 'All Languages',
                  isSelected: searchState.selectedLanguage == null,
                  onTap: () {
                    ref.read(searchProvider.notifier).setLanguageFilter(null);
                  },
                ),
                ...languages.map((lang) {
                  return _buildLanguageChip(
                    label: lang,
                    isSelected: searchState.selectedLanguage == lang,
                    onTap: () {
                      ref.read(searchProvider.notifier).setLanguageFilter(lang);
                    },
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceLight,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildLanguageChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textMuted,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.surfaceLight,
        backgroundColor: AppColors.cardBackground,
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.divider,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
