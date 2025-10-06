import 'package:flutter/material.dart';
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
        const CommonText(text: AppString.full_name, bottom: 8, top: 12),
        CommonTextField(
          hintText: AppString.hints_full_name,
          controller: controller.nameController,
          validator: OtherHelper.validator,
        ),

        /// User Email here
        const CommonText(text: AppString.email_text, bottom: 8, top: 12),
        CommonTextField(
          controller: controller.emailController,
          hintText: AppString.hint_email_text,
          validator: OtherHelper.emailValidator,
        ),

        /// User phone number here
        const CommonText(text: AppString.phone_number_text, bottom: 8, top: 12),
        CommonTextField(
          controller: controller.phoneNumberController,
          hintText: AppString.hint_phone_number,
          validator: OtherHelper.validator,
        ),

        /// User Location here
        const CommonText(text: AppString.location_text, bottom: 8, top: 12),
        CommonTextField(
          controller: controller.locationController,
          hintText: AppString.location_hint,
          validator: OtherHelper.validator,
        ),

        /// User Password here
        const CommonText(text: AppString.password_text, bottom: 8, top: 12),
        CommonTextField(
          controller: controller.passwordController,
          isPassword: true,
          hintText: AppString.hint_password_text,
          validator: OtherHelper.passwordValidator,
        ),

        /// User Confirm Password here
        const CommonText(text: AppString.confirm_password_text, bottom: 8, top: 12),
        CommonTextField(
          controller: controller.confirmPasswordController,
          isPassword: true,
          hintText: AppString.hint_confirm_password,
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
