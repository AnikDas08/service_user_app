// appointment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/appointment_controller.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(
      init: AppointmentController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Header with profile and online status
                CustomAppBar(
                  title: AppString.appointment_text,
                  showBackButton: false,
                ),

                // Calendar - Show for ALL tabs (display only, dates are gray)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TableCalendar<Event>(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: controller.focusedDay,

                    // Disable selection logic
                    selectedDayPredicate: (day) => false,

                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.sunday,

                    // Disable clicks
                    onDaySelected: (selectedDate, focusedDate) {},

                    onPageChanged: (focusedDay) {
                      controller.focusedDay = focusedDay;
                    },

                    // Only allow swiping (no tapping days)
                    availableGestures: AvailableGestures.horizontalSwipe,

                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronVisible: true,
                      rightChevronVisible: true,
                      titleTextStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),

                    calendarBuilders: CalendarBuilders(
                      // 1. Translated Months for Header
                      headerTitleBuilder: (context, day) {
                        final year = day.year.toString();
                        final List<String> monthKeys = [
                          AppString.january_text.tr, AppString.february_text.tr, AppString.march_text.tr,
                          AppString.april_text.tr, AppString.may_text.tr, AppString.june_text.tr,
                          AppString.july_text.tr, AppString.august_text.tr, AppString.september_text.tr,
                          AppString.october_text.tr, AppString.november_text.tr, AppString.december_text.tr,
                        ];
                        final String monthName = monthKeys[day.month - 1];

                        return Center(
                          child: Text(
                            "$monthName $year",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        );
                      },

                      // 2. Translated Days of Week
                      dowBuilder: (context, day) {
                        final List<String> weekdayNames = [
                          AppString.mon.tr, AppString.tue.tr, AppString.wed.tr,
                          AppString.thu.tr, AppString.fri.tr, AppString.sat.tr, AppString.sun.tr,
                        ];
                        final text = weekdayNames[day.weekday - 1];

                        return Center(
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[400], // Grayed out DOW
                            ),
                          ),
                        );
                      },
                    ),

                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,

                      // Default dates style
                      defaultTextStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                      defaultDecoration: BoxDecoration(shape: BoxShape.circle),

                      // Weekend style (also gray)
                      weekendTextStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                      weekendDecoration: BoxDecoration(shape: BoxShape.circle),

                      // Today's style (removed highlight/color)
                      todayTextStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                      todayDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent, // No highlight for "Today"
                      ),

                      // Ensure selected style doesn't pop up
                      selectedTextStyle: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[400],
                      ),
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                      ),
                    ),
                  )
                ),
                SizedBox(height: 20),

                // Filter Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppString.upcoming_button,
                          fontSize: 14,
                          height: 34,
                          isSelected: controller.selectedFilter == 0,
                          onTap: () => controller.changeFilter(0),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.pending_button,
                          fontSize: 14,
                          height: 34,
                          isSelected: controller.selectedFilter == 1,
                          onTap: () => controller.changeFilter(1),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.canceled_button,
                          fontSize: 14,
                          height: 34,
                          isSelected: controller.selectedFilter == 2,
                          onTap: () => controller.changeFilter(2),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                SizedBox(height: 8.h),

                // Booking List with Loading State and Pagination
                Expanded(
                  child: controller.isLoading
                      ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                      : controller.getFilteredBookings().isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64.sp,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: AppString.booking_here,
                          fontSize: 16.sp,
                          color: Colors.grey[600]!,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  )
                      : RefreshIndicator(
                    onRefresh: () => controller.fetchAllBookings(),
                    color: AppColors.primaryColor,
                    child: ListView.builder(
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount:
                      controller.getFilteredBookings().length +
                          (controller.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loading indicator at the end
                        if (index ==
                            controller.getFilteredBookings().length) {
                          return _buildLoadingIndicator();
                        }

                        final booking =
                        controller.getFilteredBookings()[index];
                        return _buildBookingCard(booking, controller);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Loading indicator widget for pagination
  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          CommonText(
            text: 'Loading more...',
            fontSize: 12.sp,
            color: AppColors.black300,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
      Map<String, dynamic> booking, AppointmentController controller) {
    return GestureDetector(
      onTap: () {
        if (controller.selectedFilter == 0) {
          Get.toNamed(
            AppRoutes.upcomingdetail_screen,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        } else if (controller.selectedFilter == 1) {
          Get.toNamed(
            AppRoutes.view_detail_pending,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        } else {
          Get.toNamed(
            AppRoutes.canceldetails_screen,
            arguments: {'bookingId': controller.getFullBookingId(booking)},
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 76.w,
              height: 87.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.zero,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.zero,
                child: controller.getProviderImage(booking).startsWith('http') ||
                    controller.getProviderImage(booking).startsWith('/')
                    ? Image.network(
                  ApiEndPoint.imageUrl +
                      controller.getProviderImage(booking),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/noImage.png",
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/noImage.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 12.w),
            // Booking Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: controller.getProviderName(booking),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/propetion_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black400,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getServiceNames(booking),
                        fontSize: 14.sp,
                        color: AppColors.black400,
                        fontWeight: FontWeight.w400,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/day_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedDate(booking),
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: 12.w),
                      SvgPicture.asset(
                        "assets/icons/time_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black200,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: controller.getFormattedTime(booking),
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            CommonText(
                              text:
                              '${AppString.booking_id_here}: ${controller.getBookingId(booking)}',
                              fontSize: 12.sp,
                              color: AppColors.black300,
                              fontWeight: FontWeight.w400,
                            ),
                            SizedBox(width: 12.w),
                          ],
                        ),
                      ),
                      if (controller.selectedFilter != 2)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: CustomButton(
                            text: AppString.view_button,
                            isSelected: true,
                            onTap: () =>
                                controller.viewBookingDetails(booking),
                            isSmall: true,
                            height: 24,
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Event class for table_calendar
class Event {
  final String title;
  Event(this.title);

  @override
  String toString() => title;
}