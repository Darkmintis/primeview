import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../playlist/widgets/channel_list_item.dart';
import '../providers/search_provider.dart';
import '../widgets/filter_bar.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: const InputDecoration(
            hintText: 'Search channels...',
            border: InputBorder.none,
            fillColor: Colors.transparent,
            filled: true,
          ),
          onChanged: (value) {
            ref.read(searchProvider.notifier).setQuery(value);
          },
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                ref.read(searchProvider.notifier).setQuery('');
              },
            ),
        ],
      ),
      body: Column(
        children: [
          const FilterBar(),
          const SizedBox(height: 8),
          if (searchState.query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${searchResults.length} results',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: searchResults.isEmpty && searchState.query.isNotEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.textMuted,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No channels found',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      return ChannelListItem(channel: searchResults[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
