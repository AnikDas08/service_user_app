import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/details_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/widgets/service_provider_category.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';


class DetailsCategoryScreen extends StatelessWidget {
  const DetailsCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 20,right: 20),
        child: SafeArea(
      child: GetBuilder<DetailsController>(
      init: DetailsController(),
      builder: (controller) => Column(
        children: [
          Obx(() => CustomAppBar(title: controller.category.value)),
          SizedBox(height: 20.h),
          Obx(() {
            final providers = controller.serviceProviders;
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
                return ServiceProviderCategory(
                  name: provider["name"]!,
                  service: provider["service"],
                  distance: provider["distance"]!,
                  rating: provider["rating"]!,
                  reviews: provider["reviews"]!,
                  price: provider["price"]!,
                  imageUrl: provider["image"]!,
                  onTap: ()=>controller.onProviderTap(provider),
                  onFavorite: () => controller.toggleFavorite(provider["name"]),
                );
              },
            );
          }),
        ],
      ),
            ),
          ),

          ),
    );
  }
}
