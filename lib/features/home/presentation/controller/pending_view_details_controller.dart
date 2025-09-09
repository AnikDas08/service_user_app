import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/home/data/model/booking_model.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../screen/home_screen.dart';

class PendingViewDetailsController extends GetxController {
  // Online status
  bool isOnline = true;

  // Selected filter (0: Upcoming, 1: Pending, 2: Canceled)
  int selectedFilter = 0;


  @override
  void onInit() {
    super.onInit();
  }

  // Toggle online status
  void toggleOnlineStatus() {
    isOnline = !isOnline;
    update();

    // You can add additional logic here like API calls
    if (isOnline) {
      print('User is now online');
      // Call API to set status online
    } else {
      print('User is now offline');
      // Call API to set status offline
    }
  }

  // Change filter tab
  void changeFilter(int index) {
    selectedFilter = index;
    update();
  }

}