import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../playlist/viewmodels/playlist_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120.h,
            pinned: true,
            backgroundColor: AppColors.background,
            title: Text(
              'Settings',
              style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(left: 16.w, bottom: 48.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.white,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Customize your experience',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Playback'),
                  SizedBox(height: 12.h),
                  _SettingsTile(
                    icon: Icons.play_circle_outline,
                    title: 'Auto-play on start',
                    subtitle: 'Automatically play when opening a channel',
                    trailing: Switch(
                      value: settings.autoPlay,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setAutoPlay(v),
                      activeTrackColor: AppColors.primary,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.history,
                    title: 'Remember last channel',
                    subtitle: 'Resume from last watched channel',
                    trailing: Switch(
                      value: settings.rememberLastChannel,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setRememberLastChannel(v),
                      activeTrackColor: AppColors.primary,
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.open_in_new,
                    title: 'External player',
                    subtitle: 'Open streams in external video player',
                    trailing: Switch(
                      value: settings.useExternalPlayer,
                      onChanged: (v) =>
                          ref.read(settingsProvider.notifier).setUseExternalPlayer(v),
                      activeTrackColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _SectionHeader(title: 'Playlist'),
                  SizedBox(height: 12.h),
                  _SettingsTile(
                    icon: Icons.link,
                    title: 'Playlist URL',
                    subtitle: settings.playlistUrl.length > 50
                        ? '${settings.playlistUrl.substring(0, 50)}...'
                        : settings.playlistUrl,
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20.sp,
                    ),
                    onTap: () => _showPlaylistUrlDialog(context, ref, settings.playlistUrl),
                  ),
                  _SettingsTile(
                    icon: Icons.refresh,
                    title: 'Refresh playlist',
                    subtitle: 'Fetch latest channels from source',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20.sp,
                    ),
                    onTap: () {
                      ref.read(playlistProvider.notifier).loadFromUrl(
                            settings.playlistUrl,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Refreshing playlist...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),
                  _SectionHeader(title: 'About'),
                  SizedBox(height: 12.h),
                  _SettingsTile(
                    icon: Icons.info_outline,
                    title: AppConstants.appName,
                    subtitle: 'Version ${AppConstants.appVersion}',
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20.sp,
                    ),
                    onTap: () => _showAbout(context),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: Container(
                      width: 64.w,
                      height: 64.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.premiumGradient,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.live_tv,
                          color: Colors.white,
                          size: 32.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      AppConstants.appName,
                    style: GoogleFonts.rubikDirt(
                      color: AppColors.primary,
                      fontSize: 24.sp,
                      letterSpacing: 1.5,
                    ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Center(
                    child: Text(
                      'Premium IPTV Experience',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlaylistUrlDialog(BuildContext context, WidgetRef ref, String currentUrl) {
    final controller = TextEditingController(text: currentUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Playlist URL',
          style: TextStyle(color: Colors.white, fontSize: 18.sp),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: 'Enter M3U playlist URL',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(settingsProvider.notifier).setPlaylistUrl(controller.text);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Playlist URL updated'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(
              'Save',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.premiumGradient,
        ),
        child: Icon(Icons.live_tv, color: Colors.white, size: 24),
      ),
      children: [
        SizedBox(height: 8),
        Text(
          'PrimeView is a premium IPTV streaming application.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 16.h,
          decoration: BoxDecoration(
            gradient: AppColors.premiumGradient,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: AppColors.primaryLight, size: 18.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
