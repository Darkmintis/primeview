import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBlock({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      period: const Duration(milliseconds: 1500),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ChannelLoadingSkeleton extends StatelessWidget {
  const ChannelLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildHeroSkeleton(),
        _buildCategoryBarSkeleton(),
        for (int i = 0; i < 4; i++) _buildRowSkeleton(),
      ],
    );
  }

  Widget _buildHeroSkeleton() {
    return SizedBox(
      height: AppConstants.heroBannerHeight,
      child: Stack(
        children: [
          const ShimmerBlock(
            width: double.infinity,
            height: AppConstants.heroBannerHeight,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerBlock(width: 80, height: 24, borderRadius: 4),
                  SizedBox(height: 12.h),
                  const ShimmerBlock(width: 280, height: 32, borderRadius: 4),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      const ShimmerBlock(width: 120, height: 40, borderRadius: 4),
                      SizedBox(width: 12.w),
                      const ShimmerBlock(width: 100, height: 40, borderRadius: 4),
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

  Widget _buildCategoryBarSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          const ShimmerBlock(width: 60, height: 32, borderRadius: 16),
          SizedBox(width: 8.w),
          const ShimmerBlock(width: 80, height: 32, borderRadius: 16),
          SizedBox(width: 8.w),
          const ShimmerBlock(width: 70, height: 32, borderRadius: 16),
          SizedBox(width: 8.w),
          const ShimmerBlock(width: 90, height: 32, borderRadius: 16),
        ],
      ),
    );
  }

  Widget _buildRowSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: 8.h),
          child: Row(
            children: [
              const ShimmerBlock(width: 160, height: 22, borderRadius: 4),
              const Spacer(),
              const ShimmerBlock(width: 60, height: 16, borderRadius: 4),
            ],
          ),
        ),
        SizedBox(
          height: AppConstants.channelRowHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 7,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBlock(width: 130, height: 130, borderRadius: 8),
                    SizedBox(height: 8.h),
                    const ShimmerBlock(width: 100, height: 14, borderRadius: 4),
                    SizedBox(height: 4.h),
                    const ShimmerBlock(width: 70, height: 12, borderRadius: 4),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
