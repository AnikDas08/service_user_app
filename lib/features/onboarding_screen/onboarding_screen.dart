import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../config/route/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/extensions/extension.dart';
import '../../component/button/common_button.dart';
import '../../component/text/common_text.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              // Top spacing
              60.height,

              // Title Section
              _buildTitleSection(),

              // Spacer to push content to center
              const Spacer(flex: 2),

              // Illustration Section
              _buildIllustrationSection(),

              // Spacer
              const Spacer(flex: 3),

              // Buttons Section
              _buildButtonsSection(),

              // Bottom spacing
              40.height,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        CommonText(
          text: "HaircutMen",
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          textAlign: TextAlign.center,
        ),
        8.height,
        CommonText(
          text: "Partner",
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildIllustrationSection() {
    return Container(
      width: 320.w,
      height: 320.h,
      decoration: BoxDecoration(
        color: AppColors.red50.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 280.w,
            height: 280.h,
            decoration: BoxDecoration(
              color: AppColors.red100.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          // Placeholder for illustration - you can replace this with actual illustration
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.people_outline,
                size: 80.sp,
                color: AppColors.primaryColor,
              ),
              12.height,
              CommonText(
                text: "Welcome to",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black600,
              ),
              CommonText(
                text: "HaircutMen",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      children: [
        // Log In Button (Outlined)
        CommonButton(
          titleText: "Log In",
          titleColor: AppColors.primaryColor,
          buttonColor: AppColors.transparent,
          borderColor: AppColors.primaryColor,
          borderWidth: 2,
          buttonRadius: 4.r,
          buttonHeight: 56.h,
          titleSize: 16,
          titleWeight: FontWeight.w600,
          onTap: () => Get.toNamed(AppRoutes.signIn),
        ),

        20.height,

        // Sign Up Button (Filled)
        CommonButton(
          titleText: "Sign Up",
          titleColor: AppColors.white,
          buttonColor: AppColors.primaryColor,
          borderColor: AppColors.primaryColor,
          buttonRadius: 4.r,
          buttonHeight: 56.h,
          titleSize: 16,
          titleWeight: FontWeight.w600,
          onTap: () => Get.toNamed(AppRoutes.signUp),
        ),
      ],
    );
  }
}
