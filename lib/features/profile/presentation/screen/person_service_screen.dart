import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

                // Service Type Section
                const CommonText(
                  text: AppString.service_type,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 6.h),
                Obx(() => CommonText(
                  text: controller.serviceType.value,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.left,
                )),

                SizedBox(height: 14.h),

                // Price Section
                const CommonText(
                  text: AppString.price_hour,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 6.h),
                Obx(() => CommonText(
                  text: controller.price.value,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.left,
                )),

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

// Alternative implementation using GetView if you prefer
/*
class ServiceProfileScreenGetView extends GetView<ServiceProfileController> {
  const ServiceProfileScreenGetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Obx(() => CommonText(
          text: controller.serviceName.value,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFE91E63),
        )),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // About Me Section
              const CommonText(
                text: 'About Me',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 12.h),
              Obx(() => CommonText(
                text: controller.aboutMe.value,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                textAlign: TextAlign.left,
                maxLines: 10,
              )),

              SizedBox(height: 30.h),

              // Service Type Section
              const CommonText(
                text: 'Service Type',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 12.h),
              Obx(() => CommonText(
                text: controller.serviceType.value,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                textAlign: TextAlign.left,
              )),

              SizedBox(height: 30.h),

              // Price Section
              const CommonText(
                text: 'Price (Per Hour)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 12.h),
              Obx(() => CommonText(
                text: controller.price.value,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                textAlign: TextAlign.left,
              )),

              SizedBox(height: 30.h),

              // My Work Photos Section
              const CommonText(
                text: 'My Work (Photos)',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 16.h),

              // Photo Grid
              Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.workPhotos.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Handle photo tap - could open full screen view
                      Get.snackbar(
                        'Photo',
                        'Photo ${index + 1} tapped',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        color: Colors.grey[200],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.image,
                            size: 40.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        // Replace with actual images:
                        // child: Image.asset(
                        //   controller.workPhotos[index],
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                    ),
                  );
                },
              )),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),

      // Edit Service Details Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50.h,
          child: ElevatedButton(
            onPressed: controller.editServiceDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
            child: const CommonText(
              text: 'Edit Service Details',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// You can also create a binding class for better organization
class ServiceProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceProfileController>(() => ServiceProfileController());
  }
}*/
