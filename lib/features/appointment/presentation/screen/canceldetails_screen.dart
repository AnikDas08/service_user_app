import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';

class CancelDetailsScreen extends StatelessWidget {
  const CancelDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomAppBar(
                title: "View Details",
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
                        borderRadius: BorderRadius.zero, // ensure no clipping to circle
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
                                text: "10:00 AM",
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
                                "assets/icons/booking_id_icon.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.black300,
                              ),
                              CommonText(
                                text: 'Booking ID: 1256',
                                fontSize: 12.sp,
                                color: AppColors.black300,
                                fontWeight: FontWeight.w400,
                              ),
                              SizedBox(width: 12.w),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                  child:Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: "Contact Details",
                            fontSize: 12.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(height: 4.h,),
                          Row(
                            children: [
                              CommonText(
                                text: "Contact Number    : ",
                                fontSize: 12.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w400,
                              ),
                              CommonText(
                                text: "01293923e44",
                                fontSize: 12.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(

                            children: [
                              CommonText(
                                text: "Email Address        : ",
                                fontSize: 12.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w400,
                              ),
                              CommonText(
                                text: "mehedi@gmail.com",
                                fontSize: 12.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w400,
                              ),
                            ],
                          ),
                        ],
                      )
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }
}
