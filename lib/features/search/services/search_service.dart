import '../../../core/models/channel_model.dart';
import '../../../core/utils/html_utils.dart';

class SearchService {
  List<ChannelModel> filter({
    required List<ChannelModel> channels,
    required String query,
    String? category,
    String? language,
    String? country,
  }) {
    var filtered = channels;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      filtered = filtered.where((c) {
        return c.name.toLowerCase().contains(q) ||
            (c.category?.toLowerCase().contains(q) ?? false) ||
            (c.country?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    if (category != null && category.isNotEmpty) {
      filtered = filtered
          .where((c) => htmlDecode(c.category ?? '') == category)
          .toList();
    }

    if (language != null && language.isNotEmpty) {
      filtered = filtered
          .where((c) => c.language == language)
          .toList();
    }

    if (country != null && country.isNotEmpty) {
      filtered = filtered
          .where((c) => c.country == country)
          .toList();
    }

    return filtered;
  }
}
