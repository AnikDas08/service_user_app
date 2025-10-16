import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/providers_model.dart';
import '../screen/service_details_screen.dart';

class DetailsController extends GetxController {
  final RxList<String> favoriteNames = <String>[].obs;
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
        _loadServiceProviders();
      }
    }
  }

  Future<void> _loadServiceProviders() async {
    try {
      isLoading.value = true;
      errorMessage.value = "";

      final response = await ApiService.get(
        '${ApiEndPoint.provider}?categoryId=${id.value}',
        header: {
          'Content-Type': 'application/json',
          // Add authorization token if needed
          // 'Authorization': 'Bearer ${your_token}',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
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

  void toggleFavorite(String providerId) {
    if (favoriteNames.contains(providerId)) {
      favoriteNames.remove(providerId);
    } else {
      favoriteNames.add(providerId);
    }
    update();
  }

  bool isFavorite(String providerId) {
    return favoriteNames.contains(providerId);
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

  // Helper method to calculate distance (you may need to implement actual distance calculation)
  String getDistance(ProviderModel provider) {
    // Implement distance calculation based on user's location and provider's location
    // For now, returning service distance
    return "${provider.serviceDistance}km";
  }

  // Retry loading providers
  void retryLoading() {
    if (id.value.isNotEmpty) {
      _loadServiceProviders();
    }
  }
}