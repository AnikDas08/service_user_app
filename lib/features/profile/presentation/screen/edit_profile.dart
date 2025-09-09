import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/features/home/widget/home_custom_button.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/edit_profile_controller.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class EditProfile extends StatelessWidget {
  const EditProfile({super.key});

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
                        EditPersonal(title: AppString.full_name, hintText: "Sohidul Islam",),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.email, hintText: "sohidul@gmail.com",),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.phone, hintText: "+880123456789",),
                        SizedBox(height: 12,),
                        EditPersonal(title: AppString.location, hintText: "Dhaka Bangladesh",),
                        SizedBox(height: 20.h,),
                        CustomButton(text: AppString.edit_profile_button, isSelected: true, onTap: (){})
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
