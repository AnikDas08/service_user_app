import 'package:get/get.dart';
import '../config/route/app_routes.dart';
import '../services/storage/storage_services.dart';

class DeepLinkHandler {
  static String? pendingId;
  static bool isAppInitialized = false;

  static void handle(String? id) {
    if (id == null || id.isEmpty) return;

    // যদি ইউজার লগইন করা না থাকে, তবে কিছুই করবে না
    if (!LocalStorage.isLogIn) {
      pendingId = id; // লগইন করার পর ব্যবহারের জন্য সেভ করে রাখা যেতে পারে
      return;
    }

    // যদি অ্যাপ এখনও ইনিশিয়ালাইজ না হয়ে থাকে (যেমন স্প্ল্যাশ স্ক্রিনে আছে),
    // তাহলে শুধুমাত্র pendingId হিসেবে সেভ করে রাখব। স্প্ল্যাশ স্ক্রিন এটি হ্যান্ডেল করবে।
    if (!isAppInitialized) {
      pendingId = id;
      return;
    }

    // অ্যাপ যদি বর্তমানে হোমে থাকে, তবে সরাসরি ডিটেইলসে যাবে
    // আর যদি অন্য কোথাও থাকে (যেমন অ্যাপ ক্লোজ), তবে হোমে গিয়ে তারপর ডিটেইলসে যাবে
    if (Get.currentRoute == AppRoutes.homeNav) {
      Get.toNamed(AppRoutes.service_details, parameters: {'id': id});
    } else {
      // ব্যাকগ্রাউন্ড থেকে বা ক্লোজ অবস্থা থেকে আসলে
      Get.offAllNamed(AppRoutes.homeNav, arguments: {'deepLinkProviderId': id});
    }
  }
}
