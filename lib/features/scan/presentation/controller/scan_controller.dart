import 'package:get/get.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/log/app_log.dart';

class ScanController extends GetxController {
  // Add scan controller logic here

  @override
  void onInit() {
    super.onInit();
    // Initialize controller
    appLog(
      "User Data===================>>>>>>>>>>>>>>>>" + LocalStorage.userId,
    );
  }
}
