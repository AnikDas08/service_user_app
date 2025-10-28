import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../profile/data/profiles_model.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  static final HomeController instance=HomeController();

  // Favorite list using provider IDs
  final RxList<String> favoriteIds = <String>[].obs;

  // Provider data from API
  final RxList<ProviderModel> serviceProviders = <ProviderModel>[].obs;
  final RxList<ProviderModel> filteredProviders = <ProviderModel>[].obs;
  final RxBool isLoadingProviders = false.obs;

  // Categories from API
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCategories = false.obs;
  final RxBool isProfileLoading = false.obs;
  var name = "".obs;
  var image = "".obs;
  ProfileData? profileData;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchServiceProviders();
    getProfile();
    fetchFavorites(); // Fetch favorites on init
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value = serviceProviders.where((provider) {
        return provider.name.toLowerCase().contains(query) ||
            provider.category.toLowerCase().contains(query) ||
            provider.subCategory.toLowerCase().contains(query);
      }).toList();
    }
  }

  // Fetch user's favorite list from API
  Future<void> fetchFavorites() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.favourite, // Your endpoint to get favorites
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
          "Error",
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

  Future<void> fetchServiceProviders() async {
    try {
      isLoadingProviders.value = true;

      final response = await ApiService.get(
        ApiEndPoint.provider,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final providersResponse = ProvidersResponse.fromJson(response.data);

        if (providersResponse.success) {
          serviceProviders.value = providersResponse.data;
          filteredProviders.value = providersResponse.data;
          update();
        } else {
          Get.snackbar(
            "Error",
            providersResponse.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to load providers",
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
      isLoadingProviders.value = false;
    }
  }

  Future<void> getProfile() async {
    update();
    try {
      final response = await ApiService.get(
          ApiEndPoint.user,
          header: {"Authorization": "Bearer ${LocalStorage.token}"}
      );
      if (response.statusCode == 200) {
        final profileModel = ProfileModel.fromJson(response.data);
        profileData = profileModel.data;
        name.value = response.data["data"]["name"];
        image.value = response.data["data"]["image"];
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      Utils.errorSnackBar(0, e.toString());
    }
    update();
  }

  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      final response = await ApiService.get(
        ApiEndPoint.category,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        categories.value = data.map((item) {
          return {
            "id": item['_id'],
            "name": item['name'],
            "icon": item['icon'],
          };
        }).toList();

        update();
      } else {
        Get.snackbar(
          "Error",
          response.message ?? "Failed to load categories",
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
      isLoadingCategories.value = false;
    }
  }

  // Check if a provider is favorite by matching provider ID with favorite list
  bool isFavorite(String providerId) {
    return favoriteIds.contains(providerId);
  }

  // Get all favorite providers
  List<ProviderModel> get favoriteProviders {
    return serviceProviders.where((provider) => isFavorite(provider.id)).toList();
  }

  // Filter by category
  void onServiceCategoryTap(String category) {
    if (category == "All") {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value = serviceProviders
          .where((provider) =>
      provider.category.toLowerCase().contains(category.toLowerCase()) ||
          provider.subCategory.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
  }

  // Navigate to provider details
  void onProviderTap(String id) {
    Get.to(() => const ServiceDetailsScreen(), arguments: id);
  }

  // Apply filters from bottom sheet
  void applyFilters(Map<String, dynamic> filterData) {
    List<ProviderModel> filtered = List.from(serviceProviders);

    if (filterData['category'] != null) {
      final selectedCategory = filterData['category'] as String;
      filtered = filtered
          .where((provider) =>
      provider.category.toLowerCase() == selectedCategory.toLowerCase() ||
          provider.subCategory.toLowerCase() == selectedCategory.toLowerCase())
          .toList();
    }

    if (filterData['location'] != null) {
      final selectedLocation = filterData['location'] as String;
    }

    if (filterData['priceRange'] != null) {
      final maxPrice = filterData['priceRange'] as double;
      filtered = filtered.where((provider) => provider.price <= maxPrice).toList();
    }

    if (filterData['date'] != null) {
    }

    if (filterData['time'] != null) {
    }

    filteredProviders.value = filtered;
    update();
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([
      fetchCategories(),
      fetchServiceProviders(),
      fetchFavorites(),
    ]);
  }

  @override
  void onClose() {
    super.onClose();
  }
}