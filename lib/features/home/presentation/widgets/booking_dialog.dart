import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/presentation/widgets/show_custom_calender.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../controller/service_details_controller.dart';

class ScheduleSlot {
  final String id;
  final DateTime start;  // UTC time from API
  final DateTime end;    // UTC time from API
  bool isSelected;

  ScheduleSlot({
    required this.id,
    required this.start,
    required this.end,
    this.isSelected = false,
  });

  // ✅ FIX: Use LOCAL time for display
  String get displayTime {
    // Convert UTC to local time
    DateTime localStart = start.toLocal();
    DateTime localEnd = end.toLocal();

    // ✅ Use localStart and localEnd (NOT start and end)
    String startHour = localStart.hour.toString().padLeft(2, '0');
    String startMinute = localStart.minute.toString().padLeft(2, '0');
    String endHour = localEnd.hour.toString().padLeft(2, '0');
    String endMinute = localEnd.minute.toString().padLeft(2, '0');

    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  // Optional: Add getters for local times
  DateTime get localStart => start.toLocal();
  DateTime get localEnd => end.toLocal();
}

class BookingDialog extends StatefulWidget {
  const BookingDialog({super.key});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  final serviceController = Get.find<ServiceDetailsController>();

  final RxBool isLoadingSchedule = false.obs;
  final RxBool isLoadingDates = false.obs;
  final RxList<ScheduleSlot> availableSlots = <ScheduleSlot>[].obs;
  final RxList<ScheduleSlot> selectedSlots = <ScheduleSlot>[].obs;
  final RxSet<String> datesWithSlots = <String>{}.obs; // Store dates as strings "yyyy-MM-dd"
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _updateTimeControllerText();
    _loadAvailableDates();
  }

  void _updateTimeControllerText() {
    setState(() {
      if (selectedSlots.isEmpty) {
        timeController.text = '';
      } else {
        timeController.text = selectedSlots.map((slot) => slot.displayTime).join(', ');
      }
    });
  }

  // Load all dates that have available slots
  Future<void> _loadAvailableDates() async {
    if (serviceController.providerData?.user.id == null) {
      return;
    }

    try {
      isLoadingDates.value = true;

      final response = await ApiService.get(
        "schedule/provider-schedule/${serviceController.providerData!.user.id}",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      print("📡 Available Dates Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        if (data is List) {
          datesWithSlots.clear();

          for (var schedule in data) {
            // Check if schedule is active and has count > 0 (or any count since count 0 might still be valid)
            if (schedule['isActive'] == true && schedule['date'] != null) {
              DateTime scheduleDate = DateTime.parse(schedule['date']);
              String dateKey = "${scheduleDate.year}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}";
              datesWithSlots.add(dateKey);
            }
          }

          print("✅ Loaded ${datesWithSlots.length} dates with available slots");
          print("📅 Dates: ${datesWithSlots.toList()}");
        }
      }
    } catch (e) {
      print("❌ Error loading available dates: $e");
    } finally {
      isLoadingDates.value = false;
    }
  }

  bool _hasSlots(DateTime date) {
    String dateKey = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    return datesWithSlots.contains(dateKey);
  }

  Future<void> _fetchScheduleForDate(DateTime date) async {
    if (serviceController.providerData?.user.id == null) {
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
      isLoadingSchedule.value = true;
      availableSlots.clear();
      selectedSlots.clear();

      DateTime startDateUtc = DateTime.utc(date.year, date.month, date.day);
      String formattedDate = startDateUtc.toIso8601String();

      String url = "schedule/provider-schedule-date/${serviceController.providerData!.id}?date=$formattedDate";

      print("📥 Fetching schedule for date: $formattedDate");

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      print("📡 Response Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['success'] == true && data['data'] != null) {
          final scheduleData = data['data'];

          if (scheduleData['available_slots'] != null) {
            List<dynamic> slots = scheduleData['available_slots'];

            for (var slot in slots) {
              availableSlots.add(ScheduleSlot(
                id: slot['_id'],
                start: DateTime.parse(slot['start']),
                end: DateTime.parse(slot['end']),
              ));
            }

            print("✅ Loaded ${availableSlots.length} available slots");
          }
        }
      }
    } catch (e) {
      print("❌ Error fetching schedule: $e");
      Get.snackbar(
        AppString.error,
        'Failed to load available time slots: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    } finally {
      isLoadingSchedule.value = false;
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    timeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CommonText(
                  text: AppString.booking_date_time_text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(height: 16.h),

              _buildDateField(),

              SizedBox(height: 16.h),

              _buildTimeSlotField(),

              SizedBox(height: 20.h),

              CommonText(
                text: AppString.service_description,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.black400,
                textAlign: TextAlign.left,
              ),

              SizedBox(height: 8.h),

              Container(
                height: 80.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.black100, width: 1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: AppString.type_profile,
                    hintStyle: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.black200,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.black400,
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              CommonText(
                text: AppString.service_example,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.black400,
                textAlign: TextAlign.left,
              ),

              SizedBox(height: 8.h),

              _buildImagePicker(),

              SizedBox(height: 30.h),

              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    elevation: 0,
                  ),
                  child: CommonText(
                    text: AppString.confirms_button,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _showCustomDatePicker,
      child: Container(
        height: 48.h,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: dateController.text.isEmpty ? AppString.date : dateController.text,
              fontSize: 14,
              color: dateController.text.isEmpty ? AppColors.black200 : AppColors.black300,
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 18.sp,
              color: AppColors.black300,
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomDatePicker() {
    // If dates are already loaded and available, directly show the custom calendar.
    if (!isLoadingDates.value && datesWithSlots.isNotEmpty) {
      // ⭐️ DIRECTLY CALL THE CUSTOM CALENDAR HERE
      _openCustomCalendar();
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CommonText(
                      text: AppString.select_date,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, size: 24.sp),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  if (isLoadingDates.value) {
                    return SizedBox(
                      height: 300.h,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    );
                  }

                  // Check if there are no available dates
                  if (datesWithSlots.isEmpty) {
                    return SizedBox(
                      height: 300.h,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 64.sp,
                              color: AppColors.black200,
                            ),
                            SizedBox(height: 16.h),
                            CommonText(
                              text: AppString.available_date,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black400,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            CommonText(
                              text: AppString.provider_available,
                              fontSize: 14.sp,
                              color: AppColors.black200,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // ⭐️ If data is ready, close this dialog and open the custom calendar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pop(context);
                    _openCustomCalendar();
                  });
                  return Container(); // Placeholder until pop happens
                }),
              ],
            ),
          ),
        );
      },
    );
  }

// ⭐️ NEW METHOD TO WRAP THE CUSTOM CALENDAR CALL
  void _openCustomCalendar() {
    showCustomCalendarView(
      initialDate: selectedDate ?? DateTime.now(),
      isSecond: false,
      // ✅ Pass the available dates to the custom calendar
      availableDates: datesWithSlots.map((dateStr) {
        // Convert "yyyy-MM-dd" string back to DateTime
        final parts = dateStr.split('-');
        return DateTime(
          int.parse(parts[0]), // year
          int.parse(parts[1]), // month
          int.parse(parts[2]), // day
        );
      }).toList(),
      onDateSelected: (DateTime date) {
        if (_hasSlots(date)) {
          setState(() {
            selectedDate = date;
            dateController.text = '${date.day}/${date.month}/${date.year}';
            timeController.clear();
            selectedSlots.clear();
          });
          _fetchScheduleForDate(date);
        } else {
          Get.snackbar(
            AppString.availibility_here,
            AppString.time_slot_available,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.grey,
            colorText: AppColors.white,
            duration: Duration(seconds: 2),
          );
        }
      },
    );
  }

  Widget _buildTimeSlotField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            if (selectedDate == null) {
              Get.snackbar(
                AppString.select_date,
                AppString.select_date_work,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryColor,
                colorText: AppColors.white,
              );
            } else {
              _showTimeSlotDialog();
            }
          },
          child: Container(
            height: 48,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.black100, width: 1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CommonText(
                    text: timeController.text.isEmpty
                        ? "${AppString.select_time_slot}"
                        : timeController.text,
                    fontSize: 14,
                    color: timeController.text.isEmpty
                        ? AppColors.black200
                        : AppColors.black300,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                  ),
                ),
                Icon(
                  Icons.access_time_outlined,
                  size: 18.sp,
                  color: AppColors.black300,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _selectImageFromGallery,
      child: Container(
        width: double.infinity,
        height: _selectedImage != null ? 120.h : 60.h,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100, width: 1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: _selectedImage != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                _selectedImage!,
                width: double.infinity,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: AppColors.white,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                size: 24.sp,
                color: AppColors.primaryColor,
              ),
              SizedBox(height: 4.h),
              CommonText(
                text: AppString.tap_image_customer,
                fontSize: 12,
                color: AppColors.black200,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeSlotDialog() {
    num requiredSlots = serviceController.selectedServiceIds.length;
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              children: [
                CommonText(
                  text: AppString.select_time_slot,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
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
                          text: "Select $requiredSlots time slot${requiredSlots > 1 ? 's' : ''} for your $requiredSlots service${requiredSlots > 1 ? 's' : ''}",
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryColor,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: AppString.time_slot_choose,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                _buildScheduleSlotGrid(),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          selectedSlots.clear();
                          for (var slot in availableSlots) {
                            slot.isSelected = false;
                          }
                          availableSlots.refresh();
                          _updateTimeControllerText();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: CommonText(
                          text: AppString.clear_all,
                          fontSize: 14.sp,
                          color: AppColors.black400,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (selectedSlots.length != requiredSlots) {
                            Get.snackbar(
                              'Invalid Selection',
                              'Please select exactly $requiredSlots time slot${requiredSlots > 1 ? 's' : ''} to match your $requiredSlots service${requiredSlots > 1 ? 's' : ''}',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: AppColors.white,
                              duration: Duration(seconds: 3),
                            );
                            return;
                          }

                          _updateTimeControllerText();
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: CommonText(
                          text: AppString.done_button,
                          fontSize: 14.sp,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleSlotGrid() {
    return Obx(() {
      if (isLoadingSchedule.value) {
        return SizedBox(
          height: 200.h,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      if (availableSlots.isEmpty) {
        return SizedBox(
          height: 200.h,
          child: Center(
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
                  text: AppString.time_slot_avaibales,
                  fontSize: 14.sp,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                CommonText(
                  text: AppString.select_different,
                  fontSize: 12.sp,
                  color: AppColors.black200,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: 300.h,
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
              onTap: () {
                num requiredSlots = serviceController.selectedServiceIds.length;

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
                slot.isSelected = !slot.isSelected;
                if (slot.isSelected) {
                  if (!selectedSlots.contains(slot)) {
                    selectedSlots.add(slot);
                  }
                } else {
                  selectedSlots.remove(slot);
                }
                availableSlots.refresh();
                selectedSlots.refresh();
              },
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
      );
    });
  }

  Future<void> _selectImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "${AppString.failed_image}: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _confirmBooking() {
    if (selectedDate == null || dateController.text.isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.select_date_easy,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    if (serviceController.selectedServiceIds.isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.select_service,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    num requiredSlots = serviceController.selectedServiceIds.length;
    if (selectedSlots.length != requiredSlots) {
      Get.snackbar(
        AppString.invalid_time_slot,
        "You must select exactly $requiredSlots time slot${requiredSlots > 1 ? 's' : ''} for your $requiredSlots service${requiredSlots > 1 ? 's' : ''}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: AppColors.white,
        duration: Duration(seconds: 3),
      );
      return;
    }

    if (selectedSlots.isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.select_time_slot,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    DateTime bookingDateUtc = DateTime.utc(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
    );

    List<Map<String, dynamic>> slotsData = selectedSlots.map((slot) {
      return {
        "start": slot.start.toIso8601String(),
        "end": slot.end.toIso8601String(),
        "displayTime": slot.displayTime,
      };
    }).toList();

    Map<String, dynamic> invoiceData = {
      'providerId': serviceController.providerData!.id,
      'provider': serviceController.providerData?.toJson(),
      'providerName': serviceController.providerName,
      'providerImage': serviceController.providerImage,
      'date': dateController.text,
      'dateIso': bookingDateUtc.toIso8601String(),
      'timeSlots': selectedSlots.map((slot) => slot.displayTime).toList(),
      'slotsData': slotsData,
      'selectedServices': serviceController.getSelectedServices(),
      'selectedServiceIds': serviceController.selectedServiceIds.toList(),
      'totalPrice': serviceController.getTotalPrice(),
      'totalDuration': serviceController.getTotalDuration(),
      'description': descriptionController.text,
      'image': _selectedImage?.path,
    };

    print("📄 Invoice Data Prepared: $invoiceData");

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
}