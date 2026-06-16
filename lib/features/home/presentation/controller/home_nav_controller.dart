import 'package:get/get.dart';
import '../../../../config/route/app_routes.dart';

class HomeNavController extends GetxController {
  int selectedIndex = 0;

  @override
  void onReady() {
    super.onReady();
    // Check if there's a pending deep link ID passed as an argument
    // Use Get.arguments directly
    final dynamic args = Get.arguments;
    if (args != null && args is Map && args['deepLinkProviderId'] != null) {
      String id = args['deepLinkProviderId'];
      // Navigate to details screen now that Home is fully ready
      Get.toNamed(AppRoutes.service_details, parameters: {'id': id});
    }
  }

  void changeIndex(int index) {
    selectedIndex = index;
    update();
  }

  void refreshIndex() {
    update();
  }
}
