import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_controller.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class FavouriteList extends StatelessWidget {
  final String name;
  final String service;
  final String distance;
  final String rating;
  final String reviews;
  final String price;
  final String imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const FavouriteList({
    super.key,
    required this.name,
    required this.service,
    required this.distance,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.imageUrl,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GetBuilder<HomeController>(
        builder: (controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.08), // Use withOpacity instead of withValues
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CommonImage(
                      imageSrc: imageUrl,
                      width: double.infinity,
                      height: 110.h,
                      fill: BoxFit.cover,
                    ),
                  ),
                  // Favorite Icon - FIXED VERSION
                  Positioned(
                    top: 8.h,
                    left: 6.w,
                    child: Obx(() {
                      final isFav = controller.isFavorite(name);
                      return GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite,
                            size: 24.w,
                            color: AppColors.red,
                          ),
                        ),
                      );
                    }),
                  )

                ],
              ),

              // Content Section
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name
                      CommonText(
                        text: name,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                      ),

                      SizedBox(height: 4.h),

                      // Service with icon
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/propetion_icon.svg",
                            height: 20.h,
                            width: 20.w,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: CommonText(
                              text: service,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black400,
                              textAlign: TextAlign.left,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Distance with icon
                      Row(
                        children: [
                          SvgPicture.asset(
                            "assets/icons/location_icon.svg",
                            height: 20.h,
                            width: 20.w,
                            color: AppColors.black400,
                          ),
                          SizedBox(width: 4.w),
                          CommonText(
                            text: "Distance : $distance",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black300,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Rating and Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Row(
                            children: [
                              Icon(Icons.star, size: 26.w, color: Colors.amber),
                              SizedBox(width: 2.w),
                              CommonText(
                                text: "$rating ($reviews)",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black300,
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),

                          // Price
                          CommonText(
                            text: price,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black400,
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}