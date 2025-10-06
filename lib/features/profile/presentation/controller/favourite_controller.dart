import 'package:get/get.dart';

import '../../../home/presentation/screen/service_details_screen.dart';

class FavouriteController extends GetxController{
  final RxList<Map<String, dynamic>> serviceProviders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadServiceProviders();
  }

  void _loadServiceProviders() {
    // Sample data
    serviceProviders.value = [
      {
        "name": "Angle Mariomi",
        "service": "Haircut",
        "distance": "2km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Angle Priya",
        "service": "Nail Caring",
        "distance": "5km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Samim Akter",
        "service": "Massage",
        "distance": "4km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Sohidul Hasan",
        "service": "Skin Caring",
        "distance": "6km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
    ];
  }

  void onServiceCategoryTap(String category) {

      serviceProviders.value = serviceProviders
          .where((provider) => provider["service"]!.toLowerCase().contains(category.toLowerCase()))
          .toList();
    //}
  }
  void onProviderTap(Map<String, dynamic> provider) {
    Get.to(() => const ServiceDetailsScreen(), arguments: provider);
  }
}