import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/channel_model.dart';
import '../services/search_service.dart';
import '../../playlist/providers/playlist_provider.dart';

class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _service;

  SearchNotifier(this._service) : super(SearchState());

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setCategoryFilter(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setLanguageFilter(String? language) {
    state = state.copyWith(selectedLanguage: language);
  }

  void setCountryFilter(String? country) {
    state = state.copyWith(selectedCountry: country);
  }

  void clearFilters() {
    state = const SearchState();
  }

  List<ChannelModel> filterChannels(List<ChannelModel> allChannels) {
    return _service.filter(
      channels: allChannels,
      query: state.query,
      category: state.selectedCategory,
      language: state.selectedLanguage,
      country: state.selectedCountry,
    );
  }
}

class SearchState {
  final String query;
  final String? selectedCategory;
  final String? selectedLanguage;
  final String? selectedCountry;

  const SearchState({
    this.query = '',
    this.selectedCategory,
    this.selectedLanguage,
    this.selectedCountry,
  });

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLanguage,
    String? selectedCountry,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedCountry: selectedCountry ?? this.selectedCountry,
    );
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(SearchService());
});

final searchResultsProvider = Provider<List<ChannelModel>>((ref) {
  ref.watch(searchProvider);
  final allChannels = ref.watch(channelsProvider);
  return ref.read(searchProvider.notifier).filterChannels(allChannels);
});
