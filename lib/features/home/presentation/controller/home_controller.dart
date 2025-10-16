import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();

  // Favorite list using provider IDs
  final RxList<String> favoriteIds = <String>[].obs;

  // Provider data from API
  final RxList<ProviderModel> serviceProviders = <ProviderModel>[].obs;
  final RxList<ProviderModel> filteredProviders = <ProviderModel>[].obs;
  final RxBool isLoadingProviders = false.obs;

  // Categories from API
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCategories = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories(); // Fetch categories first
    fetchServiceProviders(); // Fetch providers from API

    // Listen to search input
    searchController.addListener(_onSearchChanged);
  }

  // Search functionality
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

  // Fetch service providers from API
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

  // Fetch categories from API
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

  // Toggle favorite
  void toggleFavorite(String providerId) {
    if (favoriteIds.contains(providerId)) {
      favoriteIds.remove(providerId);
    } else {
      favoriteIds.add(providerId);
    }
    update();
  }

  // Check if a provider is favorite
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

    // Filter by category
    if (filterData['category'] != null) {
      final selectedCategory = filterData['category'] as String;
      filtered = filtered.where((provider) =>
      provider.category.toLowerCase() == selectedCategory.toLowerCase() ||
          provider.subCategory.toLowerCase() == selectedCategory.toLowerCase()).toList();
    }

    // Filter by location
    if (filterData['location'] != null) {
      final selectedLocation = filterData['location'] as String;
      // Assuming you have location field in ProviderModel
      // filtered = filtered.where((provider) =>
      //     provider.location.toLowerCase().contains(selectedLocation.toLowerCase())).toList();
    }

    // Filter by price range
    if (filterData['priceRange'] != null) {
      final maxPrice = filterData['priceRange'] as double;
      filtered = filtered.where((provider) =>
      provider.price <= maxPrice).toList();
    }

    // Filter by date (if you need date-based filtering in the future)
    if (filterData['date'] != null) {
      // Add date filtering logic if needed
    }

    // Filter by time (if you need time-based filtering in the future)
    if (filterData['time'] != null) {
      // Add time filtering logic if needed
    }

    filteredProviders.value = filtered;
    update();
  }

  // Refresh data
  Future<void> refreshData() async {
    await Future.wait([
      fetchCategories(),
      fetchServiceProviders(),
    ]);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}