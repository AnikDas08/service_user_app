import 'package:flutter/material.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/helpers/other_helper.dart';
import '../../../../../utils/constants/app_string.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/sign_up_controller.dart';

class SignUpAllField extends StatelessWidget {
  const SignUpAllField({super.key, required this.controller});

  final SignUpController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// User Name here
        const CommonText(text: AppString.name_text, fontSize: 14, fontWeight: FontWeight.w400,color: AppColors.black400),
        SizedBox(height: 6,),
        CommonTextField(
          hintText: AppString.hints_name,
          hintTextColor: AppColors.black100,
          controller: controller.nameController,
          validator: OtherHelper.validator,
        ),

        /// User Email here
        const CommonText(text: AppString.email, fontSize: 14, fontWeight: FontWeight.w400,color: AppColors.black400,top: 12,bottom: 6,),
        SizedBox(height: 6,),
        CommonTextField(
          hintText: AppString.hint_email_text,
          hintTextColor: AppColors.black100,
          controller: controller.emailController,
          validator: OtherHelper.emailValidator,
        ),

        /// User phone number here
        const CommonText(text: AppString.phone_number_text, fontSize: 14,fontWeight: FontWeight.w400,top:12,bottom: 6,),
        CommonTextField(
          hintText: AppString.hint_phone_number,
          hintTextColor: AppColors.black100,
          controller: controller.phoneNumberController,
          validator: OtherHelper.validator,
        ),

        /// User Location here
        const CommonText(text: AppString.location, bottom: 6, top: 12),
        CommonTextField(
          hintText: AppString.location_hint,
          hintTextColor: AppColors.black100,
          controller: controller.locationController,
          validator: OtherHelper.validator,
        ),

        /// User Password here
        const CommonText(text: AppString.password_text, bottom: 6, top: 12),
        CommonTextField(
          hintText: AppString.password_hint,
          hintTextColor: AppColors.black100,
          controller: controller.passwordController,
          isPassword: true,
          validator: OtherHelper.passwordValidator,
        ),

        /// User Confirm Password here
        const CommonText(text: AppString.confirm_password_text, bottom: 6, top: 12),
        CommonTextField(
          hintText: AppString.hint_confirm_password,
          hintTextColor: AppColors.black100,
          controller: controller.confirmPasswordController,
          isPassword: true,
          //hintText: AppString.confirmPassword,
          validator:
              (value) => OtherHelper.confirmPasswordValidator(
                value,
                controller.passwordController,
              ),
        ),
      ],
    );
  }
}
