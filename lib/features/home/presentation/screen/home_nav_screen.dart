import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/appointment_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/message/presentation/screen/chat_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key});

  final List<Map<String, String>> _navItems = [
    {"icon": "assets/icons/home.svg", "label": AppString.home},
    {"icon": "assets/icons/appointment_icon.svg", "label": AppString.appointment},
    {"icon": "assets/icons/scan_icon.svg", "label": AppString.qrCode},
    {"icon": "assets/icons/message_icon.svg", "label": AppString.message},
    {"icon": "assets/icons/profile.svg", "label": AppString.profile},
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeNavController>(
      init: HomeNavController(),
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.selectedIndex.toInt(),
            children: [
              controller.selectedIndex == 0 ?HomeScreen():Container(),
              controller.selectedIndex == 1 ? AppointmentScreen() : Container(),
              controller.selectedIndex == 2 ? ScanScreen() : Container(),
              controller.selectedIndex == 3 ? ChatListScreen() : Container(),
              controller.selectedIndex == 4 ? ProfileScreen() : Container(),
            ],
          ),

          /// 🟢 Bottom Navigation with Card Design
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                currentIndex: controller.selectedIndex,
                onTap: controller.changeIndex,
                selectedItemColor: AppColors.primaryColor,
                unselectedItemColor: Colors.black,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp, // Bigger text for selected item
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10.sp, // Smaller text for unselected item
                ),
                iconSize: 22,
                items: List.generate(_navItems.length, (index) {
                  return BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 10),
                      child:
                      _navItems[index]["label"] == AppString.message
                          ? Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            _navItems[index]["icon"]!,
                            width: 22,
                            height: 22,
                            colorFilter: ColorFilter.mode(
                              controller.selectedIndex == index
                                  ? AppColors.primaryColor
                                  : Colors.black,
                              BlendMode.srcIn,
                            ),
                          ),

                          /// 🔴 PERFECT BADGE
                          Positioned(
                            right: -6.r,   // Proper right alignment
                            top: -8.r,     // Proper top alignment
                            child: Container(
                              padding: EdgeInsets.all(4.r), // Ensures circle shape
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: CommonText(
                                text: "3",      // dynamic value here
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      )
                          :
                      SvgPicture.asset(
                        _navItems[index]["icon"]!,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(
                          controller.selectedIndex == index
                              ? AppColors.primaryColor
                              : Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    label: _navItems[index]["label"],
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }
}
