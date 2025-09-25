// home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/data/model/booking_model.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../widget/home_custom_button.dart';
import '../controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                // Header with profile and online status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  color: Colors.white,
                  child: Row(
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 24.r,
                        child: Image.asset("assets/images/profile_image.png"),
                      ),
                      SizedBox(width: 12.w),
                      // Profile Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: 'Social Jasim',
                              fontSize: 12.sp,
                              color: Colors.grey[600]!,
                            ),
                            CommonText(
                              text: AppString.welcome_text,
                              fontSize: 16.sp,
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      // Online Status Toggle
                      Row(
                        children: [
                          CommonText(
                            text: AppString.online_voew,
                            fontSize: 14.sp,
                            color: controller.isOnline ? AppColors.primaryColor : Colors.grey[600]!,
                          ),
                          SizedBox(width: 8.w),
                          Switch(
                            value: controller.isOnline,
                            onChanged: (val) => controller.toggleOnlineStatus(),
                            activeColor: AppColors.primaryColor,
                            activeTrackColor: AppColors.primaryColor.withOpacity(0.3),
                            inactiveThumbColor: Colors.grey[400],
                            inactiveTrackColor: Colors.grey[300],
                            trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Calendar
                Container(
                  margin: EdgeInsets.all(16.w),
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
                    selectedDayPredicate: (day) {
                      return isSameDay(controller.selectedDay, day);
                    },
                    calendarFormat: CalendarFormat.week,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    onDaySelected: controller.onDaySelected,
                    onPageChanged: (focusedDay) {
                      controller.onPageChanged(focusedDay);
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      defaultTextStyle: TextStyle(fontSize: 14.sp),
                      weekendTextStyle: TextStyle(fontSize: 14.sp),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  ),
                ),

                // Filter Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: AppString.upcoming_button,
                          fontSize: 12,
                          height: 34,
                          isSelected: controller.selectedFilter == 0,
                          onTap: () => controller.changeFilter(0),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.pending_button,
                          fontSize: 12,
                          height: 34,
                          isSelected: controller.selectedFilter == 1,
                          onTap: () => controller.changeFilter(1),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomButton(
                          text: AppString.Cancel_button,
                          fontSize:12,
                          height: 34,
                          isSelected: controller.selectedFilter == 2,
                          onTap: () => controller.changeFilter(2),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16.h),

                // Booking List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: controller.getFilteredBookings().length,
                    itemBuilder: (context, index) {
                      final booking = controller.getFilteredBookings()[index];
                      return _buildBookingCard(booking, controller);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(BookingModel booking, HomeController controller) {
    return GestureDetector(
      onTap: (){
        if(controller.selectedFilter==0){
          Get.toNamed(AppRoutes.upcomingdetail_sscreen);
        }
        else if(controller.selectedFilter==1) {
          Get.toNamed(AppRoutes.view_detail_pending);
        }
        else{

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
                borderRadius: BorderRadius.zero, // no rounding
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.zero, // ensure no clipping to circle
                child: Image.asset(
                  "assets/images/item_image.png",
                  fit: BoxFit.cover, // fills the container
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
                    text: booking.customerName,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      SvgPicture.asset(
                        "assets/icons/propetion_icon.svg",
                        width: 16.w,
                        height: 16.h,
                        color: AppColors.black400,
                      ),
                      SizedBox(width: 4.w),
                      CommonText(
                        text: booking.service,
                        fontSize: 14.sp,
                        color: AppColors.black400,
                        fontWeight: FontWeight.w400,
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
                        text: booking.date,
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
                        text: booking.time,
                        fontSize: 12.sp,
                        color: AppColors.black200,
                        fontWeight: FontWeight.w400
                        ,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      CommonText(
                        text: 'Booking ID: ${booking.bookingId}',
                        fontSize: 12.sp,
                        color: AppColors.black300,
                        fontWeight: FontWeight.w400,
                      ),
                      SizedBox(width: 12.w),
                      CommonText(
                        text: 'RSD: ${booking.price}',
                        fontSize: 12.sp,
                        color: AppColors.black400,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // View Button
            CustomButton(
              text: AppString.view_button,
              isSelected: true,
              onTap: () => controller.viewBookingDetails(booking),
              isSmall: true,
              height: 24,
              //fontSize: 14,
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