import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constant/app_constant.dart';
import '../helper/cache_helper.dart';
import '../helper/responsive_nums.dart';

class ShimmerSkeletons {
  static bool get _isDark =>
      CacheHelper.getBool(key: AppConstants.isDarkModeKey) ?? false;

  static Color get _baseColor =>
      _isDark ? Colors.grey[800]! : Colors.grey[300]!;
  static Color get _highlightColor =>
      _isDark ? Colors.grey[700]! : Colors.grey[100]!;

  static Widget chatListSkeleton({bool isFriendsSection = false}) {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: _baseColor,
          highlightColor: _highlightColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 19.w,
                  height: 19.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(isFriendsSection ? 80 : 20),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40.w,
                        height: 2.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 60.w,
                        height: 1.5.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 2.w),
                Container(
                  width: 10.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget marketGridSkeleton() {
    return GridView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 3.w,
        crossAxisSpacing: 3.w,
        childAspectRatio: 0.7,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: _baseColor,
          highlightColor: _highlightColor,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 1.5.h,
                        color: Colors.white,
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        width: 15.w,
                        height: 1.5.h,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget pageSkeleton() {
    return Shimmer.fromColors(
      baseColor: _baseColor,
      highlightColor: _highlightColor,
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40.w, height: 3.h, color: Colors.white),
            SizedBox(height: 3.h),
            Container(width: double.infinity, height: 2.h, color: Colors.white),
            SizedBox(height: 1.h),
            Container(width: double.infinity, height: 2.h, color: Colors.white),
            SizedBox(height: 1.h),
            Container(width: 70.w, height: 2.h, color: Colors.white),
            SizedBox(height: 3.h),
            Container(width: double.infinity, height: 2.h, color: Colors.white),
            SizedBox(height: 1.h),
            Container(width: 80.w, height: 2.h, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
