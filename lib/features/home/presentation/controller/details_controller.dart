import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';

class DetailsController extends GetxController {
  // Favorite list using provider IDs
  final RxList<String> favoriteIds = <String>[].obs;
  final RxList<ProviderModel> serviceProviders = <ProviderModel>[].obs;
  RxString category = "".obs;
  RxString id = "".obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = "".obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args != null) {
      id.value = args["id"] ?? "";
      category.value = args["name"] ?? "";

      if (id.value.isNotEmpty) {
        fetchFavorites(); // Fetch favorites first
        _loadServiceProviders();
      }
    }
  }

  // Fetch user's favorite list from API
  Future<void> fetchFavorites() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.favourite, // Your endpo num to get favorites
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Extract provider IDs from the providerIds array
        final List<dynamic> providerIds = response.data['data']['providerIds'] ?? [];

        // Map to get only the _id from each provider object
        favoriteIds.value = providerIds.map((item) => item.toString()).toList();

        update();
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  Future<void> _loadServiceProviders() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await ApiService.get(
        '${ApiEndPoint.provider}?categoryId=${id.value}&verified=true&isActive=true&isOnline=true',
        header: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final providersResponse = ProvidersResponse.fromJson(response.data);

        if (providersResponse.success) {
          serviceProviders.value = providersResponse.data;

          if (serviceProviders.isEmpty) {
            errorMessage.value = "No service providers found for this category";
          }
        } else {
          errorMessage.value = providersResponse.message;
        }
      } else {
        errorMessage.value = response.message ?? "Failed to load service providers";
      }
    } catch (e) {
      errorMessage.value = "An error occurred: ${e.toString()}";
      print("Error loading service providers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add/Remove favorite with API call
  Future<void> favouriteItem(String providerId) async {
    try {
      // Optimistically update UI
      final wasFavorite = favoriteIds.contains(providerId);
      if (wasFavorite) {
        favoriteIds.remove(providerId);
      } else {
        favoriteIds.add(providerId);
      }
      update();

      final response = await ApiService.post(
        ApiEndPoint.favourite, // Replace with correct favorite endpoint
        body: {
          "providerId": providerId,
        },
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
      } else {
        // Revert on failure
        if (wasFavorite) {
          favoriteIds.add(providerId);
        } else {
          favoriteIds.remove(providerId);
        }
        update();

        Get.snackbar(
          AppString.error,
          response.message ?? "Failed to update favorite",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      // Revert on error
      final wasFavorite = !favoriteIds.contains(providerId);
      if (wasFavorite) {
        favoriteIds.add(providerId);
      } else {
        favoriteIds.remove(providerId);
      }
      update();

      Get.snackbar(
        "Error",
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Check if a provider is favorite by matching provider ID with favorite list
  bool isFavorite(String providerId) {
    return favoriteIds.contains(providerId);
  }

  void onProviderTap(String id) {
    Get.to(() => const ServiceDetailsScreen(), arguments: id);
  }

  List<ProviderModel> get favoriteProviders {
    return serviceProviders
        .where((provider) => isFavorite(provider.id))
        .toList();
  }

  void onServiceCategoryTap(String categoryName) {
    serviceProviders.value = serviceProviders
        .where((provider) =>
    provider.category.toLowerCase().contains(categoryName.toLowerCase()) ||
        provider.subCategory.toLowerCase().contains(categoryName.toLowerCase()))
        .toList();
  }

  // Helper method to calculate distance
  String getDistance(ProviderModel provider) {
    return "${provider.distance.toStringAsFixed(2)}km";
  }

  // Retry loading providers
  void retryLoading() {
    if (id.value.isNotEmpty) {
      _loadServiceProviders();
    }
  }
}