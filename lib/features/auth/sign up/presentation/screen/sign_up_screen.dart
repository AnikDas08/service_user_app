import 'package:flutter/material.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';
import '../../../../../../utils/extensions/extension.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../config/route/app_routes.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../utils/constants/app_string.dart';
import '../widget/already_accunt_rich_text.dart';
import '../widget/sign_up_all_filed.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return Scaffold(
      /// App Bar Section Starts Here


      /// Body Section Starts Here
      resizeToAvoidBottomInset: true,
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              children: [
                /// Logo text here
                CustomAppBar(title: "",onBackTap: (){
                  Get.offAllNamed(AppRoutes.onboarding);
                },),
                const CommonText(
                  text: AppString.onboarding_text,
                  fontSize: 24,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                  maxLines: 2,
                ).center,
                SizedBox(height: 12,),
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
                    key: formKey,
                    child: Column(
                      children: [
                        /// Sign UP Instructions here
                        const CommonText(
                          text: AppString.signup_text,
                          fontSize: 18,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w500,
                        ).center,

                        SizedBox(height: 20,),

                        /// All Text Filed here
                        SignUpAllField(controller: controller),

                        16.height,

                        /// Submit Button Here
                        CommonButton(
                          titleText: AppString.continue_button,
                          isLoading: controller.isLoading,
                          onTap: (){
                            if(formKey.currentState!.validate()){
                              controller.signUpUser();
                            }
                          },
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
