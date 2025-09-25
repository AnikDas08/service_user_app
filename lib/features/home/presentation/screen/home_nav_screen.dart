import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/message/presentation/screen/chat_screen.dart';
import 'package:haircutmen_user_app/features/overview/presentation/screen/overview_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key}) {
    // Initialize the controller when the widget is created
    Get.put(HomeNavController());
  }

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey<CurvedNavigationBarState>();

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg", "label": "Home"},
    {"icon": "assets/icons/overview_icon.svg", "label": "Overview"},
    {"icon": "assets/icons/scan_icon.svg", "label": "QR Code"},
    {"icon": "assets/icons/message_icon.svg", "label": "Message"},
    {"icon": "assets/icons/profile.svg", "label": "Profile"},
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeNavController>();
    return Obx(
      ()=>Scaffold(
        body: IndexedStack(
                index: controller.selectedIndex.value,
                children: [
                  const HomeScreen(),
                  const OverviewScreen(),
                  // Lazy load only when QR tab selected
                  controller.selectedIndex == 2
                      ? const ScanScreen()
                      : Container(),
                  ChatListScreen(),
                  const ProfileScreen(),
                ],
              ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Curved Navigation Bar
            CurvedNavigationBar(
              key: _bottomNavigationKey,
              index: controller.selectedIndex.value,
              backgroundColor: AppColors.transparent,
              buttonBackgroundColor: AppColors.primaryColor,
              color: AppColors.primaryColor,
              height: 50,
              animationCurve: Curves.easeInOut,
              animationDuration: const Duration(milliseconds: 600),
              items: List.generate(_navItems.length, (index) {
                return SvgPicture.asset(
                  _navItems[index]["icon"]!,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                );
              }),
              onTap: controller.changeIndex,
            ),
            // Static text labels below
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              width: double.infinity,
              color: AppColors.primaryColor,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(_navItems.length, (index) {
                      return Expanded(
                        child: Center(
                          child: CommonText(
                            text: _navItems[index]["label"]!,
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: controller.selectedIndex == index
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 20.h,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
