import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../playlist/providers/playlist_provider.dart';

class HomeState {
  final String selectedCategory;
  final ChannelModel? featuredChannel;

  const HomeState({
    this.selectedCategory = AppConstants.categoryAll,
    this.featuredChannel,
  });

  HomeState copyWith({
    String? selectedCategory,
    ChannelModel? featuredChannel,
  }) {
    return HomeState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      featuredChannel: featuredChannel ?? this.featuredChannel,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState());

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setFeaturedChannel(ChannelModel channel) {
    state = state.copyWith(featuredChannel: channel);
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

final channelRowsProvider = Provider<Map<String, List<ChannelModel>>>((ref) {
  final channels = ref.watch(channelsProvider);
  final categories = ref.watch(categoriesProvider);
  final rows = <String, List<ChannelModel>>{};

  for (final cat in categories) {
    final catChannels = channels.where((c) => c.category == cat).toList();
    if (catChannels.isNotEmpty) {
      rows[cat] = catChannels;
    }
  }

  return rows;
});

final featuredChannelProvider = Provider<ChannelModel?>((ref) {
  final channels = ref.watch(channelsProvider);
  if (channels.isEmpty) return null;

  return channels.first;
});
