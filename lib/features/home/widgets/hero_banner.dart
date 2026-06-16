import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/channel_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../player/view/player_view.dart';

class HeroBanner extends ConsumerWidget {
  final ChannelModel channel;

  const HeroBanner({super.key, required this.channel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: AppConstants.heroBannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildCategoryBadge(),
                      if (channel.country != null &&
                          channel.country!.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        _buildInfoBadge(
                          channel.country!.toUpperCase(),
                        ),
                      ],
                      if (channel.language != null &&
                          channel.language!.isNotEmpty) ...[
                        SizedBox(width: 8.w),
                        _buildInfoBadge(channel.language!),
                      ],
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    channel.name,
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      _buildActionButton(
                        label: 'Play',
                        icon: Icons.play_arrow_rounded,
                        isPrimary: true,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PlayerView(channel: channel),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 12.w),
                      _buildActionButton(
                        label: 'Info',
                        icon: Icons.info_outline_rounded,
                        isPrimary: false,
                        onTap: () => _showInfo(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    if (channel.logo != null && channel.logo!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: channel.logo!,
        fit: BoxFit.cover,
        placeholder: (_, _) => _gradientPlaceholder(),
        errorWidget: (_, _, _) => _gradientPlaceholder(),
      );
    }
    return _gradientPlaceholder();
  }

  Widget _gradientPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface,
            AppColors.surfaceLight,
            AppColors.cardBackground,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.live_tv_rounded,
          size: 80.sp,
          color: AppColors.textMuted.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        channel.category ?? 'Channel',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isPrimary
              ? Colors.white
              : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.black : Colors.white,
              size: 22.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: isPrimary ? Colors.black : Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                channel.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              _infoRow('Category', channel.category),
              if (channel.language != null)
                _infoRow('Language', channel.language),
              if (channel.group != null) _infoRow('Group', channel.group),
              SizedBox(height: 16.h),
              Text(
                channel.url,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String? value) {
    if (value == null) return const SizedBox();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
