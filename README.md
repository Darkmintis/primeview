# PrimeView

IPTV streaming app built with Flutter. Dark-themed, Netflix-style UI for watching live TV channels from M3U playlists.

## Features

- **M3U Playlist Support** — Load from iptv-org, URL, or file
- **Channel Browser** — Grid view with logo, category, country, and language
- **Search & Filter** — Search by name/category, filter by category and country
- **Video Player** — HLS stream playback with full-screen and PIP
- **Favorites** — Save and manage favorite channels with Hive persistence
- **Offline Cache** — Playlist data cached locally for instant launch
- **Shimmer Loading** — Skeleton placeholders during data fetch

## Stack

- **Framework** — Flutter 3.44 / Dart 3.12
- **State** — Riverpod + StateNotifier
- **DI** — get_it (manual)
- **Networking** — Dio with retry interceptors
- **Player** — video_player
- **Storage** — Hive + HiveFlutter
- **Images** — cached_network_image

## Quick Start

```bash
flutter pub get
flutter run
```

## Build

```bash
flutter build apk --debug
flutter build apk --release
```

## Architecture

Feature-first MVVM under `lib/features/`. Each feature has its own providers, screens, and widgets. Core layer handles models, theme, networking, DI, and utilities.
