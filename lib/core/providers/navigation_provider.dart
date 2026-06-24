import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TabIndex { home, search, favorites, settings }

final currentTabProvider = StateProvider<TabIndex>((ref) => TabIndex.home);
