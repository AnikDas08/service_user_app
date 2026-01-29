import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/button/common_button.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/image_view/imageview_class.dart';
import '../../../../component/text/common_text.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<HomeController>().loadMoreProviders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                // Refresh based on whether filters are active
                if (controller.isFilterActive.value && controller.currentFilterUrl != null) {
                  // Refresh with current filters
                  await controller.fetchServiceProviders(filterUrl: controller.currentFilterUrl);
                } else {
                  // Refresh all data without filters
                  await controller.refreshData();
                }
              },
              color: AppColors.primaryColor,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: AlwaysScrollableScrollPhysics(),
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

                    // Loading more indicator
                    _buildLoadMoreIndicator(controller),

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile Image
        GestureDetector(
          onTap: (){
            if (controller.image.value != null) {
              ImageViewerScreen.openSingle(
                Get.context!,
                ApiEndPoint.socketUrl + controller.image.value!,
              );
            }
            else{
              ImageViewerScreen.openSingle(
                Get.context!,
                "assets/images/profile_image.jpg",
              );
            }
          },
          child: Container(
            width: 48.w,
            height: 48.w,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Obx(
                  () => ClipOval(
                child: controller.image.value.isNotEmpty
                    ? Image.network(
                  ApiEndPoint.socketUrl + controller.image.value,
                  width: 46.w,
                  height: 46.w,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/images/profile_image.jpg",
                      width: 46.w,
                      height: 46.w,
                      fit: BoxFit.cover,
                    );
                  },
                )
                    : Image.asset(
                  "assets/images/profile_image.jpg",
                  width: 46.w,
                  height: 46.w,
                  fit: BoxFit.cover,
                ),
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
                    () => CommonText(
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

        // Notification Icon with Badge
        GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.notifications);
              Get.find<HomeController>().countNotification();
            },
            child: Obx(
                  () => Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AppColors.black300,
                    size: 24.sp,
                  ),

                  /// Show badge only if count > 0
                  if (controller.notificationCount.value > 0)
                    Positioned(
                      right: -4.w,
                      top: -4.h,
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5.w,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16.w,
                          minHeight: 16.h,
                        ),
                        child: Center(
                          child: Text(
                            controller.notificationCount.value.toString(),
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )

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
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    decoration: InputDecoration(
                      hintText: AppString.search.tr,
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: AppColors.black200),
                    ),
                  ),
                ),

                SizedBox(width: 10),

                // Show searching indicator or clear button
                Obx(() {
                  if (controller.isSearching.value) {
                    return SizedBox(
                      width: 18.sp,
                      height: 18.sp,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    );
                  } else if (controller.searchController.text.isNotEmpty) {
                    return IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18.sp,
                        color: AppColors.black100,
                      ),
                      onPressed: () {
                        controller.searchController.clear();
                      },
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
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
        ),
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
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              ),
            );
          }

          if (controller.categories.isEmpty) {
            return Center(
              child: CommonText(
                text: AppString.category_available_top,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonText(
                  text: AppString.avaliable_ite,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                  textAlign: TextAlign.left,
                ),
                // Show clear filter button when filters are active
                Obx(() {
                  if (controller.isFilterActive.value || controller.searchController.text.isNotEmpty) {
                    return GestureDetector(
                      onTap: () {
                        controller.clearFilters();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.clear,
                              color: AppColors.primaryColor,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            CommonText(
                              text: AppString.clear_filter_text,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }),
              ],
            ),
            SizedBox(height: 14.h),
            Obx(() {
              if (controller.isLoadingProviders.value &&
                  controller.serviceProviders.isEmpty) {
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64.sp,
                          color: AppColors.black200,
                        ),
                        SizedBox(height: 16.h),
                        CommonText(
                          text: AppString.service_provider_found,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black600,
                        ),
                        SizedBox(height: 8.h),
                        CommonText(
                          text: AppString.adjusting_filter,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black300,
                        ),
                        SizedBox(height: 24.h),
                        GestureDetector(
                          onTap: () {
                            controller.clearFilters();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: AppColors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                CommonText(
                                  text: AppString.show_service_all,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh based on whether filters are active
                  if (controller.isFilterActive.value && controller.currentFilterUrl != null) {
                    // Refresh with current filters
                    await controller.fetchServiceProviders(filterUrl: controller.currentFilterUrl);
                  } else {
                    // Refresh all data without filters
                    await controller.fetchServiceProviders();
                  }
                },
                color: AppColors.primaryColor,
                child: GridView.builder(
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
                      id: provider.id,
                      name: provider.name,
                      service: provider.category,
                      distance:
                      "${provider.distance.toStringAsFixed(2)}km",
                      rating: provider.reviews.averageRating.toString(),
                      reviews: provider.reviews.totalReviews.toString(),
                      price: "RSD ${provider.price.toStringAsFixed(0)}",
                      imageUrl:
                      provider.image != null
                          ? ApiEndPoint.socketUrl + provider.image!
                          : "assets/images/item_image.png",
                      onTap: () => controller.onProviderTap(provider.id),
                      onFavorite: () => controller.favouriteItem(provider.id),
                    );
                  },
                ),
              );
            }),

          ],
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator(HomeController controller) {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          ),
        );
      }

      return const SizedBox.shrink();
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    ).then((filterData) {
      if (filterData != null) {
        Get.find<HomeController>().applyFiltersWithAPI(filterData);
      }
    });
  }
}