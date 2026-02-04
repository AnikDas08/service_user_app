import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
// Make sure this path is correct for your project structure
import 'package:haircutmen_user_app/features/profile/presentation/controller/complete_bookingcontroller.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';

import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart'; // Import AppRoutes
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../home/widget/custom_button_home.dart';

class CompleteBooking extends StatelessWidget {
  const CompleteBooking({super.key});

  // Helper widget for loading indicator at the bottom of the list
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildBookingCard(
      Map<String, dynamic> booking, CompletedBookingController controller) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.complete_details_screen,
          arguments: {'bookingId': booking['_id']},
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 76.w,
              height: 87.h,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.zero,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: (controller.getUserImage(booking).startsWith('http') ||
                    controller.getUserImage(booking).startsWith('/'))
                    ? Image.network(
                  ApiEndPoint.imageUrl +
                      controller.getUserImage(booking),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/noImage.png",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/noImage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: controller.getUserName(booking),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/propetion_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black400,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getServiceNames(booking),
                        fontSize: 14.sp,
                        color: AppColors.black400,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/day_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedDate(booking),
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(
                        "assets/icons/time_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedTimeRange(booking), // Use TimeRange
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CommonText(
                              text:
                              '${AppString.booking_id_here}: ${controller.getBookingId(booking)}',
                              fontSize: 12.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w400,
                            ),
                            SizedBox(width: 12.w),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: CustomButton(
                          text: AppString.view_button,
                          isSelected: true,
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.complete_details_screen,
                              arguments: {'bookingId': booking['_id']},
                            );
                          },
                          isSmall: true,
                          height: 24,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<CompletedBookingController>(
          builder: (controller) => Column(
            children: [
              const CustomAppBar(
                title: AppString.complete_booking,
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: controller.isLoading
                    ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
                    : controller.getFilteredBookings().isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64.sp,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16.h),
                      CommonText(
                        text: AppString.complete_booking_photo,
                        fontSize: 16.sp,
                        color: Colors.grey[600]!,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: () => controller.fetchCompletedBookings(), // Use fetchCompletedBookings
                  color: AppColors.primaryColor,
                  child: ListView.builder(
                    controller: controller.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount:
                    controller.getFilteredBookings().length +
                        (controller.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show loading indicator at the end
                      if (index ==
                          controller.getFilteredBookings().length) {
                        return _buildLoadingIndicator();
                      }

                      final booking =
                      controller.getFilteredBookings()[index];
                      return _buildBookingCard(booking, controller);
                    },
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