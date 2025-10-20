import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
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
                  CustomAppBar(title: AppString.qr_text),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // image center এ থাকবে
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
                        QrImageView(
                          data:
                              LocalStorage
                                  .userId, // এখানে আপনার ব্যবহারকারীর আইডি দিন
                          version:
                              QrVersions
                                  .auto, // QR কোডের সংস্করণ স্বয়ংক্রিয়ভাবে নির্ধারিত হবে
                          size: 235.0, // QR কোডের আকার
                          backgroundColor: Colors.white,
                          //foregroundColor: Colors.black,
                        ),
                        SizedBox(height: 20.h),
                        // 👇 Name & ID image এর width এর সাথে align হবে এবং left এ শুরু হবে
                        SizedBox(
                          width: Get.size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CommonText(
                                text:
                                    "${AppString.userName} ${LocalStorage.myName}",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                maxLines: 2,
                              ),
                              SizedBox(height: 10.h),
                              CommonText(
                                text:
                                    "${AppString.qr_id} ${LocalStorage.userId}",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                maxLines: 2,
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
