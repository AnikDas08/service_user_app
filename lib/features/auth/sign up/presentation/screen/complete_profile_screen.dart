import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'dart:io';
import '../../../../../utils/constants/app_colors.dart';
import '../controller/complete_profile_controller.dart';

class CompleteProfileScreen extends StatelessWidget {
  const CompleteProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CompleteProfileController>(
      init: CompleteProfileController(),
      builder: (controller) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: CustomAppBar(
                    title: AppString.complete_profile_text,
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

                        // Privacy Policy Checkbox
                        _buildPrivacySection(controller),

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

  Widget _buildProfileImageSection(CompleteProfileController controller) {
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

  Widget _buildFormSection(CompleteProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // About Me
        _buildFieldWithLabel(
          label: AppString.aboutMe,
          child: CommonTextField(
            controller: controller.aboutMeController,
            hintText: AppString.hint_type_here,
            maxLines: 3,
            borderColor: AppColors.black50,
            textAlign: TextAlign.start,
          ),
        ),

        SizedBox(height: 16.h),

        // Dynamic Service Section
        Obx(() => Column(
          children: [
            // Generate service pairs dynamically
            ...controller.servicePairs.asMap().entries.map((entry) {
              int index = entry.key;
              ServicePair pair = entry.value;

              return Column(
                children: [
                  // Service dropdown
                  _buildFieldWithLabel(
                    label: index == 0 ? "Service " : "Service ${index + 1}",
                    child: _buildDropdownField(
                      controller: controller,
                      textController: pair.serviceController,
                      hintText: AppString.service_hint,
                      items: controller.serviceNames,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Service Type dropdown (depends on selected service)
                  _buildFieldWithLabel(
                    label: index == 0 ? "Service Type" : "Service Type ${index + 1}",
                    child: GetBuilder<CompleteProfileController>(
                      builder: (controller) => _buildDropdownField(
                        controller: controller,
                        textController: pair.serviceTypeController,
                        hintText: "Select Service Type",
                        items: pair.serviceController.text.isNotEmpty
                            ? controller.getServiceTypes(pair.serviceController.text)
                            : [],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Price field for each service (UPDATED)
                  _buildFieldWithLabel(
                    label: index == 0 ? AppString.price_text : "${AppString.price_text} ${index + 1}",
                    child: CommonTextField(
                      controller: pair.priceController, // Use the service pair's price controller
                      hintText: AppString.price_hints,
                      keyboardType: TextInputType.number,
                      height: 44,
                      borderColor: AppColors.black50,
                      textAlign: TextAlign.start,
                    ),
                  ),

                  if (index < controller.servicePairs.length - 1) SizedBox(height: 16.h),
                ],
              );
            }).toList(),
          ],
        )),

        SizedBox(height: 16.h),

        // Add Service Button
        Align(
          alignment: Alignment.topRight,
          child: IntrinsicWidth(
            child: CustomButton(
              text: "  Add Service  ",
              isSelected: true,
              height: 44.h,
              onTap: controller.addService,
            ),
          ),
        ),

        SizedBox(height: 16.h),
        //_buildServiceTable(controller),

        // REPLACE THIS SECTION: Add Service Language - Multiple Selection
        _buildFieldWithLabel(
          label: AppString.add_service_language,
          child: Column(
            children: [
              // Display field showing selected languages
              GestureDetector(
                onTap: () => _showLanguageSelectionBottomSheet(controller),
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
                          child: Obx(() => CommonText(
                            text: controller.selectedLanguages.isEmpty
                                ? "Select Languages"
                                : controller.selectedLanguages.join(', '),
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: controller.selectedLanguages.isEmpty
                                ? AppColors.textFiledColor
                                : AppColors.black,
                            textAlign: TextAlign.start,
                            maxLines: 2,
                          )),
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
              ),

              // Show selected languages as chips
              Obx(() => controller.selectedLanguages.isNotEmpty
                  ? Container(
                width: double.infinity,
                margin: EdgeInsets.only(top: 8.h),
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: controller.selectedLanguages.map((language) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonText(
                            text: language,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(width: 4.w),
                          GestureDetector(
                            onTap: () => controller.toggleLanguageSelection(language),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
                  : SizedBox.shrink()),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Primary Location
        _buildFieldWithLabel(
          label: AppString.primary_location_text,
          child: CommonTextField(
            height: 44,
            controller: controller.locationController,
            hintText: AppString.hint_type_here,
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

// Add this method at the end of your EditServiceScreen class
  void _showLanguageSelectionBottomSheet(CompleteProfileController controller) {
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
                text: "Select Languages",
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CommonText(
                text: "You can select multiple languages",
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: controller.languages.map((language) {
                      return Obx(() => GestureDetector(
                        onTap: () => controller.toggleLanguageSelection(language),
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
                          child: Row(
                            children: [
                              Expanded(
                                child: CommonText(
                                  text: language,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                                Icon(
                                  Icons.check_circle,
                                  color: controller.isLanguageSelected(language)?AppColors.primaryColor:AppColors.black200,
                                  size: 20.sp,
                                ),
                            ],
                          ),
                        ),
                      ));
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Done button
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10.r),
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: CommonText(
                        text: "Done",
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
    required CompleteProfileController controller,
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

  Widget _buildDistanceSlider(CompleteProfileController controller) {
    return Container(
      child: Column(
        children: [
          // Current Distance Value

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

          // Slider
        ],
      ),
    );
  }

  Widget _buildUploadSection(CompleteProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.add_new,
          fontSize: 14.sp,
          maxLines: 2,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.start,
        ),
        SizedBox(height: 12.h),

        // Upload Container with Images
        Obx(() => GestureDetector(
          onTap: controller.uploadedImages.length < 10
              ? controller.handleWorkPhotosUpload
              : null,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              minHeight: 90.h,
            ),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.black50,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: controller.uploadedImages.isEmpty
                ? // Show upload prompt when no images
            Container(
              height: 66.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 32.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 8.h),
                  CommonText(
                    text: AppString.upload_image_text,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black100,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : // Show uploaded images
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with count and upload button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: "Uploaded Images (${controller.uploadedImages.length}/10)",
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black400,
                      textAlign: TextAlign.start,
                    ),
                    if (controller.uploadedImages.length < 10)
                      GestureDetector(
                        onTap: controller.handleWorkPhotosUpload,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: "Add",
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Images Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: controller.uploadedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: AppColors.black50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8.r),
                            child: Image.file(
                              File(controller.uploadedImages[index]),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => controller.removeWorkPhoto(index),
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
                    );
                  },
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildPrivacySection(CompleteProfileController controller) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Checkbox(
          value: controller.isPrivacyAccepted.value,
          onChanged: (value) => controller.togglePrivacyAcceptance(),
          activeColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        )),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 14.h),
            child: RichText(
              textAlign: TextAlign.start,
              text: TextSpan(
                text: AppString.continue_by,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.black400,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(
                    text: AppString.privacy_policy_text,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  TextSpan(text: " ${AppString.and_text} "),
                  TextSpan(
                    text: AppString.term_condition_text,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(CompleteProfileController controller) {
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
            Get.offAllNamed(AppRoutes.homeNav);
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
      CompleteProfileController controller,
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
  /*Widget _buildServiceTable(CompleteProfileController controller) {
    return Obx(() => controller.servicePairs.isEmpty
        ? SizedBox.shrink()
        : Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),

        // Table Header
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
            border: Border.all(color: AppColors.black50),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CommonText(
                    text: "Service",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 2,
                  child: CommonText(
                    text: "Service Type",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 1,
                  child: CommonText(
                    text: "Price",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 1,
                  height: 20.h,
                  color: AppColors.black50,
                ),
                Expanded(
                  flex: 1,
                  child: CommonText(
                    text: "Action",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Table Rows
        ...controller.servicePairs.asMap().entries.map((entry) {
          int index = entry.key;
          ServicePair pair = entry.value;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                left: BorderSide(color: AppColors.black50),
                right: BorderSide(color: AppColors.black50),
                bottom: BorderSide(color: AppColors.black50),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              child: Row(
                children: [
                  // Service Name
                  Expanded(
                    flex: 2,
                    child: CommonText(
                      text: pair.serviceController.text.isEmpty
                          ? "-"
                          : pair.serviceController.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.serviceController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Service Type
                  Expanded(
                    flex: 2,
                    child: CommonText(
                      text: pair.serviceTypeController.text.isEmpty
                          ? "-"
                          : pair.serviceTypeController.text,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.serviceTypeController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Price
                  Expanded(
                    flex: 1,
                    child: CommonText(
                      text: pair.priceController.text.isEmpty
                          ? "-"
                          : "${pair.priceController.text}RSD",
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: pair.priceController.text.isEmpty
                          ? AppColors.textFiledColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 30.h,
                    color: AppColors.black50,
                  ),

                  // Action Buttons
                  Expanded(
                    flex: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Edit Button
                        GestureDetector(
                          onTap: () => controller.editService(index),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16.sp,
                              color: Colors.green,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        // Delete Button
                        GestureDetector(
                          onTap: () => _showDeleteConfirmationDialog(controller, index),
                          child: Container(
                            padding: EdgeInsets.all(6.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 16.sp,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ),
    );
  }*/

// Add this method for delete confirmation dialog
  void _showDeleteConfirmationDialog(CompleteProfileController controller, int index) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: CommonText(
          text: "Delete Service",
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
          textAlign: TextAlign.center,
        ),
        content: CommonText(
          text: "Are you sure you want to delete this service?",
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: CommonText(
              text: "Cancel",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.black400,
              textAlign: TextAlign.center,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteService(index);
            },
            child: CommonText(
              text: "Delete",
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

}