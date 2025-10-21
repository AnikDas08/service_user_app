import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/home_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final HomeController controller = Get.find<HomeController>();

  String? selectedCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedLocation;
  double priceRange = 500;
  final double maxPrice = 1000;

  final List<String> locations = [
    'Select location',
    'Dhaka',
    'Chittagong',
    'Sylhet',
    'Rajshahi',
    'Khulna'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.60,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Handle bar and close button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(),
                Container(
                  width: 40.w,
                  height: 4.h,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.black100,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.red50,
                      borderRadius: BorderRadius.circular(100),
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
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Section
                    _buildSectionTitle('Category'),
                    SizedBox(height: 12.h),
                    _buildCategoryDropdown(),

                    SizedBox(height: 16.h),

                    // Date Section
                    _buildDateField(),

                    SizedBox(height: 16.h),

                    // Time Section
                    _buildTimeField(),

                    SizedBox(height: 16.h),

                    // Location Section
                    _buildSectionTitle('Location'),
                    SizedBox(height: 12.h),
                    _buildLocationDropdown(),

                    SizedBox(height: 16.h),

                    // Price Section
                    _buildSectionTitle('Price'),
                    SizedBox(height: 5.h),
                    _buildPriceSlider(),
                    SizedBox(height: 30.h),
                    // Apply Button
                    _buildApplyButton(),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return CommonText(
      text: title,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.black400,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() {
      if (controller.isLoadingCategories.value) {
        return Container(
          width: double.infinity,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black100, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: SizedBox(
              height: 20.h,
              width: 20.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        );
      }

      final categories = controller.categories.map((cat) => cat['name'] as String).toList();

      return Container(
        width: double.infinity,
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100, width: 1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedCategory,
            hint: CommonText(
              text: 'Select Category',
              fontSize: 12,
              color: AppColors.black200,
              textAlign: TextAlign.left,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.black300,
              size: 24.sp,
            ),
            isExpanded: true,
            items: categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: CommonText(
                  text: category,
                  fontSize: 14,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue;
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        width: double.infinity,
        height: 44,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100, width: 1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'Date',
              fontSize: 14,
              color: selectedDate != null ? AppColors.black400 : AppColors.black200,
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.calendar_today,
              color: AppColors.black300,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        height: 44,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black100, width: 1),
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: selectedTime != null
                  ? selectedTime!.format(context)
                  : 'Time',
              fontSize: 14,
              color: selectedTime != null ? AppColors.black400 : AppColors.black200,
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.access_time,
              color: AppColors.black300,
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return Container(
      height: 44,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black100, width: 1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedLocation,
          hint: CommonText(
            text: 'Select location',
            fontSize: 14,
            color: AppColors.black200,
            textAlign: TextAlign.left,
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.black300,
            size: 20.sp,
          ),
          isExpanded: true,
          items: locations.map((String location) {
            return DropdownMenuItem<String>(
              value: location == 'Select location' ? null : location,
              child: CommonText(
                text: location,
                fontSize: 14,
                color: location == 'Select location'
                    ? AppColors.black400
                    : AppColors.black200,
                textAlign: TextAlign.left,
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedLocation = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPriceSlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primaryColor,
            inactiveTrackColor: AppColors.black300,
            thumbColor: AppColors.primaryColor,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8.r),
            overlayColor: AppColors.primaryColor.withOpacity(0.2),
            trackHeight: 4.h,
          ),
          child: Slider(
            value: priceRange,
            min: 0,
            max: maxPrice,
            divisions: 20,
            onChanged: (double value) {
              setState(() {
                priceRange = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: 'RSD${priceRange.toInt()}',
              fontSize: 12,
              color: AppColors.black200,
              textAlign: TextAlign.left,
              fontWeight: FontWeight.w400,
            ),
            CommonText(
              text: 'RSD${maxPrice.toInt()}',
              fontSize: 12,
              color: AppColors.black200,
              textAlign: TextAlign.left,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplyButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: _applyFilters,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.r),
          ),
          elevation: 0,
        ),
        child: CommonText(
          text: 'Apply',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      initialEntryMode: TimePickerEntryMode.input,
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

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  void _applyFilters() {
    // Create filter data to pass back
    Map<String, dynamic> filterData = {
      'category': selectedCategory,
      'date': selectedDate,
      'time': selectedTime,
      'location': selectedLocation,
      'priceRange': priceRange,
    };

    // Pass the filter data back and close bottom sheet
    Get.back(result: filterData);
  }
}