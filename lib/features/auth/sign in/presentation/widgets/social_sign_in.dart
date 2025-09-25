import 'package:flutter/material.dart';

import '../../../../../component/image/common_image.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/constants/app_images.dart';

Widget buildSocialIcon() {
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
      Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.black50,
          borderRadius: BorderRadius.circular(100),
        ),
        child: CommonImage(imageSrc: AppImages.apple, size: 24),
      ),
    ],
  );
}
