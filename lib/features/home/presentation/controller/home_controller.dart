import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../screen/service_details_screen.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Sample data - replace with actual API calls
  RxList<Map<String, dynamic>> serviceProviders = <Map<String, dynamic>>[].obs;
  RxList<Map<String, dynamic>> filteredProviders = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadServiceProviders();
  }

  void _loadServiceProviders() {
    // Sample data - replace with actual API call
    serviceProviders.value = [
      {
        "name": "Angle Mariomi",
        "service": "Haircut",
        "distance": "2km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "https://via.placeholder.com/150x120",
      },
      {
        "name": "Angle Priya",
        "service": "Nail Caring",
        "distance": "5km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "https://via.placeholder.com/150x120",
      },
      {
        "name": "Samim Akter",
        "service": "Massage",
        "distance": "4km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "https://via.placeholder.com/150x120",
      },
      {
        "name": "Sohidul Hasan",
        "service": "Skin Caring",
        "distance": "6km",
        "rating": "4.5",
        "reviews": "200",
        "price": "RSD 2500",
        "image": "https://via.placeholder.com/150x120",
      },
    ];
    filteredProviders.value = serviceProviders;
  }

  void searchProviders(String query) {
    if (query.isEmpty) {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value =
          serviceProviders
              .where(
                (provider) =>
                    provider["name"]!.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    provider["service"]!.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    }
  }

  void onServiceCategoryTap(String category) {
    // Filter by category
    if (category == "All") {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value =
          serviceProviders
              .where(
                (provider) => provider["service"]!.toLowerCase().contains(
                  category.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void onProviderTap(Map<String, dynamic> provider) {
    // Navigate to provider details
    Get.to(() => const ServiceDetailsScreen(), arguments: provider);
  }

  void onFavoriteTap(Map<String, dynamic> provider) {
    // Handle favorite toggle
    // Implement favorite functionality
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
