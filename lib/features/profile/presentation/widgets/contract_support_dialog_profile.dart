import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/home/widget/custom_button_home.dart';

import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/helpers/other_helper.dart';

contractSupportDialog({
  required VoidCallback onTap,
}) {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: CommonText(
          text: AppString.contact_support_text,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.black300,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: formKey,
          child: Row(
            children: [
              /// Icon container before text field
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.email_outlined,
                  color: AppColors.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 6.w),

              /// TextField
              Expanded(
                child: CommonTextField(
                  controller: emailController,
                  hintText: "sohidul@gmail.com",
                  hintTextColor: AppColors.primaryColor,
                  validator: OtherHelper.validator,
                  textColor: AppColors.primaryColor,
                  borderColor: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(text: AppString.contact_support_button, isSelected: true, onTap: (){Get.back();}),
        ],
      );
    },
  );
}
