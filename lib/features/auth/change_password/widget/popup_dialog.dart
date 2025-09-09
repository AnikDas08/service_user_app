import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../config/route/app_routes.dart';
import '../../../home/widget/home_custom_button.dart';

simpleDialog() async {
  showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (context) {
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
            Text(
              "Your Password Has Been Changed",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30.h),

            // ✅ Button
            CustomButton(text: "Back to Login", isSelected: true, onTap: (){Get.offAllNamed(AppRoutes.signIn);})
          ],
        ),
      );
    },
  );
}