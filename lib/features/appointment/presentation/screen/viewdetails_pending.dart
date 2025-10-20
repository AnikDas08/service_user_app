import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/appointment_controller.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/pending_view_details_controller.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';

class ViewDetailsPending extends StatelessWidget {
  const ViewDetailsPending({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PendingViewDetailsController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppBar(
                  title: "View Status",
                  titleColor: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CircleAvatar(
                              backgroundImage: controller.providerImage.value.isNotEmpty
                                  ? NetworkImage(ApiEndPoint.socketUrl+controller.providerImage.value)
                                  : AssetImage("assets/images/item_image.png") as ImageProvider,
                              radius: 45,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // Booking Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  text: controller.providerName.value,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black400,
                                ),
                                SizedBox(height: 6.h),
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
                                      text: controller.serviceName.value,
                                      fontSize: 14.sp,
                                      color: AppColors.black400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: controller.rating.value.toString(),
                                      fontSize: 12.sp,
                                      color: AppColors.black300,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(width: 12.w),
                                    CommonText(
                                      text: "(${controller.reviewCount.value})",
                                      fontSize: 12.sp,
                                      color: AppColors.black200,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/location_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black300,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: controller.providerLocation.value,
                                      fontSize: 12.sp,
                                      color: AppColors.black300,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/day_icon.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.black400,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: controller.date.value,
                                fontSize: 14.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CommonText(
                                text: "Booking ID : ${controller.bookingId.value}",
                                fontSize: 14.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/time_icon.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: controller.time.value,
                                fontSize: 14.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          CommonText(
                            text: controller.duration.value,
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          CommonText(
                            text: controller.serviceName.value,
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(width: 10),
                          CommonText(
                            text: ":RSD ${controller.amount.value}",
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomButton(
                  text: AppString.cancel_button,
                  fontSize: 18,
                  isSelected: true,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          content: CommonText(
                            maxLines: 4,
                            text: AppString.cancel_booking_detail,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          actions: [
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    text: AppString.no_button,
                                    isSelected: false,
                                    onTap: () {
                                      Get.back();
                                    },
                                  ),
                                ),
                                SizedBox(width: 25),
                                Expanded(
                                  child: CustomButton(
                                    text: AppString.yes_button,
                                    isSelected: true,
                                    onTap: () async {
                                      // Cancel the booking first
                                      await controller.cancelBooking();

                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}