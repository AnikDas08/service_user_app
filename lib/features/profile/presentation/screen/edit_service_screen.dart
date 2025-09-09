import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/edit_service_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'dart:io';
import '../../../../../utils/constants/app_colors.dart';

class EditServiceScreen extends StatelessWidget {
  const EditServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditServiceController>(
      init: EditServiceController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomAppBar(
                    title: AppString.edit_service_button,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        SizedBox(height: 16.h),

                        // Profile Image Section
                        _buildProfileImageSection(controller),

                        SizedBox(height: 24.h),

                        // Form Fields
                        _buildFormSection(controller),

                        SizedBox(height: 32.h),

                        // Upload Photos Section
                        _buildUploadSection(controller),

                        SizedBox(height: 24.h),

                        // Combined Images Section (Asset + Uploaded)
                        _buildCombinedImageSection(controller),

                        SizedBox(height: 24.h),

                        SizedBox(height: 24.h),

                        // Confirm Button
                        _buildConfirmButton(controller),

                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImageSection(EditServiceController controller) {
    return Obx(() => Stack(
      children: [
        CircleAvatar(
          radius: 60.r,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60.r),
            child: controller.profileImage.value != null
                ? Image.file(
              controller.profileImage.value!,
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
            )
                : Image.asset(
              "assets/images/item_image.png",
              width: 120.w,
              height: 120.h,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: controller.handleImageUpload,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: SvgPicture.asset(
                "assets/icons/take_image.svg",
                width: 20.w,
                height: 20.h,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    ));
  }

  Widget _buildCombinedImageSection(EditServiceController controller) {
    return Obx(() {
      List<Widget> imageWidgets = [];

      // Add asset images
      for (int i = 0; i < controller.assetImages.length; i++) {
        imageWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    controller.assetImages[i],
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeAssetImage(i),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Add uploaded images
      for (int i = 0; i < controller.uploadedImages.length; i++) {
        imageWidgets.add(
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(controller.uploadedImages[i]),
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => controller.removeWorkPhoto(i),
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            text: "All Images (${controller.getTotalImageCount()})",
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          imageWidgets.isEmpty
              ? Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CommonText(
                text: "No images available",
                fontSize: 14.sp,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
            ),
          )
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: imageWidgets),
          ),
        ],
      );
    });
  }

  Widget _buildFormSection(EditServiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Me
        _buildFieldWithLabel(
          label: AppString.about_me,
          child: CommonTextField(
            controller: controller.aboutMeController,
            hintText: AppString.type_profile,
            maxLines: 3,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Service Type
        _buildFieldWithLabel(
          label: AppString.service_type,
          child: _buildDropdownField(
            controller: controller,
            textController: controller.serviceTypeController,
            hintText: AppString.service_hint,
            items: controller.serviceTypes,
          ),
        ),

        SizedBox(height: 16.h),

        // Additional Service Type
        _buildFieldWithLabel(
          label: AppString.additional_service_text,
          child: CommonTextField(
            controller: controller.additionalServiceController,
            hintText: AppString.additional_service_hints,
            height: 44,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Add Service Language
        _buildFieldWithLabel(
          label: AppString.add_service_language,
          child: _buildDropdownField(
            controller: controller,
            textController: controller.languageController,
            hintText: "English",
            items: controller.languages,
          ),
        ),

        SizedBox(height: 16.h),

        // Primary Location
        _buildFieldWithLabel(
          label: AppString.primary_location_text,
          child: CommonTextField(
            height: 44,
            controller: controller.locationController,
            hintText: AppString.primary_location_hint,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Service Distance
        _buildFieldWithLabel(
          label: AppString.service_distance,
          child: _buildDistanceSlider(controller),
        ),

        SizedBox(height: 16.h),

        // Price
        _buildFieldWithLabel(
          label: AppString.price_text,
          child: CommonTextField(
            controller: controller.priceController,
            hintText: AppString.price_hints,
            keyboardType: TextInputType.number,
            height: 44,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Price Per Hour
        _buildFieldWithLabel(
          label: AppString.price_hours,
          child: CommonTextField(
            controller: controller.pricePerHourController,
            hintText: AppString.price_hints,
            keyboardType: TextInputType.number,
            borderColor: AppColors.black50,
            height: 44,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldWithLabel({
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: label,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 6.h),
        child,
      ],
    );
  }

  Widget _buildDropdownField({
    required EditServiceController controller,
    required TextEditingController textController,
    required String hintText,
    required List<String> items,
  }) {
    return GestureDetector(
      onTap: () => _showDropdownBottomSheet(controller, textController, items),
      child: Container(
        height: 44.h,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black50),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: CommonText(
                  text: textController.text.isEmpty ? hintText : textController.text,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: textController.text.isEmpty
                      ? AppColors.textFiledColor
                      : AppColors.black,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textFiledColor,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceSlider(EditServiceController controller) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 8.h),

          Obx(() => SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.black50,
              thumbColor: AppColors.primaryColor,
              trackHeight: 4.h,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
              overlayColor: AppColors.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: controller.serviceDistance.value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: controller.updateServiceDistance,
            ),
          )),

          // Min/Max Labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                        () {
                      return CommonText(
                        text: "${controller.serviceDistance.value.round()}km",
                        fontSize: 12.sp,
                        color: AppColors.black400,
                        textAlign: TextAlign.start,
                      );
                    }
                ),
                CommonText(
                  text: "100km",
                  fontSize: 12.sp,
                  color: AppColors.black400,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(EditServiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.add_new
          ,
          fontSize: 14.sp,
          maxLines: 2,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),

        // Always show upload container
        Obx(() => GestureDetector(
          onTap: controller.getTotalImageCount() < 10
              ? controller.handleWorkPhotosUpload
              : () {
            Get.snackbar(
              "Limit Reached",
              "Maximum 10 images allowed",
              snackPosition: SnackPosition.BOTTOM,
            );
          },
          child: Container(
            width: double.infinity,
            height: 100.h,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: controller.getTotalImageCount() < 10
                    ? AppColors.black50
                    : Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10.r),
              color: controller.getTotalImageCount() < 10
                  ? Colors.transparent
                  : Colors.grey[100],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 24.sp,
                  color: controller.getTotalImageCount() < 10
                      ? AppColors.primaryColor
                      : Colors.grey[400],
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: controller.getTotalImageCount() < 10
                      ? AppString.upload_image_text
                      : "Maximum Images Reached",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: controller.getTotalImageCount() < 10
                      ? AppColors.black100
                      : Colors.grey[400]!,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildConfirmButton(EditServiceController controller) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10.r),
          onTap: (){
            controller.confirmProfile();
            //Get.toNamed(AppRoutes.verifyUser);
          },
          child: Center(
            child: CommonText(
              text: AppString.confirm_button,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _showDropdownBottomSheet(
      controller,
      TextEditingController textController,
      List<String> items,
      ) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.black50,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),
              CommonText(
                text: "Select Option",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              ...items.map(
                    (item) => GestureDetector(
                  onTap: () {
                    controller.selectFromDropdown(textController, item);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.black50,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: CommonText(
                      text: item,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}