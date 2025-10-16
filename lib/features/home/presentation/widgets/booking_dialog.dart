import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../component/text/common_text.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../controller/service_details_controller.dart';

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

  @override
  void initState() {
    super.initState();
    _updateTimeControllerText();
  }

  void _updateTimeControllerText() {
    setState(() {
      timeController.text = serviceController.getSelectedTimeSlotsText();
    });
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
      onTap: _selectDate,
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
              text: dateController.text.isEmpty ? "Date" : dateController.text,
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

  Widget _buildTimeSlotField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _showTimeSlotDialog,
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
                        ? "Select Time Slots"
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

        /*SizedBox(height: 8.h),
        GetBuilder<ServiceDetailsController>(
          builder: (controller) {
            return controller.selectedTimeSlots.isNotEmpty
                ? Wrap(
              spacing: 8.w,
              runSpacing: 4.h,
              children: controller.selectedTimeSlots.map((slot) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CommonText(
                        text: '${slot.displayTime}',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryColor,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(width: 4.w),
                      GestureDetector(
                        onTap: () {
                          controller.toggleTimeSlot(slot);
                          _updateTimeControllerText();
                        },
                        child: Icon(
                          Icons.close,
                          size: 12.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            )
                : SizedBox.shrink();
          },
        ),*/
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

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black400,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _showTimeSlotDialog() {
    final serviceController = Get.find<ServiceDetailsController>();

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
                  text: "Select Time Slots",
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: "Choose your preferred time slots",
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),

                // Direct Time Slots Grid - No Day Selection
                _buildAllTimeSlotGrid(),

                SizedBox(height: 20.h),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          serviceController.clearTimeSlotSelections();
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
                          text: "Clear All",
                          fontSize: 14.sp,
                          color: AppColors.black400,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
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
                          text: "Done",
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

  // Simplified grid showing all available time slots
  Widget _buildAllTimeSlotGrid() {
    return GetBuilder<ServiceDetailsController>(
      builder: (controller) {
        if (controller.availableTimeSlots.isEmpty) {
          return SizedBox(
            height: 100.h,
            child: Center(
              child: CommonText(
                text: "No time slots available",
                fontSize: 14.sp,
                color: AppColors.black400,
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return SizedBox(
          height: 300.h, // Increased height to accommodate all slots
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // Single column to show day + time
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 4, // Wide slots to show full info
            ),
            itemCount: controller.availableTimeSlots.length,
            itemBuilder: (context, index) {
              TimeSlot slot = controller.availableTimeSlots[index];
              return GestureDetector(
                onTap: () {
                  controller.toggleTimeSlot(slot);
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CommonText(
                            text: slot.displayTime,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: slot.isSelected
                                ? AppColors.primaryColor
                                : AppColors.black,
                            textAlign: TextAlign.start,
                          ),
                        ],
                      ),
                      if (slot.isSelected)
                        Icon(
                          Icons.check_circle,
                          color: AppColors.primaryColor,
                          size: 20.sp,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
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
        "Error",
        "Failed to select image: $e",
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
    final serviceController = Get.find<ServiceDetailsController>();

    if (serviceController.selectedTimeSlots.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select at least one time slot",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    if (dateController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select a date",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: AppColors.white,
      );
      return;
    }

    Map<String, dynamic> bookingData = {
      'date': dateController.text,
      'timeSlots': serviceController.selectedTimeSlots.map((slot) => {
        'day': slot.day,
        'startTime': slot.startTime,
        'endTime': slot.endTime,
      }).toList(),
      'description': descriptionController.text,
      'image': _selectedImage?.path,
    };

    print("Booking Data: $bookingData");

    Get.back();
    //print("service 😍😍😍😍${serviceController.serviceProvider}dfgf");
    Get.toNamed(AppRoutes.invoice,arguments: serviceController.services);
    Get.snackbar(
      "Booking Confirmed",
      "Your booking has been confirmed for ${serviceController.selectedTimeSlots.length} time slot(s)!",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.white,
    );
  }
}