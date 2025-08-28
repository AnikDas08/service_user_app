import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/services/storage/storage_keys.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/other_widgets/item.dart';
import '../../../../component/text/common_text.dart';
import '../controller/profile_controller.dart';
import '../../../../../utils/constants/app_images.dart';
import '../../../../../utils/constants/app_string.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section Starts here
      appBar: AppBar(
        centerTitle: true,
        title: const CommonText(
          text: AppString.profile,
          fontWeight: FontWeight.w600,
          fontSize: 24,
        ),
      ),

      /// Body Section Starts here
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              children: [
                /// User Profile Image here
                Center(
                  child: CircleAvatar(
                    radius: 85.sp,
                    backgroundColor: Colors.transparent,
                    child: const ClipOval(
                      child: CommonImage(
                        imageSrc: AppImages.profile,
                        size: 170,
                        defaultImage: AppImages.profile,
                      ),
                    ),
                  ),
                ),

                /// User Name here
                const CommonText(
                  text: LocalStorageKeys.myName,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  top: 20,
                  bottom: 24,
                ),

                /// Edit Profile item here
                Item(
                  icon: Icons.person,
                  title: AppString.personalInformation,
                  onTap: () => Get.toNamed(AppRoutes.editProfile),
                ),

                /// Setting item here
                Item(
                  icon: Icons.wallet,
                  title: AppString.myBalance,
                  onTap: () => Get.toNamed(AppRoutes.setting),
                ),

                /// Language item here
                Item(
                  icon: Icons.language,
                  title: AppString.language,
                  onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                ),

                /// Privacy Policy item here
                Item(
                  icon: Icons.settings,
                  title: AppString.settings,
                  onTap: () => Get.toNamed(AppRoutes.setting),
                ),

                /// Terms of Service item here
                Item(
                  icon: Icons.headset,
                  title: AppString.contactSupport,
                  onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
