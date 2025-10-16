import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';

class ServiceCategoryItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;

  const ServiceCategoryItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Check if it's a network icon (from API) or local asset
    final bool isNetworkIcon = icon.startsWith('/') || icon.startsWith('http');

    // Build the URL - remove leading slash to avoid double slashes
    final String iconUrl = isNetworkIcon
        ? '${ApiEndPoint.imageUrl}${icon.replaceFirst('/', '')}'
        : ApiEndPoint.imageUrl+icon;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: AppColors.red50,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _buildIcon(isNetworkIcon, iconUrl),
            ),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 60.w,
            child: CommonText(
              text: label,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.black300,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(bool isNetworkIcon, String iconUrl) {
    if (isNetworkIcon) {
      // Check if it's an SVG file
      if (iconUrl.toLowerCase().endsWith('.svg')) {
        return SvgPicture.network(
          iconUrl,
          height: 28,
          width: 28,
          placeholderBuilder: (context) => SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
        );
      } else {
        // For PNG, JPG, etc. - Show original image without color filter
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            iconUrl,
            height: 32,
            width: 32,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print("Error loading image: $error");
              print("Image URL: $iconUrl");
              return Icon(
                Icons.category,
                size: 28,
                color: AppColors.primaryColor,
              );
            },
          ),
        );
      }
    } else {
      // For local SVG assets
      return SvgPicture.asset(
        iconUrl,
        height: 28,
        width: 28,
        color: AppColors.primaryColor,
      );
    }
  }
}