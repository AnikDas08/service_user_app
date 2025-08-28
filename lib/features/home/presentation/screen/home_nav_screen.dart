import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/image/common_image.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/appointment_screen.dart';
import 'package:haircutmen_user_app/features/favorite/presentation/screen/favorite_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/home_nav_controller.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/scan/presentation/screen/scan_screen.dart';
import 'package:haircutmen_user_app/utils/constants/app_icons.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../profile/presentation/screen/profile_screen.dart';

List<Widget> _pages = [
  const HomeScreen(),
  const AppointmentScreen(),
  const ScanScreen(),
  const FavoriteScreen(),
  const ProfileScreen(),
];

List<String> _icons = [
  AppIcons.home,
  AppIcons.appointment,
  AppIcons.scan,
  AppIcons.favorite,
  AppIcons.profile,
];

class HomeNavScreen extends StatelessWidget {
  HomeNavScreen({super.key});

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey =
      GlobalKey<CurvedNavigationBarState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeNavController>(
      init: HomeNavController(),
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(index: controller.selectedIndex, children: _pages),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CurvedNavigationBar(
                key: _bottomNavigationKey,
                index: controller.selectedIndex,
                backgroundColor: AppColors.transparent,
                buttonBackgroundColor: AppColors.primaryColor,
                color: AppColors.primaryColor,
                items: List.generate(_icons.length, (index) {
                  return CommonImage(
                    imageSrc: _icons[index],
                    imageColor: Colors.white,
                    size: 24,
                  );
                }),
                onTap: controller.changeIndex,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                width: double.infinity,
                height: 30.h,
                color: AppColors.primaryColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonText(
                      text: "Home",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    CommonText(
                      text: "Appointment",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    CommonText(
                      text: "Scan",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    CommonText(
                      text: "Favorite",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    CommonText(
                      text: "Profile",
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
