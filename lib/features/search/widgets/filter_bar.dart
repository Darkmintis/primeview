import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_provider.dart';
import '../viewmodels/search_provider.dart';

class FilterBar extends ConsumerWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final languages = ref.watch(languagesProvider);
    final countries = ref.watch(countriesProvider);
    final searchState = ref.watch(searchProvider);

    final hasActiveFilters = searchState.selectedCategory != null ||
        searchState.selectedLanguage != null ||
        searchState.selectedCountry != null;

    return Container(
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _Chip(
                    label: hasActiveFilters ? 'Filters' : 'All Categories',
                    isSelected: searchState.selectedCategory == null &&
                        searchState.selectedLanguage == null &&
                        searchState.selectedCountry == null,
                    onTap: () => ref.read(searchProvider.notifier).clearFilters(),
                  );
                }
                if (index == 1) {
                  return _Chip(
                    label: hasActiveFilters ? 'Clear' : 'All Categories',
                    isSelected: searchState.selectedCategory == null &&
                        searchState.selectedLanguage == null &&
                        searchState.selectedCountry == null,
                    onTap: () => ref.read(searchProvider.notifier).clearFilters(),
                    hidden: !hasActiveFilters,
                  );
                }
                return _buildFilterChip(
                  label: categories[index - 2],
                  isSelected: searchState.selectedCategory == categories[index - 2],
                  onTap: () => ref
                      .read(searchProvider.notifier)
                      .setCategoryFilter(
                        searchState.selectedCategory == categories[index - 2]
                            ? null
                            : categories[index - 2],
                      ),
                  activeColor: AppColors.primary,
                );
              },
            ),
          ),
          if (searchState.selectedCategory != null ||
              searchState.selectedLanguage != null ||
              searchState.selectedCountry != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Text(
                'Active: ${[
                  if (searchState.selectedCategory != null) 'Category: ${searchState.selectedCategory}',
                  if (searchState.selectedLanguage != null) 'Lang: ${searchState.selectedLanguage}',
                  if (searchState.selectedCountry != null) 'Country: ${searchState.selectedCountry}',
                ].join(' | ')}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (languages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 4),
              child: SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    return _buildFilterChip(
                      label: lang,
                      isSelected: searchState.selectedLanguage == lang,
                      onTap: () => ref
                          .read(searchProvider.notifier)
                          .setLanguageFilter(
                            searchState.selectedLanguage == lang ? null : lang,
                          ),
                      activeColor: AppColors.primary,
                      compact: true,
                    );
                  },
                ),
              ),
            ),
          if (countries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 4, bottom: 8),
              child: SizedBox(
                height: 32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: countries.length,
                  itemBuilder: (context, index) {
                    final country = countries[index];
                    return _buildFilterChip(
                      label: country,
                      isSelected: searchState.selectedCountry == country,
                      onTap: () => ref
                          .read(searchProvider.notifier)
                          .setCountryFilter(
                            searchState.selectedCountry == country ? null : country,
                          ),
                      activeColor: AppColors.primary,
                      compact: true,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    bool compact = false,
    Color activeColor = AppColors.primary,
    bool hidden = false,
  }) {
    if (hidden) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 14,
            vertical: compact ? 4 : 6,
          ),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? activeColor : AppColors.divider,
              width: 1,
            ),
          ),
          child: Text(
            htmlDecode(label),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: compact ? 11 : 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool hidden;

  const _Chip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.hidden = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hidden) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
