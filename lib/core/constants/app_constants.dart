class AppConstants {
  AppConstants._();

  static const String appName = 'PrimeView';
  static const String appVersion = '1.0.0';

  static const String defaultPlaylistUrl = 'https://iptv-org.github.io/iptv/index.m3u';

  static const List<String> categoryPlaylists = [
    'https://iptv-org.github.io/iptv/categories/entertainment.m3u',
    'https://iptv-org.github.io/iptv/categories/sports.m3u',
    'https://iptv-org.github.io/iptv/categories/news.m3u',
    'https://iptv-org.github.io/iptv/categories/movies.m3u',
    'https://iptv-org.github.io/iptv/categories/music.m3u',
    'https://iptv-org.github.io/iptv/categories/kids.m3u',
  ];
  static const Duration connectionTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 60);

  static const String hiveBoxName = 'primeview_cache';
  static const String hiveFavoritesKey = 'favorites';
  static const String hiveRecentlyWatchedKey = 'recently_watched';
  static const String hivePlaylistKey = 'cached_playlist';

  static const String categoryAll = 'All';
  static const String categoryFavorites = 'Favorites';
  static const String categoryRecentlyWatched = 'Recently Watched';

  static const double channelLogoSize = 48.0;
  static const double heroBannerHeight = 380.0;
  static const double channelRowHeight = 180.0;
  static const Duration animationDuration = Duration(milliseconds: 300);

  static const List<String> predefinedCategories = [
    'Live TV',
    'Sports',
    'News',
    'Movies',
    'Entertainment',
    'Music',
    'Documentary',
    'Kids',
  ];
}
