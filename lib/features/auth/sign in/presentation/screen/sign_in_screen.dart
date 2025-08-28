import 'package:flutter/material.dart';
import '../../../../../../config/route/app_routes.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/sign_in_controller.dart';

import '../../../../../../utils/constants/app_colors.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../../../../../../utils/helpers/other_helper.dart';
import '../widgets/do_not_account.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Sections Starts here
      appBar: AppBar(),

      /// Body Sections Starts here
      body: GetBuilder<SignInController>(
        builder: (controller) {
          return SingleChildScrollView(
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

                /// Log In Container here
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
                    key: controller.formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Log In Instruction here
                        const CommonText(
                          text: AppString.login,
                          fontSize: 24,
                          bottom: 20,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w400,
                        ).center,

                        /// Account Email Input here
                        const CommonText(text: AppString.email, bottom: 8),
                        CommonTextField(
                          controller: controller.emailController,

                          hintText: AppString.email,
                          validator: OtherHelper.emailValidator,
                        ),

                        /// Account Password Input here
                        const CommonText(
                          text: AppString.password,
                          bottom: 8,
                          top: 24,
                        ),
                        CommonTextField(
                          controller: controller.passwordController,
                          isPassword: true,
                          hintText: AppString.password,
                          validator: OtherHelper.passwordValidator,
                        ),

                        /// Forget Password Button here
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.forgotPassword),
                            child: const CommonText(
                              text: AppString.forgotThePassword,
                              top: 10,
                              bottom: 30,
                              color: AppColors.primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        /// Submit Button here
                        CommonButton(
                          titleText: AppString.login,
                          isLoading: controller.isLoading,
                          onTap: controller.signInUser,
                        ),
                        30.height,

                        /// Account Creating Instruction here
                        const DoNotHaveAccount().center,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
