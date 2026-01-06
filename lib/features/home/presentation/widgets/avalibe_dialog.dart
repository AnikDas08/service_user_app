import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/service_details_controller.dart';

class ScheduleSlot {
  final String id;
  final DateTime start;  // UTC time from API
  final DateTime end;    // UTC time from API
  final DateTime? date;
  bool isSelected;

  ScheduleSlot({
    required this.id,
    required this.start,
    required this.end,
    this.date,
    this.isSelected = false,
  });

  bool get isValid => date != null;

  // ✅ FIX: Use LOCAL time for display
  String get displayTime {
    // Convert UTC to local time
    DateTime localStart = start.toLocal();
    DateTime localEnd = end.toLocal();

    // ✅ Use localStart and localEnd instead of start and end
    String startHour = localStart.hour.toString().padLeft(2, '0');
    String startMinute = localStart.minute.toString().padLeft(2, '0');
    String endHour = localEnd.hour.toString().padLeft(2, '0');
    String endMinute = localEnd.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  // Optional: Add getters for local times if needed elsewhere
  DateTime get localStart => start.toLocal();
  DateTime get localEnd => end.toLocal();
}

String _getLocalTimeRangeFromStrings(dynamic schedule) {
  try {
    // If startTime and endTime are ISO strings
    DateTime startTimeUtc = DateTime.parse(schedule.startTimeString);
    DateTime endTimeUtc = DateTime.parse(schedule.endTimeString);

    // Convert to local
    DateTime startTimeLocal = startTimeUtc.toLocal();
    DateTime endTimeLocal = endTimeUtc.toLocal();

    // Format as HH:mm
    String startStr = '${startTimeLocal.hour.toString().padLeft(2, '0')}:${startTimeLocal.minute.toString().padLeft(2, '0')}';
    String endStr = '${endTimeLocal.hour.toString().padLeft(2, '0')}:${endTimeLocal.minute.toString().padLeft(2, '0')}';

    return '$startStr - $endStr';
  } catch (e) {
    print("Error converting time: $e");
    return schedule.formattedTimeRange ?? "N/A";
  }
}

String _getLocalTimeRange(dynamic schedule) {
  try {
    // Get startTime and endTime from schedule (these are UTC)
    DateTime startTimeUtc = schedule.startTime;  // Assuming these are DateTime
    DateTime endTimeUtc = schedule.endTime;

    // Convert to local
    DateTime startTimeLocal = startTimeUtc.toLocal();
    DateTime endTimeLocal = endTimeUtc.toLocal();

    // Format as HH:mm
    String startStr = '${startTimeLocal.hour.toString().padLeft(2, '0')}:${startTimeLocal.minute.toString().padLeft(2, '0')}';
    String endStr = '${endTimeLocal.hour.toString().padLeft(2, '0')}:${endTimeLocal.minute.toString().padLeft(2, '0')}';

    return '$startStr - $endStr';
  } catch (e) {
    // Fallback to original if parsing fails
    print("Error converting time: $e");
    return schedule.formattedTimeRange ?? "N/A";
  }
}

class AvailabilityDialog extends StatefulWidget {
  const AvailabilityDialog({super.key});

  @override
  State<AvailabilityDialog> createState() => _AvailabilityDialogState();
}

class _AvailabilityDialogState extends State<AvailabilityDialog> {
  late ServiceDetailsController controller;

  bool isLoadingSlots = false;
  List<ScheduleSlot> availableSlots = [];
  List<ScheduleSlot> selectedSlots = [];

  DateTime? selectedDate;
  dynamic selectedSchedule;
  bool showingSlots = false;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceDetailsController>();
  }

  @override
  Widget build(BuildContext context) {
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
            // Header with close button and back button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /*if (showingSlots)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showingSlots = false;
                        selectedDate = null;
                        selectedSchedule = null;
                        availableSlots.clear();
                        selectedSlots.clear();
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(5.w),
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        size: 20.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),*/
                Flexible(
                  child: CommonText(
                    text: AppString.select_time_slot,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    color: AppColors.black400,
                    textAlign: TextAlign.left,
                  ),
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

            // Content - Either schedule list or slots grid
            Flexible(
              child: showingSlots ? _buildSlotsView() : _buildScheduleList(),
            ),

            // Book Now button (only shown when slots are selected)
            if (showingSlots && selectedSlots.isNotEmpty)
              _buildBookingSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    return Obx(() {
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
                text: AppString.schedule_avaliable_do,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.black300,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              CommonText(
                text: AppString.schedule_available,
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

      return ListView.separated(
        shrinkWrap: true,
        itemCount: controller.providerSchedule.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final schedule = controller.providerSchedule[index];
          return _buildScheduleItem(schedule);
        },
      );
    });
  }

  Widget _buildScheduleItem(schedule) {
    return GestureDetector(
      onTap: () => _onScheduleItemTap(schedule),
      child: Container(
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
                        // ✅ FIX: Use local time instead of UTC
                        text: _getLocalTimeRange(schedule),
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
                        text: "${schedule.duration} ${AppString.minute}",
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

            Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: schedule.count == 0
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: CommonText(
                    text: schedule.count == 0 ? AppString.available : "${schedule.count} ${AppString.booked}",
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: schedule.count == 0 ? Colors.green : Colors.orange,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 4.h),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.sp,
                  color: AppColors.primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotsView() {
    if (isLoadingSlots) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
            SizedBox(height: 16.h),
            CommonText(
              text: "Loading time slots...",
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.black300,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 48.sp,
              color: AppColors.black200,
            ),
            SizedBox(height: 12.h),
            CommonText(
              text: AppString.time_slot_do,
              fontSize: 14.sp,
              color: AppColors.black400,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    num requiredSlots = controller.selectedServiceIds.length;

    return Column(
      children: [
        // Info banner
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CommonText(
                  text: "${AppString.select} $requiredSlots ${AppString.time_slot}${requiredSlots > 1 ? 's' : ''} ${AppString.you} $requiredSlots ${AppString.service}${requiredSlots > 1 ? 's' : ''}",
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // Slots grid
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.5,
            ),
            itemCount: availableSlots.length,
            itemBuilder: (context, index) {
              ScheduleSlot slot = availableSlots[index];
              return GestureDetector(
                onTap: () => _onSlotTap(slot, requiredSlots),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: slot.isSelected
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: slot.isSelected
                          ? AppColors.primaryColor
                          : AppColors.black50,
                      width: slot.isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: CommonText(
                      text: slot.displayTime,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: slot.isSelected
                          ? AppColors.primaryColor
                          : AppColors.black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBookingSection() {
    num requiredSlots = controller.selectedServiceIds.length;
    bool canBook = selectedSlots.length == requiredSlots;

    return Column(
      children: [
        SizedBox(height: 16.h),

        // Selected slots info
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CommonText(
                    text: "${AppString.select}: ${selectedSlots.length}/$requiredSlots slots",
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: canBook ? Colors.green : AppColors.primaryColor,
                  ),
                  if (selectedSlots.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSlots.clear();
                          for (var slot in availableSlots) {
                            slot.isSelected = false;
                          }
                        });
                      },
                      child: CommonText(
                        text: AppString.clear,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
              if (selectedSlots.isNotEmpty) ...[
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: selectedSlots.map((slot) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: CommonText(
                        text: slot.displayTime,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.white,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Book Now button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: canBook ? _confirmBooking : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canBook ? AppColors.primaryColor : Colors.grey[300],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
            child: CommonText(
              text: canBook
                  ? AppString.book_now_button
                  : "Select $requiredSlots slot${requiredSlots > 1 ? 's' : ''}",
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: canBook ? AppColors.white : Colors.grey[600]!,
            ),
          ),
        ),
      ],
    );
  }

  void _onScheduleItemTap(schedule) async {
    selectedSchedule = schedule;
    selectedDate = schedule.date;

    setState(() {
      showingSlots = true;
    });

    await _fetchScheduleForDate(schedule.date);
  }

  void _onSlotTap(ScheduleSlot slot, num requiredSlots) {
    if (controller.selectedServiceIds.isEmpty) {
      Get.snackbar(
        AppString.service_selected,
        AppString.select_service,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }
    if (!slot.isSelected && selectedSlots.length >= requiredSlots) {
      Get.snackbar(
        AppString.limit_here_show,
        'You can only select $requiredSlots time slot${requiredSlots > 1 ? 's' : ''} for $requiredSlots service${requiredSlots > 1 ? 's' : ''}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
        duration: Duration(seconds: 2),
      );
      return;
    }

    setState(() {
      slot.isSelected = !slot.isSelected;
      if (slot.isSelected) {
        if (!selectedSlots.contains(slot)) {
          selectedSlots.add(slot);
        }
      } else {
        selectedSlots.remove(slot);
      }
    });
  }

  Future<void> _fetchScheduleForDate(DateTime date) async {
    if (controller.providerData?.id == null) {
      Get.snackbar(
        AppString.error,
        'Provider information not available',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    try {
      setState(() {
        isLoadingSlots = true;
        availableSlots.clear();
        selectedSlots.clear();
      });

      DateTime startDateUtc = DateTime.utc(date.year, date.month, date.day);
      String formattedDate = startDateUtc.toIso8601String();

      String url = "schedule/provider-schedule-date/${controller.providerData!.id}?date=$formattedDate";

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final scheduleData = data['data'];

          if (scheduleData['available_slots'] != null) {
            List<dynamic> slots = scheduleData['available_slots'];

            setState(() {
              for (var slot in slots) {
                // Parse UTC times from API
                DateTime startUtc = DateTime.parse(slot['start']);
                DateTime endUtc = DateTime.parse(slot['end']);

                availableSlots.add(ScheduleSlot(
                  id: slot['_id'],
                  start: startUtc,  // Store as UTC
                  end: endUtc,      // Store as UTC
                  date: date,       // Store the selected date
                ));

                // Debug: Print to verify conversion
                print("🕐 Slot: UTC ${slot['start']} → Local ${startUtc.toLocal()}");
              }
            });

            if (availableSlots.isEmpty) {
              Get.snackbar(
                AppString.availibility_here,
                AppString.time_slot_available,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: AppColors.white,
              );
            }
          }
        }
      }
    } catch (e) {
      print("Error fetching schedule: $e");
      Get.snackbar(
        AppString.error,
        'Failed to load available time slots',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    } finally {
      setState(() {
        isLoadingSlots = false;
      });
    }
  }

  void _confirmBooking() {
    num requiredSlots = controller.selectedServiceIds.length;

    if (selectedSlots.length != requiredSlots) {
      Get.snackbar(
        AppString.valid_time_slot,
        "You must select exactly $requiredSlots time slot${requiredSlots > 1 ? 's' : ''} for your $requiredSlots service${requiredSlots > 1 ? 's' : ''}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    DateTime bookingDateUtc = DateTime.utc(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    // ✅ Send UTC times to API, but display local time
    List<Map<String, dynamic>> slotsData = selectedSlots.map((slot) {
      return {
        "start": slot.start.toUtc().toIso8601String(),  // Send UTC to API
        "end": slot.end.toUtc().toIso8601String(),      // Send UTC to API
        "displayTime": slot.displayTime,                 // Display shows local time
      };
    }).toList();

    String formattedDate = '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}';

    Map<String, dynamic> invoiceData = {
      'providerId': controller.providerData!.id,
      'provider': controller.providerData?.toJson(),
      'providerName': controller.providerName,
      'providerImage': controller.providerImage,
      'date': formattedDate,
      'dateIso': bookingDateUtc.toIso8601String(),
      'timeSlots': selectedSlots.map((slot) => slot.displayTime).toList(),  // Local time for display
      'slotsData': slotsData,
      'selectedServices': controller.getSelectedServices(),
      'selectedServiceIds': controller.selectedServiceIds.toList(),
      'totalPrice': controller.getTotalPrice(),
      'totalDuration': controller.getTotalDuration(),
      'description': '',
      'image': null,
    };

    Get.back();
    Get.toNamed(AppRoutes.invoice, arguments: invoiceData);

    Get.snackbar(
      AppString.successful,
      AppString.booking_confirmed,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.white,
    );
  }

  String _getMonthShort(num month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month.toInt() - 1];
  }

  String _format24HourTime(String timeRange) {
    if (!timeRange.contains('AM') && !timeRange.contains('PM')) {
      return timeRange;
    }

    try {
      final parts = timeRange.split(' - ');
      if (parts.length != 2) return timeRange;

      String startTime24 = _convertTo24Hour(parts[0].trim());
      String endTime24 = _convertTo24Hour(parts[1].trim());

      return '$startTime24 - $endTime24';
    } catch (e) {
      return timeRange;
    }
  }

  String _convertTo24Hour(String time12) {
    time12 = time12.trim();

    bool isPM = time12.toUpperCase().contains('PM');
    bool isAM = time12.toUpperCase().contains('AM');

    String timePart = time12.replaceAll(RegExp(r'(AM|PM|am|pm)', caseSensitive: false), '').trim();

    List<String> timeParts = timePart.split(':');
    if (timeParts.isEmpty) return time12;

    num hour = int.tryParse(timeParts[0]) ?? 0;
    String minute = timeParts.length > 1 ? timeParts[1] : '00';

    if (isPM && hour != 12) {
      hour += 12;
    } else if (isAM && hour == 12) {
      hour = 0;
    }

    return '${hour.toString().padLeft(2, '0')}:$minute';
  }
}