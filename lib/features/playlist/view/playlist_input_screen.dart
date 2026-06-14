import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/playlist_provider.dart';

class PlaylistInputScreen extends ConsumerStatefulWidget {
  const PlaylistInputScreen({super.key});

  @override
  ConsumerState<PlaylistInputScreen> createState() => _PlaylistInputScreenState();
}

class _PlaylistInputScreenState extends ConsumerState<PlaylistInputScreen> {
  final _urlController = TextEditingController();
  final _fileController = TextEditingController();
  bool _hasUrl = false;
  bool _hasFile = false;

  @override
  void initState() {
    super.initState();
    _urlController.addListener(() {
      setState(() => _hasUrl = _urlController.text.isNotEmpty);
    });
    _fileController.addListener(() {
      setState(() => _hasFile = _fileController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    _fileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Playlist'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.live_tv,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'PrimeView',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Playlist URL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/playlist.m3u',
                prefixIcon: Icon(Icons.link, color: AppColors.textMuted),
              ),
              keyboardType: TextInputType.url,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _hasUrl
                    ? () => _loadFromUrl(_urlController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Load from URL',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Paste M3U Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _fileController,
              decoration: const InputDecoration(
                hintText: 'Paste your M3U playlist content here...',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _hasFile
                    ? () => _loadFromFile(_fileController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Load from Content',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is an M3U playlist?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'An M3U file contains a list of TV channels with their stream URLs. '
                    'You can get one from your IPTV provider. '
                    'The file starts with #EXTM3U and contains #EXTINF entries.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadFromUrl(String url) async {
    if (url.isEmpty) return;

    await ref.read(playlistProvider.notifier).loadFromUrl(url);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _loadFromFile(String content) async {
    if (content.isEmpty) return;

    await ref.read(playlistProvider.notifier).loadFromFile(content);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
