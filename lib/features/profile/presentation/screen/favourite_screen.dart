import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
        child: SafeArea(
          child: Column(
            children: [
              CustomAppBar(title: AppString.favourite_list,),
              SizedBox(height: 20,),
              _buildServiceProviders(),

            ],
          ),
        ),
      ),
    );
  }
  Widget _buildServiceProviders() {
    return GetBuilder<FavouriteController>(
      builder: (controller) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                final providers = controller.serviceProviders;

                if (providers.isEmpty) {
                  return Center(
                    child: CommonText(
                      text: "No Favourite providers found",
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
                    return FavouriteList(
                      name: provider["name"]!,
                      service: provider["service"]!,
                      distance: provider["distance"]!,
                      rating: provider["rating"]!,
                      reviews: provider["reviews"]!,
                      price: provider["price"]!,
                      imageUrl: provider["image"]!,
                      onTap: () => controller.onProviderTap(provider),
                    );
                  },
                );
              }),
            ]
        );
      },
    );
  }
}
