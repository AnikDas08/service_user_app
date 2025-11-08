import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../config/route/app_routes.dart';
import '../../../utils/constants/app_colors.dart';
import '../../../utils/extensions/extension.dart';
import '../../component/button/common_button.dart';
import '../../component/image/common_image.dart';
import '../../component/text/common_text.dart';
import '../../utils/constants/app_images.dart';

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
              SizedBox(height: 30.h),

              // Illustration Sectio_buildIllustrationSection(),
              Image.asset(
                "assets/images/flash_image_service.png",
                width: 260,
                height: 190,
              ),

              SizedBox(height: 50.h),

              // Buttons Section
              _buildButtonsSection(),

              40.height,

              _buildSocialIcon(),

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
          text: AppString.onboarding_text,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
          maxLines: 2,
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
          titleText: AppString.login_text,
          titleColor: AppColors.primaryColor,
          buttonColor: AppColors.transparent,
          borderColor: AppColors.primaryColor,
          borderWidth: 2,
          buttonRadius: 4.r,
          titleSize: 18,
          titleWeight: FontWeight.w600,
          onTap: () => Get.toNamed(AppRoutes.signIn),
        ),

        SizedBox(height: 26.h),

        // Sign Up Button (Filled)
        CommonButton(
          titleText: AppString.signup_text,
          titleColor: AppColors.white,
          buttonColor: AppColors.primaryColor,
          borderColor: AppColors.primaryColor,
          buttonRadius: 4.r,
          titleSize: 18,
          titleWeight: FontWeight.w600,
          onTap: () => Get.toNamed(AppRoutes.signUp),
        ),
      ],
    );
  }

  Widget _buildSocialIcon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 24,
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.black50,
            borderRadius: BorderRadius.circular(100),
          ),
          child: CommonImage(imageSrc: AppImages.google, size: 24),
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.black50,
            borderRadius: BorderRadius.circular(100),
          ),
          child: CommonImage(imageSrc: AppImages.facebook, size: 24),
        ),
       /* Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.black50,
            borderRadius: BorderRadius.circular(100),
          ),
          child: CommonImage(imageSrc: AppImages.apple, size: 24),
        ),*/
      ],
    );
  }
}
