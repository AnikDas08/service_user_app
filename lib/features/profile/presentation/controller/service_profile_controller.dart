import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Controller for managing service profile state
class ServiceProfileController extends GetxController {
  final RxString serviceName = 'My Service'.obs;
  final RxString aboutMe = '''With 10 Years Of Experience In The Hair Styling Industry, I'm Passionate About Making My Clients Feel Their Best Every Time! Whether You're Looking For A Fresh Cut, A Bold New Look, Or Expert Styling Advice, I Provide Top-Notch Service With A Focus On Making Each Client Feel Confident And Unique.'''.obs;
  final RxString serviceType = 'Hair'.obs;
  final RxString price = 'RSD 2500'.obs;

  final RxList<String> workPhotos = <String>[
    'assets/images/image_here.png',
    'assets/images/image_here.png',
    'assets/images/image_here.png',
    'assets/images/image_here.png',
  ].obs;

  void editServiceDetails() {
    // Navigate to edit screen or show dialog
    Get.snackbar(
      'Edit Service',
      'Edit functionality would be implemented here',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}