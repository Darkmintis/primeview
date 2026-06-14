import 'package:uuid/uuid.dart';
import '../models/channel_model.dart';
import 'logger.dart';
import 'html_utils.dart';

class M3uParser {
  M3uParser._();

  static const _uuid = Uuid();

  static List<ChannelModel> parse(String content) {
    try {
      final lines = content.split('\n');
      final channels = <ChannelModel>[];
      final nameSet = <String>{};

      String? currentName;
      String? currentLogo;
      String? currentCategory;
      String? currentLanguage;
      String? currentGroup;

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.startsWith('#EXTINF:')) {
          final metadata = _parseExtInf(line);
          currentName = metadata['name'];
          currentLogo = metadata['logo'];
          currentCategory = metadata['category'];
          currentLanguage = metadata['language'];
          currentGroup = metadata['group'];
        } else if (line.startsWith('http://') || line.startsWith('https://') || line.startsWith('rtmp://') || line.startsWith('rtsp://')) {
          final url = line.trim();

          if (url.isEmpty) continue;

          final channelName = currentName ?? _extractNameFromUrl(url);

          if (channelName.isEmpty) continue;

          final normalizedName = channelName.trim().toLowerCase();

          if (nameSet.contains(normalizedName)) continue;
          nameSet.add(normalizedName);

          channels.add(ChannelModel(
            id: _uuid.v4(),
            name: channelName.trim(),
            url: url,
            logo: currentLogo,
            category: currentCategory ?? 'Uncategorized',
            language: currentLanguage,
            group: currentGroup,
            isActive: true,
          ));

          currentName = null;
          currentLogo = null;
          currentCategory = null;
          currentLanguage = null;
          currentGroup = null;
        }
      }

      AppLogger.info('Parsed ${channels.length} channels from M3U playlist');
      return channels;
    } catch (e) {
      AppLogger.error('Failed to parse M3U content', error: e);
      return [];
    }
  }

  static Map<String, String?> _parseExtInf(String line) {
    String? name;
    String? logo;
    String? category;
    String? language;
    String? group;

    final logoMatch = RegExp(r'tvg-logo="([^"]*)"').firstMatch(line);
    if (logoMatch != null) {
      logo = logoMatch.group(1);
    }

    final groupMatch = RegExp(r'group-title="([^"]*)"').firstMatch(line);
    if (groupMatch != null) {
      group = htmlDecode(groupMatch.group(1)!);
      category = group;
    }

    final languageMatch = RegExp(r'tvg-language="([^"]*)"').firstMatch(line);
    if (languageMatch != null) {
      language = htmlDecode(languageMatch.group(1)!);
    }

    final commaIndex = line.lastIndexOf(',');
    if (commaIndex > 0 && commaIndex < line.length - 1) {
      name = htmlDecode(line.substring(commaIndex + 1).trim());
    }

    return {
      'name': name,
      'logo': logo,
      'category': category,
      'language': language,
      'group': group,
    };
  }

  static String _extractNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.isNotEmpty) {
        final last = segments.last;
        final dotIndex = last.lastIndexOf('.');
        if (dotIndex > 0) {
          return htmlDecode(last.substring(0, dotIndex).replaceAll(RegExp(r'[-_]'), ' '));
        }
        return htmlDecode(last.replaceAll(RegExp(r'[-_]'), ' '));
      }
    } catch (_) {}
    return 'Unknown Channel';
  }

  static bool isValidM3u(String content) {
    return content.trim().startsWith('#EXTM3U');
  }
}
