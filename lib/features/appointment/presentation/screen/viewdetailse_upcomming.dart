import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';

class ViewDetailsUpcoming extends StatelessWidget {
  const ViewDetailsUpcoming({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomAppBar(
                title: AppString.view_status,
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            backgroundImage: AssetImage("assets/images/item_image.png"),
                            radius: 45,
                          )
                        ),

                        SizedBox(width: 12.w),
                        // Booking Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: "Angel Maria",
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
                                  Icon(
                                      Icons.star,
                                    size: 18,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4.w),
                                  CommonText(
                                    text: "4.5",
                                    fontSize: 12.sp,
                                    color: AppColors.black300,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  SizedBox(width: 12.w),
                                  CommonText(
                                    text: "(200)",
                                    fontSize: 12.sp,
                                    color: AppColors.black200,
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
                                    text: "Dhaka Bangladesh House 30",
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
                              text: "09.12.2025",
                              fontSize: 14.sp,
                              color: AppColors.black400,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            CommonText(
                              text: "Booking ID : 234545",
                              fontSize: 14.sp,
                              color: AppColors.black400,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h,),
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
                              text: "10:34 pm",
                              fontSize: 14.sp,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                        CommonText(
                          text: "45 Minutes Duration",
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          text: "Hair Cut",
                          fontSize: 14.sp,
                          color: AppColors.black400,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(width: 10,),
                        CommonText(
                          text: ": RSD 200",
                          fontSize: 14.sp,
                          color: AppColors.black400,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    /*Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 100.h,
                          child: CommonText(
                            text: "Phone Number",
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(width: 10,),
                        CommonText(
                          text: ": 2345656767",
                          fontSize: 14.sp,
                          color: AppColors.black400,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    SizedBox(height: 12,),
                    Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 100.h,
                          child: CommonText(
                            text: "Email",
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        SizedBox(width: 10,),
                        CommonText(
                          text: ": anik@gmail.com",
                          fontSize: 14.sp,
                          color: AppColors.black400,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    )*/
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /*Expanded(
                    child: CustomButton(text: AppString.cancel_button,
                        fontSize: 18,
                        isSmall: false,
                        isSelected: false,
                        onTap: (){

                        }),
                  ),
                  SizedBox(width: 20.h,),*/
                  Expanded(
                    child: CustomButton(
                        text: "Message",
                        fontSize: 18,
                        isSmall: false,
                        isSelected: true,
                        onTap: (){

                        }),
                  ),
                ],
              )
            )
          ],
        ),
      ),
    );
  }
}
