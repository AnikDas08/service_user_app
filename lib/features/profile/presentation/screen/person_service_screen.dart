import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/service_profile_controller.dart';

class ServiceProfileScreen extends StatelessWidget {
  ServiceProfileScreen({super.key});

  final ServiceProfileController controller = Get.put(ServiceProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomAppBar(title: AppString.service_information,),
                SizedBox(height: 18.h),

                // About Me Section
                CommonText(
                  text: AppString.about_me,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 12.h),
                Obx(() => CommonText(
                  text: controller.aboutMe.value,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black300,
                  textAlign: TextAlign.left,
                  maxLines: 10,
                )),

                SizedBox(height: 14.h),

                // Languages
                Row(
                  children: [
                    CommonText(
                      text: "Spoken : ",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                    CommonText(
                      text: "English, Russian",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/location_icon.svg",
                      width: 24.w,
                      height: 24.h,
                      color: AppColors.black400,
                    ),
                    SizedBox(width: 4.w),
                    CommonText(
                      text: "Dhaka Bangladesh",
                      fontSize: 16.sp,
                      color: AppColors.black300,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    CommonText(
                      text: "Service Distance : ",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                    CommonText(
                      text: "10 KM",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  children: [
                    CommonText(
                      text: "Price Per Hour : ",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                    CommonText(
                      text: "RSD 2500",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),

                SizedBox(height: 20.h),

                // Services Table
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.black300.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Table(
                    border: TableBorder(
                      verticalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
                      horizontalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
                    ),
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1),
                    },
                    children: [
                      // Header Row
                      TableRow(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.r),
                            topRight: Radius.circular(8.r),
                          ),
                        ),
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Service",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Service Type",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Price",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Data Row 1
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Hair Cut",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black300,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Zero Cut",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black300,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "200RSD",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      // Data Row 2
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Hair Cut",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black300,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "Color with cut",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black300,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: CommonText(
                              text: "200RSD",
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),

                // My Work Photos Section
                const CommonText(
                  text: AppString.work_details,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 6.h),

                // Photo Grid
                Obx(() => GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: controller.workPhotos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          controller.workPhotos[index],
                          fit: BoxFit.cover,)
                    );
                  },
                )),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),

      // Edit Service Details Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20,bottom: 20,top: 10),
        child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: CustomButton(text: AppString.edit_service_button, isSelected: true, onTap: (){
              Get.toNamed(AppRoutes.edit_service_screen);
            })
        ),
      ),
    );
  }
}