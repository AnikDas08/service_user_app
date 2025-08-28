import 'package:flutter/material.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../widget/already_accunt_rich_text.dart';
import '../widget/sign_up_all_filed.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section Starts Here
      appBar: AppBar(),

      /// Body Section Starts Here
      body: GetBuilder<SignUpController>(
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

                /// Sign Up Container here
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
                    key: controller.signUpFormKey,
                    child: Column(
                      children: [
                        /// Sign UP Instructions here
                        const CommonText(
                          text: AppString.signUp,
                          fontSize: 24,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w400,
                          bottom: 20,
                        ).center,

                        /// All Text Filed here
                        SignUpAllField(controller: controller),

                        16.height,

                        /// Submit Button Here
                        CommonButton(
                          titleText: AppString.confirm,
                          isLoading: controller.isLoading,
                          onTap: controller.signUpUser,
                        ),
                        24.height,

                        ///  Sign In Instruction here
                        const AlreadyAccountRichText(),
                        30.height,
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
