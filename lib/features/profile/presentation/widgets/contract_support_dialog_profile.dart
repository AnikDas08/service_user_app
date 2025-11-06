import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/home/widget/custom_button_home.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/helpers/other_helper.dart';

contractSupportDialog({
  required VoidCallback onTap,
}) {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: CommonText(
          text: AppString.contact_support_text,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.black300,
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Row(
              children: [
                /// Icon container before text field
                Container(
                  padding: EdgeInsets.all(5.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.email_outlined,
                    color: AppColors.primaryColor,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 6.w),
          
                /// TextField
                Expanded(
                  child: CommonTextField(
                    controller: emailController,
                    hintText: "resoyi2307@wivstore.com",
                    readOnly: true,
                    hintTextColor: AppColors.primaryColor,
                    validator: OtherHelper.validator,
                    textColor: AppColors.primaryColor,
                    borderColor: Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          CustomButton(text: AppString.contact_support_button, isSelected: true, onTap: ()async{
            final String email = emailController.text.trim().isEmpty
                ? 'resoyi2307@wivstore.com'
                : emailController.text.trim();

            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: email,
              query: 'subject=${Uri.encodeComponent("Support Request")}&body=${Uri.encodeComponent("Hi, I need help with...")}',
            );

            try {
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(
                  emailUri,
                  mode: LaunchMode.externalApplication, // 👈 important
                );
              } else {
                Get.snackbar('Error', 'Could not launch email app');
              }
            } catch (e) {
              debugPrint('Email launch error: $e');
              Get.snackbar('Error', 'Something went wrong launching email');
            }
          }),
        ],
      );
    },
  );
}
Future<void> _sendEmail(String toEmail) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: toEmail,
    query: 'subject=${Uri.encodeComponent("Customer Support")}&body=${Uri.encodeComponent("Hi, I need help with...")}',
  );

  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  } else {
    Get.snackbar(
      'Error',
      'Could not open email app.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
