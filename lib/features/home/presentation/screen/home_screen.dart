import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
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
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: controller.refreshData,
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),

                    // Header Section
                    _buildHeader(controller),

                    SizedBox(height: 20.h),

                    // Search Bar with Filter
                    _buildSearchBar(controller),

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
          ),
        );
      },
    );
  }

  Widget _buildHeader(HomeController controller) {
    return Row(
      children: [
        // Profile Image
        Container(
          width: 48.w,
          height: 48.w,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: Obx(
            ()=> ClipOval(
              child: controller.image!=""?Image.network(
                ApiEndPoint.socketUrl+controller.image.value,
                width: 46.w,
                height: 46.w,
                fit: BoxFit.cover,
              )
                  :Image.asset(
                "assets/images/profile_image.jpg",
                width: 46.w,
                height: 46.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        SizedBox(width: 12.w),

        // Welcome Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                  ()=>CommonText(
                    text: controller.name.value,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black300,
                    textAlign: TextAlign.left,
                  ),
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

  Widget _buildSearchBar(HomeController controller) {
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
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () => _showFilterBottomSheet(context),
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
  }

  Widget _buildServiceCategories() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Obx(() {
          if (controller.isLoadingCategories.value) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return Center(
              child: CommonText(
                text: "No categories available",
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.black300,
              ),
            );
          }

          return SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.categories.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final category = controller.categories[index];
                return Padding(
                  padding: EdgeInsets.only(
                    right: index < controller.categories.length - 1 ? 20.w : 0,
                  ),
                  child: ServiceCategoryItem(
                    icon: category["icon"]!,
                    label: category["name"]!,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.details_category_screen,
                        arguments: {
                          "id": category["id"],
                          "name": category["name"],
                        },
                      );
                    },
                  ),
                );
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildServiceProviders() {
    return GetBuilder<HomeController>(
      builder: (controller) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonText(
              text: AppString.avaliable_ite,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 14.h),
            Obx(() {
              if (controller.isLoadingProviders.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              }

              final providers = controller.filteredProviders;

              if (providers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: CommonText(
                      text: "No service providers found",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.black600,
                    ),
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
                    id: provider.id,                    // From API
                    name: provider.name,                 // From API
                    service: provider.category,       // From API
                    distance: "${provider.serviceDistance}km", // From API
                    rating: "4.5",                       // Default or from API if available
                    reviews: "0",                        // Default or from API if available
                    price: "RSD ${provider.price.toStringAsFixed(0)}", // From API
                    imageUrl: provider.image != null
                        ? ApiEndPoint.socketUrl + provider.image!
                        : "assets/images/item_image.png",
                    onTap: () => controller.onProviderTap(provider.id),
                    onFavorite: () => controller.toggleFavorite(provider.id),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    ).then((filterData) {
      if (filterData != null) {
        Get.find<HomeController>().applyFilters(filterData);
      }
    });
  }
}