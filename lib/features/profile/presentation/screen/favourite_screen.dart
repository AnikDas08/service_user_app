import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/favourite_controller.dart';
import 'package:haircutmen_user_app/features/profile/presentation/widgets/favourite_list.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: CustomAppBar(
                title: AppString.favourite_list,
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: GetBuilder<FavouriteController>(
                init: FavouriteController(),
                builder: (controller) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshData,
                    color: AppColors.primaryColor,
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ),
                        );
                      }
                      if (controller.serviceProviders.isEmpty) {
                        return Center(
                          child: CommonText(
                            text: AppString.favourite_item,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black600,
                          ),
                        );
                      }

                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.h,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: controller.serviceProviders.length,
                          itemBuilder: (context, index) {
                            final provider = controller.serviceProviders[index];

                            return FavouriteList(
                              id: provider['id'],
                              name: provider['name'],
                              service: provider['category'],
                              distance: "${provider['serviceDistance']}km",
                              // Using the formatted 2-decimal rating from the map
                              rating: provider['reviews']['averageRating'].toString(),
                              // Using the total reviews count from the map
                              reviews: provider['reviews']['totalReviews'].toString(),
                              price: "RSD ${provider['price'].toStringAsFixed(0)}",
                              imageUrl: provider['image'] != null
                                  ? ApiEndPoint.socketUrl + provider['image']
                                  : "assets/images/item_image.png",
                              onTap: () => controller.onProviderTap(provider['id']),
                              onFavorite: () => controller.toggleFavourite(provider['id']),
                            );
                          },
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}