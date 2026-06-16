import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_viewmodel.dart';
import '../../playlist/widgets/channel_list_item.dart';
import '../viewmodels/search_viewmodel.dart';

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
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

  void _showCategoryPicker() {
    final channels = ref.read(channelsProvider);
    final allCategories =
        channels
            .map((c) => htmlDecode(c.category ?? ''))
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final filtered = AppConstants.predefinedCategories
        .where((c) => allCategories.contains(c))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final current = ref.read(searchProvider).selectedCategory;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Select Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _filterChip('All', current == null, () {
                    ref.read(searchProvider.notifier).setCategoryFilter(null);
                    Navigator.of(ctx).pop();
                  }),
                  ...filtered.map(
                    (c) => _filterChip(c, current == c, () {
                      ref.read(searchProvider.notifier).setCategoryFilter(c);
                      Navigator.of(ctx).pop();
                    }),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCountryPicker() {
    final channels = ref.read(channelsProvider);
    final allCountries =
        channels
            .map((c) => c.country)
            .where((c) => c != null && c.isNotEmpty)
            .map((c) => c!)
            .toSet()
            .toList()
          ..sort();
    var countryQuery = '';
    final countryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final current = ref.read(searchProvider).selectedCountry;
            final filtered = countryQuery.isEmpty
                ? allCountries
                : allCountries
                      .where(
                        (c) =>
                            htmlDecode(c).toLowerCase().contains(countryQuery),
                      )
                      .toList();

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    'Select Country',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: countryController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search countries...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) =>
                          setSheetState(() => countryQuery = v.toLowerCase()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _countryChip('All Countries', current == null, () {
                          ref
                              .read(searchProvider.notifier)
                              .setCountryFilter(null);
                          Navigator.of(ctx).pop();
                        }),
                        ...filtered.map(
                          (c) => _countryChip(c, current == c, () {
                            ref
                                .read(searchProvider.notifier)
                                .setCountryFilter(c);
                            Navigator.of(ctx).pop();
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() => countryController.dispose());
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 12, color: AppColors.primary),
            ],
          ],
        ),
      ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: hasFilters ? AppColors.primary : AppColors.divider,
                      width: hasFilters ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search channels...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 15,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 16, right: 8),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 22,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasFilters)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: _showFilterSheet,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 12,
                              ),
                              child: Icon(
                                Icons.filter_list,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                ref.read(searchProvider.notifier).setQuery('');
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 12,
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: AppColors.textMuted,
                                  size: 20,
                                ),
                              ),
                            ),
                          const SizedBox(width: 4),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (value) {
                      ref.read(searchProvider.notifier).setQuery(value);
                    },
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: searchState.selectedCategory ?? 'Category',
                    icon: Icons.category,
                    isActive: searchState.selectedCategory != null,
                    onTap: () => _showCategoryPicker(),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: searchState.selectedCountry ?? 'Country',
                    icon: Icons.flag,
                    isActive: searchState.selectedCountry != null,
                    onTap: () => _showCountryPicker(),
                  ),
                  const Spacer(),
                  if (hasFilters)
                    GestureDetector(
                      onTap: () =>
                          ref.read(searchProvider.notifier).clearFilters(),
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
  final _countrySearchController = TextEditingController();
  String _countryQuery = '';

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _country = widget.selectedCountry;
  }

  @override
  void dispose() {
    _countrySearchController.dispose();
    super.dispose();
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMuted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Filter Channels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _filterChip(
                      'All',
                      _category == null,
                      () => setState(() => _category = null),
                    ),
                    ...widget.categories.map(
                      (c) => _filterChip(
                        c,
                        _category == c,
                        () => setState(() => _category = c),
                      ),
                    ),
                  ],
                ),
                if (widget.countries.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Country',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.countries.length} countries',
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _countrySearchController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search countries...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                        suffixIcon: _countryQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _countrySearchController.clear();
                                  setState(() => _countryQuery = '');
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.clear,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _countryQuery = v.toLowerCase()),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCountries.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _countryChip(
                          'All Countries',
                          _country == null,
                          () => setState(() => _country = null),
                        );
                      }
                      final country = _filteredCountries[index - 1];
                      return _countryChip(
                        country,
                        _country == country,
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
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 16),
                    ),
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

  List<String> get _filteredCountries {
    if (_countryQuery.isEmpty) return widget.countries;
    return widget.countries
        .where((c) => htmlDecode(c).toLowerCase().contains(_countryQuery))
        .toList();
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
