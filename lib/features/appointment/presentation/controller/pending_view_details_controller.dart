import 'package:get/get.dart';


class PendingViewDetailsController extends GetxController {
  // Online status
  bool isOnline = true;

  // Selected filter (0: Upcoming, 1: Pending, 2: Canceled)
  int selectedFilter = 1;



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