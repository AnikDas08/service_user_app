import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../component/text/common_text.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../utils/constants/app_string.dart';
import '../../../../home/widget/custom_button_home.dart';

simpleDialog() async {
  // Create a new BuildContext by using Navigator.of(Get.context!).push
  // to avoid using the same context that contains the Form with GlobalKey
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) { // Use a different context parameter name
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.all(20.w),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ Image
            Image.asset(
              "assets/images/succes_image.png", // 👉 put your image in assets folder
              height: 100.h,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),

            // ✅ Title
            CommonText(
              text: AppString.password_change_now,
              textAlign: TextAlign.center,
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              maxLines: 2,
            ),
            SizedBox(height: 30.h),

            // ✅ Button
            CustomButton(
              text: AppString.back_to_login_button, 
              isSelected: true, 
              onTap: () {
                // First close the dialog to avoid context issues
                //Navigator.of(Get.context!).pop();
                // Then navigate to sign in screen with offAll to clear the navigation stack
                Get.back();
                Get.offAllNamed(AppRoutes.signIn);
              }
            )
          ],
        ),
      );
    },
  );
}