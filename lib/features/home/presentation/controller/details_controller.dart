import 'package:get/get.dart';

import '../screen/service_details_screen.dart';

class DetailsController extends GetxController {
  final RxList<String> favoriteNames = <String>[].obs;
  final RxList<Map<String, dynamic>> serviceProviders = <Map<String, dynamic>>[].obs;
  RxString category="".obs;


  @override
  void onInit() {
    super.onInit();

    final arg = Get.arguments;
    if (arg != null && arg is String) {
      category.value = arg;
    } else {
      category.value = "";
    }
    _loadServiceProviders();
  }

  void _loadServiceProviders() {
    // Sample data
    serviceProviders.value = [
      {
        "name": "Angle Mariomi",
        "service": category.value,
        "distance": "2km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Angle Priya",
        "service": category.value,
        "distance": "5km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Samim Akter",
        "service": category.value,
        "distance": "4km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
      {
        "name": "Sohidul Hasan",
        "service": category.value,
        "distance": "6km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "assets/images/item_image.png",
      },
    ];
  }

  void toggleFavorite(String providerName) {
    if (favoriteNames.contains(providerName)) {
      favoriteNames.remove(providerName);
    } else {
      favoriteNames.add(providerName);
    }
    update();
  }

  bool isFavorite(String providerName) {
    return favoriteNames.contains(providerName);
  }
  void onProviderTap(Map<String, dynamic> provider) {
    Get.to(() => const ServiceDetailsScreen(), arguments: provider);
  }
  List<Map<String, dynamic>> get favoriteProviders {
    return serviceProviders.where((provider) => isFavorite(provider["name"]!)).toList();
  }

  void onServiceCategoryTap(String category) {
      serviceProviders.value = serviceProviders
          .where((provider) => provider["service"]!.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
}