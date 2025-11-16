import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied!',
      'QR Code ID copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.white,
      duration: Duration(seconds: 2),
      margin: EdgeInsets.all(16),
    );
  }

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
                  CustomAppBar(
                    title: AppString.qr_text,
                    showBackButton: false,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          text: AppString.qr_details,
                          fontSize: 16,
                          maxLines: 2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 25.h),

                        // QR Code with Copy Button
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            QrImageView(
                              data: LocalStorage.userId,
                              version: QrVersions.auto,
                              size: 235.0,
                              backgroundColor: Colors.white,
                            ),
                          ],
                        ),

                        SizedBox(height: 20.h),

                        // Name & ID Section
                        SizedBox(
                          width: Get.size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CommonText(
                                text: "${AppString.userName} ${LocalStorage.myName}",
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                maxLines: 2,
                              ),
                              SizedBox(height: 10.h),

                              // ID with inline copy button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CommonText(
                                    text: "${AppString.qr_id} ${LocalStorage.userId}",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    maxLines: 2,
                                  ),
                                  SizedBox(width: 8.w),
                                  GestureDetector(
                                    onTap: () => _copyToClipboard(LocalStorage.userId),
                                    child: Icon(
                                      Icons.copy,
                                      color: AppColors.primaryColor,
                                      size: 18.sp,
                                    ),
                                  ),
                                ],
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