import 'package:flutter/material.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/forget_password_controller.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/helpers/other_helper.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({super.key});

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgetPasswordController>(
      builder:
          (controller) => Scaffold(
            /// App Bar Section
            appBar: AppBar(),

            /// body section
            body: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                children: [
                  /// Logo text here
                  const CommonText(
                    text: AppString.logoText,
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    bottom: 20,
                  ).center,

                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.black50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x408E8E8E),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// OTP Title here
                          CommonText(
                            text: AppString.forgotPassword,
                            fontSize: 18,
                            bottom: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ).center,

                          /// subtitle here
                          CommonText(
                            text: AppString.enterYourEmailToResetPassword,
                            fontSize: 14,
                            bottom: 20,
                            fontWeight: FontWeight.w400,
                          ).center,

                          /// forget password take email for reset Password
                          const CommonText(text: AppString.email, bottom: 8),
                          CommonTextField(
                            controller: controller.emailController,
                            hintText: AppString.email,
                            validator: OtherHelper.emailValidator,
                          ),
                          20.height,

                          /// Submit Button here
                          CommonButton(
                            titleText: AppString.verifyNow,
                            isLoading: controller.isLoadingEmail,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                controller.forgotPasswordRepo();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
