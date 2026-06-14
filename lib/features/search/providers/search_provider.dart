import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/channel_model.dart';
import '../../playlist/providers/playlist_provider.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setLanguageFilter(String? language) {
    state = state.copyWith(selectedLanguage: language);
  }

  List<ChannelModel> filterChannels(List<ChannelModel> allChannels) {
    var filtered = allChannels;

    if (state.query.isNotEmpty) {
      final query = state.query.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(query) ||
            (c.category?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    if (state.selectedCategory != null && state.selectedCategory!.isNotEmpty) {
      filtered = filtered
          .where((c) => c.category == state.selectedCategory)
          .toList();
    }

    if (state.selectedLanguage != null && state.selectedLanguage!.isNotEmpty) {
      filtered = filtered
          .where((c) => c.language == state.selectedLanguage)
          .toList();
    }

    return filtered;
  }
}

class SearchState {
  final String query;
  final String? selectedCategory;
  final String? selectedLanguage;

  const SearchState({
    this.query = '',
    this.selectedCategory,
    this.selectedLanguage,
  });

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLanguage,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

final searchResultsProvider = Provider<List<ChannelModel>>((ref) {
  ref.watch(searchProvider);
  final allChannels = ref.watch(channelsProvider);
  return ref.read(searchProvider.notifier).filterChannels(allChannels);
});
