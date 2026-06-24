import '../models/channel_model.dart';

final _qualityPattern = RegExp(
  r'\b(1080[pi]|720[pi]|480[pi]|360[pi]|240[pi]|144[pi]|'
  r'4K|UHD|FHD|HD|SD|'
  r'2160[pi]|1440[pi])\b',
  caseSensitive: false,
);

String? extractQuality(String name) {
  final match = _qualityPattern.firstMatch(name);
  if (match != null) {
    return match.group(0)?.toUpperCase();
  }
  return null;
}

String cleanChannelName(String name) {
  return name.replaceAll(_qualityPattern, '').replaceAll(RegExp(r'\s+'), ' ').trim();
}

ChannelModel processChannelQuality(ChannelModel channel) {
  final quality = extractQuality(channel.name);
  if (quality != null) {
    return channel.copyWith(
      name: cleanChannelName(channel.name),
      quality: quality,
    );
  }
  return channel;
}
