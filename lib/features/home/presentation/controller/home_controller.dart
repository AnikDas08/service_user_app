import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/app_utils.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/data/profiles_model.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';
import 'home_nav_controller.dart';

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
  final RxInt totalPages = 1.obs;  // Changed from Rx num to RxDouble
  final RxInt totalProviders = 0.obs;
  final  num limit = 20;
  final RxBool hasMoreData = true.obs;
  final RxBool isFilterActive = false.obs;

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

  Future<void> countNotification()async{
    try{
      final response = await ApiService.get(
          "notifications/amount",
          header: {
            "Content-Type": "application/json",
          }
      );
      if(response.statusCode==200){
        updateCount(response.data['data']);

      }
    }
    catch(e){

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

  Future<void> countMessa()async{
    try{
      final response = await ApiService.get(
          "messages/get-unread-messages-amount",
          header: {
            "Content-Type": "application/json",
          }
      );
      if(response.statusCode==200){
        updateMessage(response.data['data']);
        Get.find<HomeNavController>().refresh();
      }
    }
    catch(e){

    }
  }

  void updateCount(int count) {
    notificationCount.value = count;
    print("data :$count");
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    if (query.isEmpty) {
      filteredProviders.value = serviceProviders;
    } else {
      filteredProviders.value = serviceProviders.where((provider) {
        // Search only by category and subcategory (removed name search)
        return provider.category.toLowerCase().contains(query) ||
            provider.subCategory.toLowerCase().contains(query);
      }).toList();
    }
  }

  // Fetch user's favorite list from API
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



  // Add/Remove favorite with API call
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
  Future<void> fetchServiceProviders({String? filterUrl, bool loadMore = false}) async {
    try {
      // Prevent multiple simultaneous requests
      if (loadMore && isLoadingMore.value) return;
      if (!loadMore && isLoadingProviders.value) return;

      // Check if there's more data to load
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

      // Add pagination parameters
      String separator = baseUrl.contains('?') ? '&' : '?';
      String url = baseUrl +
          "${separator}page=${currentPage.value}&limit=$limit";

      final response = await ApiService.get(
        url,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final providersResponse = ProvidersResponse.fromJson(response.data);

        if (providersResponse.success) {
          // Update pagination info
          // Update pagination info
          // Update pagination info
          if (response.data['pagination'] != null) {
            totalPages.value = (response.data['pagination']['totalPage'] ?? 1).toInt();
            totalProviders.value = (response.data['pagination']['total'] ?? 0).toInt();
            hasMoreData.value = currentPage.value < totalPages.value.toInt();
          }

          if (loadMore) {
            // Append new data
            //serviceProviders.addAll(providersResponse.data);
            //filteredProviders.addAll(providersResponse.data);
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



  // Load next page
  Future<void> loadMoreProviders() async {
    if (hasMoreData.value && !isLoadingMore.value) {
      currentPage.value++;
      await fetchServiceProviders(loadMore: true);
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
        name.value = response.data["data"]["name"]??"";
        image.value = response.data["data"]["image"]??"";
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
        ApiEndPoint.category+"?limit=20",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];

        categories.value = data.map((item) {
          return {
            "id": item['_id']??"",
            "name": item['name']??"",
            "icon": item['icon']??"assets/images/noImage.png",
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

  // Fetch subcategories for a specific category
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

  bool isFavorite(String providerId) {
    return favoriteIds.contains(providerId);
  }

  List<ProviderModel> get favoriteProviders {
    return serviceProviders.where((provider) => isFavorite(provider.id)).toList();
  }

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

  void onProviderTap(String id) {
    Get.to(() => const ServiceDetailsScreen(), arguments: id);
  }

  // New method to apply filters with API call
  Future<void> applyFiltersWithAPI(Map<String, dynamic> filterData) async {
    try {
      // Build query parameters
      List<String> queryParams = ["verified=true", "isActive=true", "isOnline=true"];

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

      // Build the complete URL
      String filterUrl = ApiEndPoint.provider + "?" + queryParams.join("&");
      print("Filter URL: $filterUrl");

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

  // Original applyFilters method (for local filtering if needed)
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

  Future<void> refreshData() async {
    currentPage.value = 1;
    hasMoreData.value = true;
    currentFilterUrl = null;
    await Future.wait([
      fetchCategories(),
      fetchServiceProviders(),
      fetchFavorites(),
    ]);
  }

  @override
  void onClose() {
    //searchController.dispose();
    super.onClose();
  }
}