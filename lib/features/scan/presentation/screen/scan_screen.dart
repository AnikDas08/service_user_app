import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/image/common_image.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../controller/scan_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanController>(
      init: ScanController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomAppBar(title: AppString.qr_text,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // image center এ থাকবে
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          text: AppString.qr_details,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 25.h),
                        // 👇 Image Center এ থাকবে
                        Image.asset(
                          "assets/images/scan_image.png",
                          height: 235.h,
                          width: 235.w,
                          fit: BoxFit.fill,
                        ),
                        SizedBox(height: 20.h),
                        // 👇 Name & ID image এর width এর সাথে align হবে এবং left এ শুরু হবে
                        SizedBox(
                          width: 235.w, // image এর width এর সমান
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CommonText(
                                text: AppString.qr_name,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              SizedBox(height: 10.h),
                              CommonText(
                                text: "${AppString.qr_id} 485945",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}