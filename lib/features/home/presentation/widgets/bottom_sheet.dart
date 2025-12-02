import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/features/home/presentation/widgets/show_custom_calender.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
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
  String? selectedCategoryId;
  String? selectedSubCategory;
  String? selectedSubCategoryId;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedLocation;
  double priceRange = 500;
  final double minPrice = 500;
  final double maxPrice = 150000;
  TextEditingController locationControllers = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
            minHeight: 200,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Flexible(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Category Section
                      _buildSectionTitle(AppString.category),
                      SizedBox(height: 12.h),
                      _buildCategoryDropdown(),

                      SizedBox(height: 16.h),

                      // Subcategory Section (only show if category is selected)
                      if (selectedCategoryId != null) ...[
                        _buildSectionTitle(AppString.subService),
                        SizedBox(height: 12.h),
                        _buildSubCategoryDropdown(),
                        SizedBox(height: 16.h),
                      ],

                      // Date Section
                      _buildDateField(),

                      SizedBox(height: 16.h),

                      // Time Section
                      _buildTimeField(),

                      SizedBox(height: 16.h),

                      // Location Section
                      _buildSectionTitle(AppString.location_text),
                      SizedBox(height: 12.h),
                      CommonTextField(
                        controller: locationControllers,
                        hintText: AppString.hint_type_here,
                      ),

                      SizedBox(height: 16.h),

                      // Price Section
                      _buildSectionTitle(AppString.price),
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
            ],
          ),
        ),
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
      final categoriesId = controller.categories.map((cat) => cat['id'] as String).toList();

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
              text: AppString.select_category_text,
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
                selectedCategoryId = categoriesId[categories.indexWhere((element) => element == newValue)];

                // Reset subcategory when category changes
                selectedSubCategory = null;
                selectedSubCategoryId = null;

                // Fetch subcategories for the selected category
                if (selectedCategoryId != null) {
                  controller.fetchSubCategories(selectedCategoryId!);
                }
              });
            },
          ),
        ),
      );
    });
  }

  Widget _buildSubCategoryDropdown() {
    return Obx(() {
      // Check if subcategories are loading for the selected category
      bool isLoading = controller.isLoadingSubCategories[selectedCategoryId] ?? false;

      if (isLoading) {
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

      // Get subcategories for the selected category
      List<Map<String, dynamic>> subCategories =
          controller.subCategoriesMap[selectedCategoryId] ?? [];

      // If no subcategories available
      if (subCategories.isEmpty) {
        return Container(
          width: double.infinity,
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.black100, width: 1),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: CommonText(
              text: AppString.noSubcategory,
              fontSize: 12,
              color: AppColors.black200,
              textAlign: TextAlign.left,
            ),
          ),
        );
      }

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
            value: selectedSubCategory,
            hint: CommonText(
              text: AppString.select_subtype,
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
            items: subCategories.map((Map<String, dynamic> subCat) {
              return DropdownMenuItem<String>(
                value: subCat['subCategoryName'],
                child: CommonText(
                  text: subCat['subCategoryName'],
                  fontSize: 14,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSubCategory = newValue;
                // Find the subcategory ID
                final subCat = subCategories.firstWhere(
                      (s) => s['subCategoryName'] == newValue,
                  orElse: () => {},
                );
                selectedSubCategoryId = subCat['_id'];
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
                  : AppString.date,
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
                  : AppString.time,
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
            min: minPrice,
            max: maxPrice,
            divisions: 290,
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
          text: AppString.apply_button,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.white,
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    // ⭐️ Replacing the use of showDatePicker with your custom dialog
    showCustomCalendarView(
      // The initial date should be the currently selected date or today
      initialDate: selectedDate ?? DateTime.now(),

      // The callback function handles the date selection from the custom dialog
      onDateSelected: (DateTime pickedDate) {
        // This setState is called when the user selects a date and the dialog closes
        setState(() {
          selectedDate = pickedDate;
        });
      },
      // You can ignore `isSecond` for a single date picker
      isSecond: false,
    );

    // Note: Since showCustomCalendarView is a void function that uses a callback
    // to handle the result, this method no longer needs to be `async`
    // and wait for a result, but we keep `Future<void>` for consistency.
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
    // Format date and time
    String? formattedDate;

    if (selectedDate != null && selectedTime != null) {
      // Both date and time are selected
      final dateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
        0,
      );
      formattedDate = dateTime.toIso8601String();
    } else if (selectedDate != null && selectedTime == null) {
      // Only date is selected (no time)
      final dateOnly = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        0,
        0,
        0,
      );
      formattedDate = dateOnly.toIso8601String();
    } else if (selectedDate == null && selectedTime != null) {
      // Only time is selected (use current date with selected time)
      final now = DateTime.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        selectedTime!.hour,
        selectedTime!.minute,
        0,
      );
      formattedDate = dateTime.toIso8601String();
    }

    print("Date: $formattedDate");

    // Create filter data to pass back
    Map<String, dynamic> filterData = {
      'categoryId': selectedCategoryId,
      'subCategoryId': selectedSubCategoryId,
      'date': formattedDate,
      'location': locationControllers.text.isNotEmpty ? locationControllers.text : null,
      'userLng': "90.3890144",
      'userLat': "23.7643863",
      'minPrice': 0,
      'maxPrice': priceRange.toString(),
    };
    print("Filter data : $filterData");

    // Call the controller method to apply filters and fetch from API
    controller.applyFiltersWithAPI(filterData);

    // Close bottom sheet
    Get.back();
  }
}