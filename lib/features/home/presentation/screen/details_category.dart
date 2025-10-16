import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/details_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/widgets/service_provider_category.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';

class DetailsCategoryScreen extends StatelessWidget {
  const DetailsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: SafeArea(
          child: GetBuilder<DetailsController>(
            init: DetailsController(),
            builder: (controller) => Column(
              children: [
                Obx(() => CustomAppBar(title: controller.category.value)),
                SizedBox(height: 20.h),
                Expanded(
                  child: Obx(() {
                    // Show loading indicator
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    // Show error message with retry button
                    if (controller.errorMessage.value.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 60.w,
                              color: Colors.red,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            ElevatedButton.icon(
                              onPressed: controller.retryLoading,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show empty state
                    if (controller.serviceProviders.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 60.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'No service providers found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Show providers grid
                    final providers = controller.serviceProviders;
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        return ServiceProviderCategory(
                          name: provider.name,
                          service: provider.category.isNotEmpty
                              ? provider.category
                              : provider.subCategory,
                          distance: controller.getDistance(provider),
                          rating: "4.5", // Update when rating is available from API
                          reviews: "200", // Update when reviews are available from API
                          price: "RSD ${provider.price.toStringAsFixed(0)}",
                          imageUrl: provider.image != null
                              ? ApiEndPoint.socketUrl + provider.image!
                              : "assets/images/item_image.png",
                          onTap: () => controller.onProviderTap(provider.id),
                          onFavorite: () => controller.toggleFavorite(provider.id),
                          //isFavorite: controller.isFavorite(provider.id),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}