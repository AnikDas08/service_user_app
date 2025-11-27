import 'package:flutter/material.dart';
import 'package:haircutmen_user_app/features/auth/sign%20in/presentation/controller/sign_in_controller.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../config/route/app_routes.dart';
import 'package:get/get.dart';
import '../../component/image/common_image.dart';
import '../../services/storage/storage_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () async {
      print("token 🤣🤣🤣🤣🤣${LocalStorage.token}");
      if (LocalStorage.isLogIn) {
        bool isValidUser=await SignInController().checkProfile();
        if(isValidUser){
          Get.offAllNamed(AppRoutes.homeNav);
        }
        else{
          Get.offAllNamed(AppRoutes.onboarding);
        }
      } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
      //Get.offAllNamed(AppRoutes.onboarding);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset("assets/images/flash_image_service.jpg",height: double.infinity,width: double.infinity,fit: BoxFit.fill,)
    );
  }
}
