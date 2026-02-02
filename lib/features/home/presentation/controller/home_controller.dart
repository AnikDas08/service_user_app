import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:http/http.dart' as http;
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/data/profiles_model.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';
import 'home_nav_controller.dart';

/// -------------------------------
/// Location Model
/// -------------------------------
class LocationModel {
  final String placeId;
  final String displayName;
  final String lat;
  final String lon;

  // Address fields (OSM)
  final String houseNumber;
  final String road;
  final String neighbourhood;
  final String suburb;
  final String city;
  final String town;
  final String village;
  final String county;
  final String state;
  final String postcode;
  final String country;
  final String countryCode;

  // Computed fields
  final String shortName;
  final String searchableName;
  final String fullAddress;

  LocationModel({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.houseNumber,
    required this.road,
    required this.neighbourhood,
    required this.suburb,
    required this.city,
    required this.town,
    required this.village,
    required this.county,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
    required this.shortName,
    required this.searchableName,
    required this.fullAddress,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    String getValue(String key) =>
        address[key]?.toString() ?? '';

    /// -------- Short Name (Most specific) --------
    String shortName =
    getValue('neighbourhood').isNotEmpty
        ? getValue('neighbourhood')
        : getValue('suburb').isNotEmpty
        ? getValue('suburb')
        : getValue('road').isNotEmpty
        ? getValue('road')
        : getValue('city').isNotEmpty
        ? getValue('city')
        : getValue('town').isNotEmpty
        ? getValue('town')
        : getValue('village').isNotEmpty
        ? getValue('village')
        : getValue('state');

    /// -------- Searchable Name --------
    List<String> searchParts = [];
    if (getValue('neighbourhood').isNotEmpty) {
      searchParts.add(getValue('neighbourhood'));
    }
    if (getValue('road').isNotEmpty) {
      searchParts.add(getValue('road'));
    }
    if (getValue('city').isNotEmpty) {
      searchParts.add(getValue('city'));
    } else if (getValue('town').isNotEmpty) {
      searchParts.add(getValue('town'));
    }

    String searchableName = searchParts.isNotEmpty
        ? searchParts.join(', ')
        : json['display_name'];

    /// -------- Full Address (Manual structured) --------
    List<String> fullParts = [
      getValue('house_number'),
      getValue('road'),
      getValue('neighbourhood'),
      getValue('suburb'),
      getValue('city'),
      getValue('town'),
      getValue('village'),
      getValue('county'),
      getValue('state'),
      getValue('postcode'),
      getValue('country'),
    ].where((e) => e.isNotEmpty).toList();

    String fullAddress = fullParts.join(', ');

    return LocationModel(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',

      houseNumber: getValue('house_number'),
      road: getValue('road'),
      neighbourhood: getValue('neighbourhood'),
      suburb: getValue('suburb'),
      city: getValue('city'),
      town: getValue('town'),
      village: getValue('village'),
      county: getValue('county'),
      state: getValue('state'),
      postcode: getValue('postcode'),
      country: getValue('country'),
      countryCode: getValue('country_code'),

      shortName: shortName,
      searchableName: searchableName,
      fullAddress: fullAddress,
    );
  }
}

/// -------------------------------
/// Home Controller
/// -------------------------------
class HomeController extends GetxController {
  TextEditingController searchController = TextEditingController();
  static final HomeController instance = HomeController();
  RxInt notificationCount = 0.obs;
  RxInt message = 0.obs;

  // Favorite list using provider IDs
  final RxList<String> favoriteIds = <String>[].obs;

  // Provider data from API
  final RxList<ProviderModel> serviceProviders = <ProviderModel>[].obs;
  final RxList<ProviderModel> filteredProviders = <ProviderModel>[].obs;
  final RxBool isLoadingProviders = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalProviders = 0.obs;
  final num limit = 20;
  final RxBool hasMoreData = true.obs;
  final RxBool isFilterActive = false.obs;

  // Search state
  final RxBool isSearching = false.obs;

  // Categories from API
  final RxList<Map<String, dynamic>> categories = <Map<String, dynamic>>[].obs;
  final RxBool isLoadingCategories = false.obs;

  // Subcategories from API
  final RxMap<String, List<Map<String, dynamic>>> subCategoriesMap =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxMap<String, bool> isLoadingSubCategories = <String, bool>{}.obs;

  final RxBool isProfileLoading = false.obs;
  var name = "".obs;
  var image = "".obs;
  ProfileData? profileData;

  // Store current filter URL for pagination
  String? currentFilterUrl;

  // Location properties
  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;
  String? latitude;
  String? longitude;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchServiceProviders();
    getProfile();
    fetchFavorites();
    countNotification();
    countMessa();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  Future<void> countNotification() async {
    try {
      final response = await ApiService.get(
        "notifications/amount",
        header: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        updateCount(response.data['data']);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearFilters() async {
    try {
      // Reset filter URL
      currentFilterUrl = null;

      // Reset pagination
      currentPage.value = 1;
      hasMoreData.value = true;

      // Clear search
      searchController.clear();

      // Clear location data
      latitude = null;
      longitude = null;
      locationSuggestions.clear();

      // Mark filter as inactive
      isFilterActive.value = false;

      // Fetch all providers without filters
      await fetchServiceProviders();

      Get.snackbar(
        AppString.filter_clear_text,
        AppString.show_service_all,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.primaryColor,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "Failed to clear filters: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void updateMessage(int count) {
    message.value = count;
    print("values :$message");
  }

  Future<void> countMessa() async {
    try {
      final response = await ApiService.get(
        "messages/get-unread-messages-amount",
        header: {
          "Content-Type": "application/json",
        },
      );
      if (response.statusCode == 200) {
        updateMessage(response.data['data']);
        Get.find<HomeNavController>().refresh();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void updateCount(int count) {
    notificationCount.value = count;
    print("data :$count");
  }

  /// -------------------------------
  /// SEARCH FUNCTIONALITY
  /// -------------------------------
  void _onSearchChanged() {
    final query = searchController.text.trim();

    // Cancel previous search timer
    _debounce?.cancel();

    if (query.isEmpty) {
      // If search is empty, reset to show all providers or current filter
      if (currentFilterUrl != null) {
        fetchServiceProviders(filterUrl: currentFilterUrl);
      } else {
        fetchServiceProviders();
      }
    } else {
      // Show searching indicator
      isSearching.value = true;

      // Set a 1-second delay before making the API call
      _debounce = Timer(const Duration(seconds: 1), () {
        _performSearch(query);
      });
    }
  }

  Future<void> _performSearch(String query) async {
    try {
      isLoadingProviders.value = true;
      isSearching.value = false;

      // Build search URL
      String searchUrl;
      if (currentFilterUrl != null) {
        // If there's an active filter, append search to it
        String separator = currentFilterUrl!.contains('?') ? '&' : '?';
        searchUrl = currentFilterUrl! + "${separator}searchTerm=$query";
      } else {
        // Otherwise, create a new search URL
        searchUrl = ApiEndPoint.provider + "?verified=true&isActive=true&isOnline=true&searchTerm=$query";
      }

      print("Search URL: $searchUrl");

      final response = await ApiService.get(
        searchUrl,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final providersResponse = ProvidersResponse.fromJson(response.data);

        if (providersResponse.success) {
          if (response.data['pagination'] != null) {
            totalPages.value = (response.data['pagination']['totalPage'] ?? 1).toInt();
            totalProviders.value = (response.data['pagination']['total'] ?? 0).toInt();
            hasMoreData.value = false; // Disable load more for search results
          }

          serviceProviders.value = providersResponse.data;
          filteredProviders.value = providersResponse.data;

          update();
        } else {
          Get.snackbar(
            AppString.error,
            providersResponse.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? "Failed to search providers",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "Search error: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProviders.value = false;
      isSearching.value = false;
    }
  }

  /// -------------------------------
  /// LOCATION AUTOCOMPLETE
  /// -------------------------------
  void onLocationChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchLocation(value);
    });
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      locationSuggestions.clear();
      update();
      return;
    }

    isLocationLoading = true;
    update();

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5',
      );

      final response = await http.get(
        url,
        headers: {
          "User-Agent": "HaircutMenApp",
        },
      );

      if (response.statusCode == 200) {
        debugPrint("RAW LOCATION RESPONSE 👉 ${response.body}");

        final List data = jsonDecode(response.body);

        debugPrint("PARSED LIST LENGTH 👉 ${data.length}");

        locationSuggestions = data.map((e) => LocationModel.fromJson(e)).toList();
      } else {
        locationSuggestions.clear();
      }
    } catch (e) {
      debugPrint("Location search error: $e");
      locationSuggestions.clear();
    }

    isLocationLoading = false;
    update();
  }

  void selectLocation(LocationModel location) {
    latitude = location.lat;
    longitude = location.lon;
    locationSuggestions.clear();
    update();
  }

  void clearLocationSuggestions() {
    locationSuggestions.clear();
    update();
  }

  /// -------------------------------
  /// FAVORITES
  /// -------------------------------
  Future<void> fetchFavorites() async {
    try {
      final response = await ApiService.get(
        ApiEndPoint.favourite,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> providerIds = response.data['data']['providerIds'] ?? [];
        favoriteIds.value = providerIds.map((item) => item.toString()).toList();
        update();
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
  }

  Future<void> favouriteItem(String providerId) async {
    try {
      final wasFavorite = favoriteIds.contains(providerId);
      if (wasFavorite) {
        favoriteIds.remove(providerId);
      } else {
        favoriteIds.add(providerId);
      }
      update();

      final response = await ApiService.post(
        ApiEndPoint.favourite,
        body: {
          "providerId": providerId,
        },
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        // Success
      } else {
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
      final wasFavorite = !favoriteIds.contains(providerId);
      if (wasFavorite) {
        favoriteIds.add(providerId);
      } else {
        favoriteIds.remove(providerId);
      }
      update();

      Get.snackbar(
        AppString.error,
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool isFavorite(String providerId) {
    return favoriteIds.contains(providerId);
  }

  List<ProviderModel> get favoriteProviders {
    return serviceProviders.where((provider) => isFavorite(provider.id)).toList();
  }

  /// -------------------------------
  /// SERVICE PROVIDERS
  /// -------------------------------
  Future<void> fetchServiceProviders({String? filterUrl, bool loadMore = false}) async {
    try {
      if (loadMore && isLoadingMore.value) return;
      if (!loadMore && isLoadingProviders.value) return;

      if (loadMore && !hasMoreData.value) return;

      if (loadMore) {
        isLoadingMore.value = true;
      } else {
        isLoadingProviders.value = true;
        currentPage.value = 1;
        serviceProviders.clear();
      }

      // Store filter URL for pagination
      if (filterUrl != null) {
        currentFilterUrl = filterUrl;
      }

      // Build URL with pagination
      String baseUrl = currentFilterUrl ??
          (ApiEndPoint.provider + "?verified=true&isActive=true&isOnline=true");

      String separator = baseUrl.contains('?') ? '&' : '?';
      String url = baseUrl + "${separator}page=${currentPage.value}&limit=$limit";

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final providersResponse = ProvidersResponse.fromJson(response.data);

        if (providersResponse.success) {
          if (response.data['pagination'] != null) {
            totalPages.value = (response.data['pagination']['totalPage'] ?? 1).toInt();
            totalProviders.value = (response.data['pagination']['total'] ?? 0).toInt();
            hasMoreData.value = currentPage.value < totalPages.value.toInt();
          }

          if (loadMore) {
            // Append new data
            serviceProviders.addAll(providersResponse.data);
            filteredProviders.addAll(providersResponse.data);
          } else {
            // Replace data
            serviceProviders.value = providersResponse.data;
            filteredProviders.value = providersResponse.data;
          }

          update();
        } else {
          Get.snackbar(
            AppString.error,
            providersResponse.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? "Failed to load providers",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (loadMore) {
        isLoadingMore.value = false;
      } else {
        isLoadingProviders.value = false;
      }
    }
  }

  Future<void> loadMoreProviders() async {
    if (hasMoreData.value && !isLoadingMore.value) {
      currentPage.value++;
      await fetchServiceProviders(loadMore: true);
    }
  }

  /// -------------------------------
  /// PROFILE
  /// -------------------------------
  Future<void> getProfile() async {
    update();
    try {
      final response = await ApiService.get(
        ApiEndPoint.user,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );
      if (response.statusCode == 200) {
        final profileModel = ProfileModel.fromJson(response.data);
        profileData = profileModel.data;
        name.value = response.data["data"]["name"] ?? "";
        image.value = response.data["data"]["image"] ?? "";
      } else {
        Utils.errorSnackBar(response.statusCode, response.message);
      }
    } catch (e) {
      Utils.errorSnackBar(0, e.toString());
    }
    update();
  }

  /// -------------------------------
  /// CATEGORIES
  /// -------------------------------
  Future<void> fetchCategories() async {
    try {
      isLoadingCategories.value = true;

      final response = await ApiService.get(
        ApiEndPoint.category + "?limit=20",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        categories.value = data.map((item) {
          return {
            "id": item['_id'] ?? "",
            "name": item['name'] ?? "",
            "icon": item['icon'] ?? "assets/images/noImage.png",
          };
        }).toList();

        update();
      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? "Failed to load categories",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "An error occurred: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingCategories.value = false;
    }
  }

  /// -------------------------------
  /// SUBCATEGORIES
  /// -------------------------------
  Future<void> fetchSubCategories(String categoryId) async {
    try {
      isLoadingSubCategories[categoryId] = true;
      isLoadingSubCategories.refresh();

      print("Fetching subcategories for category: $categoryId");

      final response = await ApiService.get(
        "${ApiEndPoint.subCatrgory}?category=$categoryId",
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      print("Subcategory response status: ${response.statusCode}");
      print("Subcategory response data: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          subCategoriesMap[categoryId] = List<Map<String, dynamic>>.from(
            data['data'],
          );
          subCategoriesMap.refresh();
          print(
            "Subcategories loaded: ${subCategoriesMap[categoryId]?.length ?? 0}",
          );
        } else {
          print("No subcategories found for category: $categoryId");
          subCategoriesMap[categoryId] = [];
          subCategoriesMap.refresh();
        }
      } else {
        print("Failed to fetch subcategories. Status: ${response.statusCode}");
        Get.snackbar("Error", "Failed to load subcategories");
      }
    } catch (e) {
      print("Error fetching subcategories: $e");
      Get.snackbar("Error", "Failed to load subcategories: $e");
      subCategoriesMap[categoryId] = [];
      subCategoriesMap.refresh();
    } finally {
      isLoadingSubCategories[categoryId] = false;
      isLoadingSubCategories.refresh();
    }
  }

  /// -------------------------------
  /// FILTERING
  /// -------------------------------
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

  Future<void> applyFiltersWithAPI(Map<String, dynamic> filterData) async {
    try {
      //List<String> queryParams = ["verified=true", "isActive=true", "isOnline=true"];
      List<String> queryParams = [];

      if (filterData['categoryId'] != null && filterData['categoryId'].toString().isNotEmpty) {
        queryParams.add("categoryId=${filterData['categoryId']}");
      }

      if (filterData['subCategoryId'] != null && filterData['subCategoryId'].toString().isNotEmpty) {
        queryParams.add("subCategoryId=${filterData['subCategoryId']}");
      }

      if (filterData['minPrice'] != null && filterData['minPrice'].toString().isNotEmpty) {
        queryParams.add("minPrice=${filterData['minPrice']}");
      }

      if (filterData['maxPrice'] != null && filterData['maxPrice'].toString().isNotEmpty) {
        queryParams.add("maxPrice=${filterData['maxPrice']}");
      }

      if (filterData['date'] != null && filterData['date'].toString().isNotEmpty) {
        queryParams.add("date=${filterData['date']}");
      }

      if (filterData['time'] != null && filterData['time'].toString().isNotEmpty) {
        queryParams.add("time=${filterData['time']}");
      }

      if (filterData['location'] != null && filterData['location'].toString().isNotEmpty) {
        queryParams.add("location=${filterData['location']}");
      }

      if (filterData['userLat'] != null && filterData['userLat'].toString().isNotEmpty) {
        queryParams.add("userLat=${filterData['userLat']}");
      }

      if (filterData['userLng'] != null && filterData['userLng'].toString().isNotEmpty) {
        queryParams.add("userLng=${filterData['userLng']}");
      }

      String filterUrl = ApiEndPoint.provider + "?" + queryParams.join("&");
      print("Filter URL: $filterUrl");

      // Mark filter as active
      isFilterActive.value = true;

      // Reset pagination and fetch with new filters
      currentPage.value = 1;
      hasMoreData.value = true;
      await fetchServiceProviders(filterUrl: filterUrl);
    } catch (e) {
      Get.snackbar(
        AppString.error,
        "Failed to apply filters: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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

    if (filterData['priceRange'] != null) {
      final maxPrice = filterData['priceRange'] as double;
      filtered = filtered.where((provider) => provider.price <= maxPrice).toList();
    }

    filteredProviders.value = filtered;
    update();
  }

  /// -------------------------------
  /// NAVIGATION
  /// -------------------------------
  void onProviderTap(String id) {
    Get.to(() => const ServiceDetailsScreen(), arguments: id);
  }

  /// -------------------------------
  /// REFRESH
  /// -------------------------------
  Future<void> refreshData() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    currentFilterUrl = null;
    latitude = null;
    longitude = null;
    locationSuggestions.clear();
    searchController.clear();
    await Future.wait([
      fetchCategories(),
      fetchServiceProviders(),
      fetchFavorites(),
    ]);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    super.onClose();
  }
}