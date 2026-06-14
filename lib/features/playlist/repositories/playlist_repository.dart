import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/utils/logger.dart';

class PlaylistRepository {
  PlaylistRepository();

  Future<String> fetchRawPlaylist(String url) async {
    try {
      final content = await DioClient.fetchPlaylistContent(url);
      return content;
    } on DioException catch (e) {
      AppLogger.error('Network error fetching playlist', error: e);
      rethrow;
    }
  }

  Future<void> cachePlaylist(List<ChannelModel> channels) async {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final jsonList = channels
          .map((c) => {
                'id': c.id,
                'name': c.name,
                'url': c.url,
                'logo': c.logo,
                'category': c.category,
                'language': c.language,
                'country': c.country,
                'group': c.group,
                'isActive': c.isActive,
              })
          .toList();
      await box.put(AppConstants.hivePlaylistKey, jsonList);
    } catch (e) {
      AppLogger.error('Failed to cache playlist', error: e);
    }
  }

  List<ChannelModel>? getCachedPlaylist() {
    try {
      final box = Hive.box(AppConstants.hiveBoxName);
      final cached = box.get(AppConstants.hivePlaylistKey) as List<dynamic>?;
      if (cached == null) return null;

      return cached.map((json) {
        final map = Map<String, dynamic>.from(json as Map);
        return ChannelModel(
          id: map['id'] as String,
          name: map['name'] as String,
          url: map['url'] as String,
          logo: map['logo'] as String?,
          category: map['category'] as String?,
          language: map['language'] as String?,
          country: map['country'] as String?,
          group: map['group'] as String?,
          isActive: map['isActive'] as bool? ?? true,
        );
      }).toList();
    } catch (e) {
      AppLogger.error('Failed to read cached playlist', error: e);
      return null;
    }
  }
}
