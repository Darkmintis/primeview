import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../viewmodels/playlist_viewmodel.dart';

class PlaylistInputView extends ConsumerStatefulWidget {
  const PlaylistInputView({super.key});

  @override
  ConsumerState<PlaylistInputView> createState() => _PlaylistInputViewState();
}

class _PlaylistInputViewState extends ConsumerState<PlaylistInputView> {
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
        title: Text('Add Playlist'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(
                Icons.live_tv,
                size: 72.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Center(
              child: Text(
                'PrimeView',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              'Playlist URL',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/playlist.m3u',
                prefixIcon: Icon(Icons.link, color: AppColors.textMuted),
              ),
              keyboardType: TextInputType.url,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _hasUrl
                    ? () => _loadFromUrl(_urlController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Load from URL',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'OR',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14.sp),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            SizedBox(height: 32.h),
            Text(
              'Paste M3U Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: _fileController,
              decoration: const InputDecoration(
                hintText: 'Paste your M3U playlist content here...',
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 12.sp),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _hasFile
                    ? () => _loadFromFile(_fileController.text)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Load from Content',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What is an M3U playlist?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'An M3U file contains a list of TV channels with their stream URLs. '
                    'You can get one from your IPTV provider. '
                    'The file starts with #EXTM3U and contains #EXTINF entries.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13.sp,
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
