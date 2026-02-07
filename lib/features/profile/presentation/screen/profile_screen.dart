import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/profile/presentation/widgets/contract_support_dialog_profile.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../component/image_view/imageview_class.dart';
import '../../../../component/other_widgets/item.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../controller/profile_controller.dart';
import '../../../../../utils/constants/app_string.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// Body Section Starts here
      body: GetBuilder<ProfileController>(
        init: ProfileController(),
        builder: (controller) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  children: [
                    CustomAppBar(title: AppString.profile_text,showBackButton: false,),
                    /// User Profile Image here
                    Center(
                          child:Obx(
                            ()=> GestureDetector(
                              onTap: (){
                                if (controller.imageUser.value != "") {
                                  ImageViewerScreen.openSingle(
                                    Get.context!,
                                    ApiEndPoint.socketUrl + controller.imageUser.value,
                                  );
                                }
                                else{
                                  ImageViewerScreen.openSingle(
                                    Get.context!,
                                    "assets/images/profile_image.jpg",
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 60.sp,
                                backgroundColor: Colors.transparent,
                                child: ClipOval(
                                  child: Image.network(
                                    ApiEndPoint.socketUrl + controller.imageUser.value,
                                    width: 120.sp,
                                    height: 120.sp,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Image.asset(
                                        "assets/images/profile_image.jpg",
                                        width: 120.sp,
                                        height: 120.sp,
                                        fit: BoxFit.cover,
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 30,
                                        height: 30,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      );
                                    },
                                  ),
                                ),
                              ),

                            ),
                          ),
                          ),

                    SizedBox(height: 12,),
                    SizedBox(height: 9,),
                    /// User Name here
                    Obx(
                      ()=> CommonText(
                        text: controller.name.value,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 20,),
                    /// Edit Profile item here
                    Item(
                      image: "assets/icons/profile.svg",
                      title: AppString.personal_information,
                      onTap: () => Get.toNamed(AppRoutes.personal_information_screen),
                    ),

                    /// Language item here
                    Item(
                      image: "assets/icons/language_icon.svg",
                      title: AppString.language_text.tr,
                      onTap: () => Get.toNamed(AppRoutes.language_screen),
                    ),

                    /// Setting item here
                    Item(
                      image: "assets/icons/setting_icon.svg",
                      title: AppString.setting.tr,
                      onTap: ()=>Get.toNamed(AppRoutes.setting),
                    ),

                    /// Completed Booking item here
                    Item(
                      image: "assets/icons/term_icon.svg",
                      title: AppString.complete_service.tr,
                      onTap: () => Get.toNamed(AppRoutes.complete_screen_appointment),
                    ),

                    Item(
                      image: "assets/icons/contract_icon.svg",
                      title: AppString.contact_support.tr,
                      onTap: () => contractSupportDialog(onTap: (){}),
                    ),
                    Item(
                      icon: Icons.favorite_outline,
                      disableIcon: false,
                      title: AppString.favourite_list.tr,
                      onTap: () => Get.toNamed(AppRoutes.favourite_screen),
                    ),
                   SizedBox(height: 10.h,),
                   Container(
                     padding: EdgeInsets.all(14),
                     width: double.infinity,
                     decoration: BoxDecoration(
                       color: AppColors.red100,
                       borderRadius: BorderRadius.circular(10),
                     ),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         CommonText(
                             text: "${AppString.present_credit.tr}: ${controller.credit.value.toStringAsFixed(2)}",
                           fontSize: 16,
                           fontWeight: FontWeight.w500,
                           overflow: TextOverflow.ellipsis,
                           color: AppColors.black400
                         ),
                         SizedBox(height: 18,),
                         CommonText(
                             text: "${AppString.one_credit} ${controller.creditShow} RSD",
                           fontSize: 16,
                           maxLines: 2,
                           overflow: TextOverflow.ellipsis,
                           fontWeight: FontWeight.w500,
                           color: AppColors.black100,
                         ),
                       ],
                     ),
                   )
                  ],
                ),
              ),
          );
        },
      ),
    );
  }
}
