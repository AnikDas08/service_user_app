import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/canceldetails_screen.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/viewdetails_pending.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/screen/viewdetailse_upcomming.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/details_category.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/invoice_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/contract_support_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/favourite_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/language_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/screen/personal_information_screen.dart';
import 'package:haircutmen_user_app/features/setting/presentation/screen/privacy_policy_screen.dart';
import '../../features/auth/change_password/presentation/screen/change_password_screen.dart';
import '../../features/auth/forgot password/presentation/screen/create_password.dart';
import '../../features/auth/forgot password/presentation/screen/forgot_password.dart';
import '../../features/auth/forgot password/presentation/screen/verify_screen.dart';
import '../../features/auth/sign in/presentation/screen/sign_in_screen.dart';
import '../../features/auth/sign up/presentation/screen/sign_up_screen.dart';
import '../../features/auth/sign up/presentation/screen/verify_user.dart';
import '../../features/message/presentation/screen/chat_screen.dart';
import '../../features/message/presentation/screen/message_screen.dart';
import '../../features/notifications/presentation/screen/notifications_screen.dart';
import '../../features/onboarding_screen/onboarding_screen.dart';
import '../../features/profile/presentation/screen/edit_profile.dart';
import '../../features/profile/presentation/screen/profile_screen.dart';
import '../../features/setting/presentation/screen/setting_screen.dart';
import '../../features/setting/presentation/screen/terms_of_services_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/presentation/screen/home_screen.dart';
import '../../features/home/presentation/screen/home_nav_screen.dart';
import '../../features/appointment/presentation/screen/appointment_screen.dart';
import '../../features/scan/presentation/screen/scan_screen.dart';

class AppRoutes {
  static const String test = "/test_screen.dart";
  static const String splash = "/splash_screen.dart";
  static const String onboarding = "/onboarding_screen.dart";
  static const String signUp = "/sign_up_screen.dart";
  static const String verifyUser = "/verify_user.dart";
  static const String signIn = "/sign_in_screen.dart";
  static const String forgotPassword = "/forgot_password.dart";
  static const String verifyEmail = "/verify_screen.dart";
  static const String createPassword = "/create_password.dart";
  static const String changePassword = "/change_password_screen.dart";
  static const String notifications = "/notifications_screen.dart";
  static const String chat = "/chat_screen.dart";
  static const String message = "/message_screen.dart";
  static const String profile = "/profile_screen.dart";
  static const String editProfile = "/edit_profile.dart";
  static const String privacyPolicy = "/privacy_policy_screen.dart";
  static const String termsOfServices = "/terms_of_services_screen.dart";
  static const String setting = "/setting_screen.dart";
  static const String home = "/home_screen.dart";
  static const String homeNav = "/home_nav_screen.dart";
  static const String appointment = "/appointment_screen.dart";
  static const String scan = "/scan_screen.dart";
  static const String details_category_screen = "/details_category_screen";
  static const String upcomingdetail_screen = "/upcomingdetail_screen";
  static const String view_detail_pending = "/view_detail_pending";
  static const String canceldetails_screen = "/canceldetails_screen";
  static const String personal_information_screen = "/personal_information_screen";
  static const String language_screen = "/language_screen";
  static const String contract_support_screen = "/contract_support_screen";
  static const String favourite_screen = "/favourite_screen";
  static const String invoice = "/invoice";

  static List<GetPage> routes = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: onboarding, page: () => const OnboardingScreen()),
    GetPage(name: signUp, page: () => SignUpScreen()),
    GetPage(name: verifyUser, page: () => const VerifyUser()),
    GetPage(name: signIn, page: () => SignInScreen()),
    GetPage(name: forgotPassword, page: () => ForgotPasswordScreen()),
    GetPage(name: verifyEmail, page: () => const VerifyScreen()),
    GetPage(name: createPassword, page: () => CreatePassword()),
    GetPage(name: changePassword, page: () => ChangePasswordScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: chat, page: () => ChatListScreen()),
    GetPage(name: message, page: () => MessageScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: editProfile, page: () => EditProfile()),
    GetPage(name: privacyPolicy, page: () => PrivacyPolicyScreen()),
    GetPage(name: termsOfServices, page: () => TermsOfServicesScreen()),
    GetPage(name: setting, page: () => const SettingScreen()),
    GetPage(name: home, page: () => HomeScreen()),
    GetPage(name: homeNav, page: () => HomeNavScreen()),
    GetPage(name: appointment, page: () => const AppointmentScreen()),
    GetPage(name: scan, page: () => ScanScreen()),
    GetPage(name: details_category_screen, page: () => DetailsCategoryScreen()),
    GetPage(name: upcomingdetail_screen, page: () => ViewDetailsUpcoming()),
    GetPage(name: view_detail_pending, page: () => ViewDetailsPending()),
    GetPage(name: canceldetails_screen, page: () => CancelDetailsScreen()),
    GetPage(name: personal_information_screen, page: () => PersonalInformationScreen()),
    GetPage(name: language_screen, page: () => LanguageSelectionScreen()),
    GetPage(name: contract_support_screen, page: () => ContractsScreen()),
    GetPage(name: favourite_screen, page: () => FavouriteScreen()),
    GetPage(name: invoice, page: () => InvoiceScreen()),
  ];
}
