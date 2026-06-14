import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_provider.dart';
import '../../playlist/widgets/channel_list_item.dart';
import '../viewmodels/search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final channels = ref.read(channelsProvider);
    final allCategories =
        channels
            .map((c) => htmlDecode(c.category ?? ''))
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final allCountries =
        channels
            .map((c) => c.country)
            .where((c) => c != null && c.isNotEmpty)
            .map((c) => c!)
            .toSet()
            .toList()
          ..sort();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _FilterSheet(
          categories: AppConstants.predefinedCategories
              .where((c) => allCategories.contains(c))
              .toList(),
          countries: allCountries,
          onApply: (category, country) {
            ref.read(searchProvider.notifier).setCategoryFilter(category);
            ref.read(searchProvider.notifier).setCountryFilter(country);
            Navigator.of(ctx).pop();
          },
          selectedCategory: ref.read(searchProvider).selectedCategory,
          selectedCountry: ref.read(searchProvider).selectedCountry,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchState = ref.watch(searchProvider);
    final channels = ref.watch(channelsProvider);

    final hasFilters =
        searchState.selectedCategory != null ||
        searchState.selectedCountry != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 8,
                  top: 56,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search channels...',
                          hintStyle: TextStyle(
                            color: AppColors.textMuted.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasFilters)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              IconButton(
                                icon: const Icon(
                                  Icons.filter_list,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: _showFilterSheet,
                              ),
                              if (_searchController.text.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: AppColors.textMuted,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchProvider.notifier)
                                        .setQuery('');
                                  },
                                ),
                            ],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          ref.read(searchProvider.notifier).setQuery(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (hasFilters)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_alt,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Filters: ${[if (searchState.selectedCategory != null) '${searchState.selectedCategory}', if (searchState.selectedCountry != null) '${searchState.selectedCountry}'].join(', ')}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        ref.read(searchProvider.notifier).clearFilters();
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (searchState.query.isNotEmpty || searchResults.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '${searchResults.length} of ${channels.length} channels',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          if (searchState.query.isEmpty && !hasFilters)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.live_tv_outlined,
                      size: 72,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${channels.length} channels available',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Search or tap filter to find channels',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (searchResults.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.search_off,
                      size: 64,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No channels found',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters or search term',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ChannelListItem(channel: searchResults[index]),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> categories;
  final List<String> countries;
  final void Function(String? category, String? country) onApply;
  final String? selectedCategory;
  final String? selectedCountry;

  const _FilterSheet({
    required this.categories,
    required this.countries,
    required this.onApply,
    this.selectedCategory,
    this.selectedCountry,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _category;
  String? _country;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _country = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Filter Channels',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _filterChip('All', _category == null, () => setState(() => _category = null)),
                    ...widget.categories.map(
                      (c) => _filterChip(c, _category == c, () => setState(() => _category = c)),
                    ),
                  ],
                ),
                if (widget.countries.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Text(
                    'Country',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.countries.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _countryChip('All Countries', _country == null,
                            () => setState(() => _country = null));
                      }
                      final country = widget.countries[index - 1];
                      return _countryChip(
                        country, _country == country,
                        () => setState(() => _country = country),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_category, _country),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          htmlDecode(label),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _countryChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.white : AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              htmlDecode(label),
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
