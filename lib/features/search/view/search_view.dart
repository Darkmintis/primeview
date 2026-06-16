import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        final current = ref.read(searchProvider).selectedCategory;
        return Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Text(
                'Select Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
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
                left: 20.w,
                right: 20.w,
                top: 12.h,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    'Select Country',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: countryController,
                      style: TextStyle(color: Colors.white, fontSize: 14.sp),
                      decoration: InputDecoration(
                        hintText: 'Search countries...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 10.h,
                        ),
                      ),
                      onChanged: (v) =>
                          setSheetState(() => countryQuery = v.toLowerCase()),
                    ),
                  ),
                  SizedBox(height: 8.h),
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12.sp,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (isActive) ...[
              SizedBox(width: 4.w),
              Icon(Icons.close, size: 12.sp, color: AppColors.primary),
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
                left: 16.w,
                right: 16.w,
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 8.h,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: hasFilters ? AppColors.primary : AppColors.divider,
                      width: hasFilters ? 1.5 : 1,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    decoration: InputDecoration(
                      hintText: 'Search channels...',
                      hintStyle: TextStyle(
                        color: AppColors.textMuted.withValues(alpha: 0.7),
                        fontSize: 15.sp,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 16.w, right: 8.w),
                        child: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 22.sp,
                        ),
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasFilters)
                            Padding(
                              padding: EdgeInsets.only(right: 4.w),
                              child: Container(
                                width: 8.w,
                                height: 8.h,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          GestureDetector(
                            onTap: _showFilterSheet,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 12.h,
                              ),
                              child: Icon(
                                Icons.filter_list,
                                color: AppColors.textMuted,
                                size: 22.sp,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                ref.read(searchProvider.notifier).setQuery('');
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 12.h,
                                ),
                                child: Icon(
                                  Icons.clear,
                                  color: AppColors.textMuted,
                                  size: 20.sp,
                                ),
                              ),
                            ),
                          SizedBox(width: 4.w),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
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
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: searchState.selectedCategory ?? 'Category',
                    icon: Icons.category,
                    isActive: searchState.selectedCategory != null,
                    onTap: () => _showCategoryPicker(),
                  ),
                  SizedBox(width: 8.w),
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
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.sp,
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
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                child: Text(
                  '${searchResults.length} of ${channels.length} channels',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.sp,
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
                    Icon(
                      Icons.live_tv_outlined,
                      size: 72.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      '${channels.length} channels available',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Search or tap filter to find channels',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
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
                    Icon(
                      Icons.search_off,
                      size: 64.sp,
                      color: AppColors.textMuted,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'No channels found',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Try adjusting your filters or search term',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14.sp,
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
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          htmlDecode(label),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.white : AppColors.textMuted,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              htmlDecode(label),
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 13.sp,
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
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                SizedBox(height: 20.h),
                Text(
                  'Filter Channels',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
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
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Text(
                        'Country',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${widget.countries.length} countries',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _countrySearchController,
                      style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      decoration: InputDecoration(
                        hintText: 'Search countries...',
                        hintStyle: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.7),
                          fontSize: 13.sp,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.textMuted,
                          size: 18.sp,
                        ),
                        suffixIcon: _countryQuery.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _countrySearchController.clear();
                                  setState(() => _countryQuery = '');
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(12.w),
                                  child: Icon(
                                    Icons.clear,
                                    color: AppColors.textMuted,
                                    size: 18.sp,
                                  ),
                                ),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 10.h,
                        ),
                      ),
                      onChanged: (v) =>
                          setState(() => _countryQuery = v.toLowerCase()),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredCountries.length + 1,
                    separatorBuilder: (_, _) => SizedBox(height: 4.h),
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
                SizedBox(height: 24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => widget.onApply(_category, _country),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(fontSize: 16.sp),
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
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          htmlDecode(label),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: 13.sp,
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
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? Colors.white : AppColors.textMuted,
              size: 18.sp,
            ),
            SizedBox(width: 10.w),
            Text(
              htmlDecode(label),
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
