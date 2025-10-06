import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/service_details_screen.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Simple favorite list using provider names as identifiers
  final RxList<String> favoriteNames = <String>[].obs;

  // Sample data
  final RxList<Map<String, dynamic>> serviceProviders = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredProviders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadServiceProviders();
  }

  // Simple favorite toggle
  void toggleFavorite(String providerName) {
    if (favoriteNames.contains(providerName)) {
      favoriteNames.remove(providerName);
    } else {
      favoriteNames.add(providerName);
    }
    update();
  }

  // Check if a provider is favorite
  bool isFavorite(String providerName) {
    return favoriteNames.contains(providerName);
  }

  // Get all favorite providers
  List<Map<String, dynamic>> get favoriteProviders {
    return serviceProviders.where((provider) => isFavorite(provider["name"]!)).toList();
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
    filteredProviders.value = serviceProviders;
  }

  /*void searchProviders(String query) {
    if (query.isEmpty) {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value = serviceProviders
          .where((provider) =>
      provider["name"]!.toLowerCase().contains(query.toLowerCase()) ||
          provider["service"]!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }*/

  void onServiceCategoryTap(String category) {
    if (category == "All") {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value = serviceProviders
          .where((provider) => provider["service"]!.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
  }

  void onProviderTap(Map<String, dynamic> provider) {
    Get.to(() => const ServiceDetailsScreen(), arguments: provider);
  }

  /*void onFavoriteTap(Map<String, dynamic> provider) {
    toggleFavorite(provider["name"]!);
  }*/

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}