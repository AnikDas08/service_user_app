import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/service_details_controller.dart';

class AvailabilityDialog extends StatelessWidget {
  const AvailabilityDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: "Available Schedule",
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
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

            SizedBox(height: 20.h),

            // Content - Schedule list
            Flexible(
              child: Obx(() {
                // Show loading indicator
                if (controller.isLoadingSchedule.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: "Loading schedule...",
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                // Show empty state if no schedule
                if (controller.providerSchedule.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 64.sp,
                          color: AppColors.black200,
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: "No schedule available",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black300,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        CommonText(
                          text: "The provider hasn't set up\ntheir schedule yet",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black200,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  );
                }

                // Show schedule list
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: controller.providerSchedule.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final schedule = controller.providerSchedule[index];
                    return _buildScheduleItem(schedule);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(schedule) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: AppColors.black50,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date icon
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CommonText(
                  text: schedule.date.day.toString(),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.center,
                ),
                CommonText(
                  text: _getMonthShort(schedule.date.month),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Schedule details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14.sp,
                      color: AppColors.black300,
                    ),
                    SizedBox(width: 4.w),
                    CommonText(
                      text: schedule.dayOfWeek,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black400,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14.sp,
                      color: AppColors.black300,
                    ),
                    SizedBox(width: 4.w),
                    CommonText(
                      text: _format24HourTime(schedule.formattedTimeRange),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black300,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      Icons.timelapse,
                      size: 14.sp,
                      color: AppColors.black300,
                    ),
                    SizedBox(width: 4.w),
                    CommonText(
                      text: "${schedule.duration} minutes",
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black300,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: schedule.count == 0
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: CommonText(
              text: schedule.count == 0 ? "Available" : "${schedule.count} booked",
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: schedule.count == 0 ? Colors.green : Colors.orange,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthShort( num month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month.toInt() - 1];
  }

  String _format24HourTime(String timeRange) {
    // Convert time range from 12-hour format (e.g., "9:00 AM - 5:00 PM")
    // to 24-hour format (e.g., "09:00 - 17:00")

    if (!timeRange.contains('AM') && !timeRange.contains('PM')) {
      // Already in 24-hour format or no AM/PM markers
      return timeRange;
    }

    try {
      final parts = timeRange.split(' - ');
      if (parts.length != 2) return timeRange;

      String startTime24 = _convertTo24Hour(parts[0].trim());
      String endTime24 = _convertTo24Hour(parts[1].trim());

      return '$startTime24 - $endTime24';
    } catch (e) {
      // If conversion fails, return original
      return timeRange;
    }
  }

  String _convertTo24Hour(String time12) {
    // Remove extra spaces and split
    time12 = time12.trim();

    bool isPM = time12.toUpperCase().contains('PM');
    bool isAM = time12.toUpperCase().contains('AM');

    // Extract time part (remove AM/PM)
    String timePart = time12.replaceAll(RegExp(r'(AM|PM|am|pm)', caseSensitive: false), '').trim();

    List<String> timeParts = timePart.split(':');
    if (timeParts.isEmpty) return time12;

     num hour = int.tryParse(timeParts[0]) ?? 0;
    String minute = timeParts.length > 1 ? timeParts[1] : '00';

    // Convert to 24-hour format
    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }
}