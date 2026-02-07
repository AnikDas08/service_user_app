import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_controller.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import '../../../../services/api/api_service.dart';
import '../../../home/presentation/screen/service_details_screen.dart';

class FavouriteController extends GetxController {
  final RxList<Map<String, dynamic>> serviceProviders = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFavouriteProviders();
  }

  // Fetch favourite providers from API
  Future<void> fetchFavouriteProviders() async {
    try {
      isLoading.value = true;

      final response = await ApiService.get(
        'fav-list/fav-list-with-details', // Your API endpoint
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        // Store raw data from API
        // Store raw data from API
        serviceProviders.value = data.map((item) {
          return {
            "id": item['_id'],
            "name": item['name'],
            "image": item['image'],
            "category": item['category'],
            "subCategory": item['subCategory'],
            "price": (item['price'] ?? 0).toDouble(),

            // Fix 1: Ensure distance is handled as a number before formatting
            "serviceDistance": (item['distance'] ?? 0.0).toDouble().toStringAsFixed(2),

            "primaryLocation": item['primaryLocation'],
            "pricePerHour": (item['pricePerHour'] ?? 0).toDouble(),
            "isActive": item['isActive'] ?? false,
            "isOnline": item['isOnline'] ?? false,
            "location": {
              "type": item['location']?['type'],
              "coordinates": item['location']?['coordinates'],
            },
            "reviews": {
              "_id": item['reviews']?['_id'],

              // Fix 2: Cast to num? and use a numeric default (0.0) instead of a string ("0.0")
              "averageRating": (item['reviews']?['averageRating'] as num? ?? 0.0).toStringAsFixed(2),

              "totalReviews": item['reviews']?['totalReviews'] ?? 0,
            },
          };
        }).toList();

        update();
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to load favourites",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Toggle favourite (Add/Remove)
  Future<void> toggleFavourite(String providerId) async {
    try {
      final response = await ApiService.post(
        ApiEndPoint.favourite, // Add this endpoint
        body: {
          "providerId": providerId,
        },
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        Get.find<HomeController>().fetchServiceProviders();
        Get.find<HomeController>().fetchFavorites();
        serviceProviders.removeWhere((provider) => provider['id'] == providerId);
        update();
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to update favourite",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Check if provider is favourite (always true in this screen)
  bool isFavorite(String providerId) {
    return serviceProviders.any((provider) => provider['id'] == providerId);
  }

  // Navigate to provider details
  void onProviderTap(String providerId) {
    Get.to(() => const ServiceDetailsScreen(), arguments: providerId);
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchFavouriteProviders();
  }
}