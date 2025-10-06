import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';
import '../controller/edit_profile_controller.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});
  String? selectedLocation;

  List<String> locations = [
    'New York',
    'Los Angeles',
    'Chicago',
    'Houston',
    'Phoenix',
    'Philadelphia',
    'San Antonio',
    'San Diego',
    'Dallas',
    'San Jose',
    'Austin',
    'Jacksonville',
    'Fort Worth',
    'Columbus',
    'Charlotte',
    'San Francisco',
    'Indianapolis',
    'Seattle',
    'Denver',
    'Boston',
    // Add more locations as needed
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Scaffold(
          body:SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomAppBar(title: AppString.edit_profile_button,),
                  SizedBox(height: 20,),
                  Obx(
                        ()=> Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: controller.profileImage.value!=null?Image.file(
                                controller.profileImage.value!,
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              ):
                              Image.asset(
                                "assets/images/item_image.png",
                                width: 120.w,
                                height: 120.h,
                                fit: BoxFit.cover,
                              )
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: GestureDetector(
                              onTap: (){
                                controller.handleImageUpload();
                              },
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
                    ),
                  ),
                  SizedBox(height: 20.h,),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14),
                    constraints: BoxConstraints(),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow:[
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CommonText(
                            text: AppString.edit_now,
                            fontSize: 18.sp,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.full_name, hintText: AppString.hints_full_name,),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.contact_number_text, hintText: AppString.contact_hint,),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.multiple_location, hintText: AppString.location_hint,),
                        SizedBox(height: 12,),
                        _buildLocationDropdown(controller),
                        SizedBox(height: 20.h,),
                        CustomButton(text: AppString.confirm_button, isSelected: true, onTap: (){})
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Widget _buildLocationDropdown(EditProfileController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.add_primary_locatiopn,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black100, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
              value: controller.selectedLocation.value.isEmpty
                  ? null
                  : controller.selectedLocation.value,
              hint: CommonText(
                text: 'Select Location',
                fontSize: 12,
                color: AppColors.black200,
                textAlign: TextAlign.left,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.black300,
                size: 24.sp,
              ),
              isExpanded: true,
              items: controller.locations.map((String location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: CommonText(
                    text: location,
                    fontSize: 14,
                    color: AppColors.black400,
                    textAlign: TextAlign.left,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                controller.setSelectedLocation(newValue ?? '');
              },
            )),
          ),
        ),
      ],
    );
  }
}

class EditPersonal extends StatelessWidget {
  final String title;
  final String hintText;
  const EditPersonal({
    super.key,
    required this.title,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: title,
          fontSize: 14.sp,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6,),
        CommonTextField(
          hintText: hintText,
          hintTextColor: AppColors.black400,
          height: 44,
        )
      ],
    );
  }
}
