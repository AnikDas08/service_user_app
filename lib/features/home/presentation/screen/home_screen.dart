import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../controller/home_controller.dart';
import '../widgets/bottom_sheet.dart';
import '../widgets/service_category_item.dart';
import '../widgets/service_provider_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedDate = "Date";
  String selectedTime = "Time";
  String selectedCategory = "Category";

  final List<String> categories = [
    "Haircut",
    "Massage",
    "Nail Care",
    "Skin Care",
    "Makeup",
    "Beard Trim",
    "Hair Wash",
    "Facial",
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Header Section
                  _buildHeader(),

                  SizedBox(height: 20.h),

                  // Search Bar
                  _buildDateTime(),

                  SizedBox(height: 20.h),

                  // Service Categories
                  _buildServiceCategories(),

                  SizedBox(height: 15.h),

                  // Service Providers Grid
                  _buildServiceProviders(),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile Image
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: CommonImage(
              imageSrc: "assets/images/profile_image.png",
              size: 46.w,
              fill: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: "Md Kamran Khan",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.black300,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 2.h),
              CommonText(
                text: AppString.welcome_text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black400,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTime() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: CommonTextField(
                  controller: controller.searchController,
                  hintText: "Search Here",
                  borderRadius: 30,
                  height: 36,
                  hintTextColor: AppColors.black200,
                ),
              )
            ),
            SizedBox(width: 10,),
            GestureDetector(
              onTap: () => _showFilterBottomSheet(Get.context!),
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  "assets/icons/filter.svg",
                  height: 24.h,
                  width: 24.w,
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildServiceCategories() {
    final categoriesData = [
      {"icon": "assets/icons/haircut_icon_here.svg", "label": "Haircut"},
      {"icon": "assets/icons/message_iconwork.svg", "label": "Massage"},
      {"icon": "assets/icons/nail_care.svg", "label": "Nail Care"},
      {"icon": "assets/icons/skin_care_icon.svg", "label": "Skin Care"},
      {"icon": "assets/icons/makeup_icon.svg", "label": "Makeup"},
    ];

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
              categoriesData.map((category) {
                return ServiceCategoryItem(
                  icon: category["icon"]!,
                  label: category["label"]!,
                  onTap: () {
                    Get.toNamed(AppRoutes.details_category_screen,arguments: category["label"]);
                  },
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildServiceProviders() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(text: AppString.avaliable_ite,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 14,),
              Obx(() {
                final providers = controller.filteredProviders;

                if (providers.isEmpty) {
                  return Center(
                    child: CommonText(
                      text: "No service providers found",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black600,
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: providers.length,
                  itemBuilder: (context, index) {
                    final provider = providers[index];
                    return ServiceProviderCard(
                      name: provider["name"]!,
                      service: provider["service"]!,
                      distance: provider["distance"]!,
                      rating: provider["rating"]!,
                      reviews: provider["reviews"]!,
                      price: provider["price"]!,
                      imageUrl: provider["image"]!,
                      onTap: () => controller.onProviderTap(provider),
                      onFavorite: () => controller.toggleFavorite(provider["name"]),
                    );
                  },
                );
              }),
            ]
        );
      },
    );
  }

  // Date Picker Method
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
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  // Time Picker Method
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.black400,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        selectedTime = "$hour:$minute"; // Example: 23:45
      });
    }
  }

  // Category Selection Method
  void _selectCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: CommonText(
            text: "Select Category",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
            textAlign: TextAlign.center,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: categories.length,
              separatorBuilder: (context, index) => Divider(
                color: AppColors.black100,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  title: CommonText(
                    text: category,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primaryColor : AppColors.black400,
                    textAlign: TextAlign.left,
                  ),
                  trailing: isSelected
                      ? Icon(
                    Icons.check_circle,
                    color: AppColors.primaryColor,
                    size: 20.sp,
                  )
                      : null,
                  onTap: () {
                    setState(() {
                      selectedCategory = category;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  selectedCategory = "Category";
                });
                Navigator.pop(context);
              },
              child: CommonText(
                text: "Clear",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black300,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: CommonText(
                text: "Cancel",
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }

  // Add this method to your HomeScreen class
  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    ).then((filterData) {
      // Handle the returned filter data
      if (filterData != null) {
        // You can access the filter values like:
        // filterData['category']
        // filterData['date']
        // filterData['time']
        // filterData['location']
        // filterData['priceRange']

        // Apply filters to your controller here
        // For example:
        // Get.find<HomeController>().applyFilters(filterData);
      }
    });
  }
}