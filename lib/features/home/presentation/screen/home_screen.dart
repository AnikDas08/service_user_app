import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../component/text_field/common_text_field.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_icons.dart';
import '../controller/home_controller.dart';
import '../widgets/service_category_item.dart';
import '../widgets/service_provider_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

                  SizedBox(height: 24.h),

                  // Search Bar
                  _buildSearchBar(),

                  SizedBox(height: 24.h),

                  // Service Categories
                  _buildServiceCategories(),

                  SizedBox(height: 32.h),

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
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: ClipOval(
            child: CommonImage(
              imageSrc: "https://via.placeholder.com/50",
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
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textColor,
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 2.h),
              CommonText(
                text: "Welcome To Veldora",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.black600,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),

        // Menu Icon
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.red50,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: CommonImage(
              imageSrc: AppIcons.burger,
              size: 20.w,
              imageColor: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CommonTextField(
            controller: controller.searchController,
            hintText: "Any Treatment",
            prefixIconData: Icons.search,
            borderRadius: 12.r,
            fillColor: AppColors.white,
            borderColor: AppColors.transparent,
            onSubmitted: (value) => controller.searchProviders(value),
          ),
        );
      },
    );
  }

  Widget _buildServiceCategories() {
    final categories = [
      {"icon": AppIcons.haircut, "label": "Haircut"},
      {"icon": AppIcons.massage, "label": "Massage"},
      {"icon": AppIcons.nailCare, "label": "Nail Care"},
      {"icon": AppIcons.skinCare, "label": "Skin Care"},
      {"icon": AppIcons.makeup, "label": "Makeup"},
    ];

    return GetBuilder<HomeController>(
      builder: (controller) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  categories.map((category) {
                    return ServiceCategoryItem(
                      icon: category["icon"]!,
                      label: category["label"]!,
                      onTap:
                          () => controller.onServiceCategoryTap(
                            category["label"]!,
                          ),
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
        return Obx(() {
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
                onFavorite: () => controller.onFavoriteTap(provider),
              );
            },
          );
        });
      },
    );
  }
}
