import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/pending_view_details_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../widget/home_custom_button.dart';

class ViewDetailsPending extends StatelessWidget {
  const ViewDetailsPending({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GetBuilder<PendingViewDetailsController>(
          init: PendingViewDetailsController(),
          builder: (controller) {
            return
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CustomAppBar(
                      title: AppString.view_details_text,
                      titleColor: AppColors.primaryColor,),
                  ),
                  SizedBox(height: 20.h,),
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
                      child: Row(
                        children: [
                          Container(
                            width: 137.w,
                            height: 144.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.zero, // no rounding
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.zero,
                              // ensure no clipping to circle
                              child: Image.asset(
                                "assets/images/item_image.png",
                                fit: BoxFit.cover, // fills the container
                              ),
                            ),
                          ),

                          SizedBox(width: 12.w),
                          // Booking Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  text: "Md Naimul Islam",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black400,
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/propetion_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black400,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: "Haircut",
                                      fontSize: 14.sp,
                                      color: AppColors.black400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/day_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black300,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: "09.02.2025",
                                      fontSize: 12.sp,
                                      color: AppColors.black300,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    SizedBox(width: 12.w),
                                    SvgPicture.asset(
                                      "assets/icons/time_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black300,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: "10:00",
                                      fontSize: 12.sp,
                                      color: AppColors.black300,
                                      fontWeight: FontWeight.w400
                                      ,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/location_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black300,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: "Dhaka Bangladesh",
                                      fontSize: 12.sp,
                                      color: AppColors.black300,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                CommonText(
                                  text: "RSD :2500",
                                  fontSize: 12.sp,
                                  color: AppColors.black400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                          // View Button
                          /*CustomButton(
                        text: 'View',
                        isSelected: true,
                        onTap: (){

                        },
                        isSmall: true,
                      ),*/
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: AppString.cancel_button,
                            fontSize: 14,
                            height: 48,
                            isSelected: false,
                            onTap: () => controller.changeFilter(1),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: CustomButton(
                            text: AppString.confirm_button,
                            fontSize: 14,
                            height: 48,
                            isSelected: true,
                            onTap: () => controller.changeFilter(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h,),
                ],
              );
          }
        ),
      ),
    );
  }
}
