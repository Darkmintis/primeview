import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/utils/html_utils.dart';
import '../../playlist/viewmodels/playlist_viewmodel.dart';

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

class HomeViewModel extends StateNotifier<HomeState> {
  HomeViewModel() : super(const HomeState());

  void selectCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setFeaturedChannel(ChannelModel channel) {
    state = state.copyWith(featuredChannel: channel);
  }
}

final homeProvider = StateNotifierProvider<HomeViewModel, HomeState>((ref) {
  return HomeViewModel();
});

final curatedCategoriesProvider = Provider<List<String>>((ref) {
  ref.watch(playlistProvider);
  final channels = ref.watch(channelsProvider);
  final available = channels.map((c) => htmlDecode(c.category ?? '')).toSet();

  return AppConstants.predefinedCategories
      .where((cat) => available.contains(cat))
      .toList();
});

final channelRowsProvider = Provider<Map<String, List<ChannelModel>>>((ref) {
  final channels = ref.watch(channelsProvider);
  final curated = ref.watch(curatedCategoriesProvider);
  final rows = <String, List<ChannelModel>>{};

  for (final cat in curated) {
    final catChannels = channels
        .where((c) => htmlDecode(c.category ?? '') == cat)
        .toList();
    if (catChannels.isNotEmpty) {
      rows[cat] = catChannels;
    }
  }

  return rows;
});

final featuredChannelProvider = Provider<ChannelModel?>((ref) {
  final channels = ref.watch(channelsProvider);
  if (channels.isEmpty) return null;

  try {
    final box = Hive.box(AppConstants.hiveBoxName);
    final lastWatchedJson = box.get('last_watched_channel');
    if (lastWatchedJson != null) {
      final data = jsonDecode(lastWatchedJson) as Map<String, dynamic>;
      final lastId = data['id'] as String?;
      if (lastId != null) {
        final match = channels.where((c) => c.id == lastId).firstOrNull;
        if (match != null) return match;
      }
    }
  } catch (_) {}

  return channels.first;
});

void saveLastWatchedChannel(ChannelModel channel) {
  try {
    final box = Hive.box(AppConstants.hiveBoxName);
    box.put(
      'last_watched_channel',
      jsonEncode({
        'id': channel.id,
        'name': channel.name,
        'url': channel.url,
        'logo': channel.logo,
        'category': channel.category,
        'language': channel.language,
        'country': channel.country,
        'quality': channel.quality,
      }),
    );
  } catch (_) {}
}
