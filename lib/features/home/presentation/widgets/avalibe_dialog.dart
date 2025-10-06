import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';


class AvailabilityDialog extends StatelessWidget {
  const AvailabilityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 24.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Days list
            _buildDayItem("Monday", "9:00-12:00"),
            _buildDayItem("Tuesday", "9:00-12:00"),
            _buildDayItem("Wednesday", "2:00-12:00 PM"),
            _buildDayItem("Thursday", "9:00-12:00"),
            _buildDayItem("Friday", "9:00-12:00"),
            _buildDayItem("Saturday", "9:00-12:00"),
          ],
        ),
      ),
    );
  }

  Widget _buildDayItem(String day, String time) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20,vertical:8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              CommonText(
                text: day,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 4.h,),
              CommonText(
                text: time,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.black300,
                textAlign: TextAlign.right,
              ),
            ],
      ),
    );
  }
}