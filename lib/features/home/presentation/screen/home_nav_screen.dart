import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/appointment_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/message/presentation/screen/chat_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key});

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg", "label": "Home"},
    {"icon": "assets/icons/appointment_icon.svg", "label": "Appointment"},
    {"icon": "assets/icons/scan_icon.svg", "label": "QR Code"},
    {"icon": "assets/icons/message_icon.svg", "label": "Message"},
    {"icon": "assets/icons/profile.svg", "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeNavController>(
      init: HomeNavController(),
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.selectedIndex,
            children: [
              HomeScreen(),
              controller.selectedIndex == 1 ?AppointmentScreen():Container(),
              controller.selectedIndex == 2 ? ScanScreen() : Container(),
              controller.selectedIndex == 3 ?ChatListScreen():Container(),
              controller.selectedIndex == 4 ? ProfileScreen():Container(),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.primaryColor,
            currentIndex: controller.selectedIndex,
            onTap: controller.changeIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white54,
            selectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 12.sp,
            ),
            iconSize: 22, // slightly larger icons
            items: List.generate(_navItems.length, (index) {
              return BottomNavigationBarItem(
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 10,top: 10),
                  child: SvgPicture.asset(
                    _navItems[index]["icon"]!,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      controller.selectedIndex == index
                          ? Colors.white
                          : Colors.white54,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                label: _navItems[index]["label"],
              );
            }),
          ),
        );
      },
    );
  }
}
