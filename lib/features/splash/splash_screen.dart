import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:app_links/app_links.dart'; // ✅ Added
import 'package:haircutmen_user_app/features/auth/sign%20in/presentation/controller/sign_in_controller.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../config/route/app_routes.dart';
import 'package:get/get.dart';
import '../../component/app_storage/storage_key.dart';
import '../../component/image/common_image.dart';
import '../../services/storage/storage_services.dart';
import '../../utils/deep_link_handler.dart';

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
      print("token 🤣🤣🤣🤣🤣${LocalStorage.userId}");
      final box = GetStorage();
      String? language = box.read(StorageKey.language);
      print("language : $language");

      if (language != null && language.isNotEmpty) {
        Get.updateLocale(Locale(language));
      }
      if (LocalStorage.isLogIn) {
        bool isValidUser = await SignInController().checkProfile();
        if (!mounted) return; // ✅ Check if widget is still here

        if (isValidUser) {
          // ✅ হ্যান্ডলার ব্যবহার করে ডিপলিংক চেক করা হচ্ছে
          if (DeepLinkHandler.pendingId != null) {
            String id = DeepLinkHandler.pendingId!;
            DeepLinkHandler.pendingId = null; // Clear it
            DeepLinkHandler.handle(id);
          } else {
            Get.offAllNamed(AppRoutes.homeNav);
          }
        } else {
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
      body: Image.asset("assets/images/logo.png",height: double.infinity,width: double.infinity,fit: BoxFit.fill,)
    );
  }
}
