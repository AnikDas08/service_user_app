import 'package:flutter/material.dart';
import '../../../../../config/route/app_routes.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/pop_up/common_pop_menu.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../controller/setting_controller.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_string.dart';
import '../widgets/logout_dialog.dart';
import '../widgets/setting_item.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<SettingController>(
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SafeArea(
              child: Column(
                children: [

                  CustomAppBar(title: "Settings",),

                  SizedBox(height: 30.h,),

                  /// Change password Item here
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.changePassword),
                    child: const SettingItem(
                      title: AppString.changePassword,
                      image: "assets/icons/password_icon.svg",
                    ),
                  ),

                  /// Terms of Service Item here
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                    child: const SettingItem(
                      title: "Privacy Policy",
                      image: "assets/icons/privacy_icon.svg",
                    ),
                  ),

                  /// Privacy Policy Item here
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.termsOfServices),
                    child: const SettingItem(
                      title: "Terms & Conditions",
                      image: "assets/icons/term_icon.svg",
                    ),
                  ),


                  InkWell(
                    onTap: () => logoutDialog(onConfirm: (){}),
                    child: const SettingItem(
                      title: AppString.logOut,
                      iconDate: Icons.logout,
                      iconColor: AppColors.primaryColor,
                      titleColor: AppColors.primaryColor,
                      image: "assets/icons/logout_icon.svg",
                    ),
                  ),


                  InkWell(
                    onTap:
                        () => deletePopUp(
                      controller: controller.passwordController,
                      onTap: controller.deleteAccountRepo,
                      isLoading: controller.isLoading,
                    ),
                    child: const SettingItem(
                      title: AppString.deleteAccount,
                      image:"assets/icons/delete_icon.svg",
                      iconColor: AppColors.primaryColor,
                      titleColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
