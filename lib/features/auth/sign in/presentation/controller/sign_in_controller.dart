import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 🌟 নতুন ইম্পোর্ট
import 'package:google_sign_in/google_sign_in.dart'; // 🌟 নতুন ইম্পোর্ট
import 'package:haircutmen_user_app/features/profile/data/profiles_model.dart';
import 'package:haircutmen_user_app/utils/app_utils.dart';
import '../../../../../component/app_storage/app_auth_storage.dart';
import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../services/storage/storage_services.dart';

class SignInController extends GetxController {
  /// Sign in Button Loading variable
  bool isLoading = false;

  /// 🌟 Google Sign-In এবং Firebase-এর জন্য অবজেক্ট (নতুন যুক্ত করা হয়েছে)
  FirebaseAuth get _auth => FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn();

  /// email and password Controller here
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'takeci1126@gxuzi.com' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : "",
  );

  Future<bool> checkProfile() async {
    try {
      var response = await ApiService.get(
        ApiEndPoint.user,
        header: {"Authorization": "Bearer ${LocalStorage.token}"},
      );

      if (response.statusCode == 200) {
        return true;
      }
      else if (response.statusCode == 401) {
        // Session expired → logout
        //AppAuthStorage().clear(); // if available
        LocalStorage.isLogIn = false;
        LocalStorage.token = "";
        LocalStorage.setBool(LocalStorageKeys.isLogIn, false);
        LocalStorage.setString(LocalStorageKeys.token, "");
        return false;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<void> signInUser() async {
    //Get.toNamed(AppRoutes.complete_profile_screen);
    //return;

    isLoading = true;
    update();

    Map<String, String> body = {
      "role": "USER",
      "email": emailController.text,
      "password": passwordController.text,
    };

    var response = await ApiService.post(
      ApiEndPoint.signIn,
      body: body,
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      var data = response.data;

      AppAuthStorage().setToken(data['data']["accessToken"]);

      LocalStorage.token = data['data']["accessToken"];
      LocalStorage.isLogIn = true;
      LocalStorage.userId = data['data']["id"];
      //LocalStorage.userName = data['data']["name"];
      //print("dkjfklsdjfkd 😍😍😍😍😍 ${LocalStorage.userId}");

      LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
      LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
      LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
      //LocalStorage.setString(LocalStorageKeys.userName, LocalStorage.userId);

      Get.offAllNamed(AppRoutes.homeNav);


      try {
        final response = await ApiService.get(
          ApiEndPoint.user,
          header: {"Authorization": "Bearer ${LocalStorage.token}"},
        );
        if (response.statusCode == 200) {
          final profileModel = ProfileModel.fromJson(response.data);
          LocalStorage.myName = profileModel.data?.name ?? "";
          LocalStorage.myEmail = profileModel.data?.email ?? "";
          LocalStorage.myImage = profileModel.data?.image ?? "";
        } else {

          Utils.errorSnackBar("Invalid Credentials", response.message);
        }
      } catch (e) {
        Utils.errorSnackBar(0, e.toString());
        debugPrint("================================${e.toString()}========================================");
      }

      emailController.clear();
      passwordController.clear();
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoading = false;
    update();
  }

  /// 🌟 🌟 🌟 নতুন যুক্ত করা মেথড: Firebase Google Sign-In 🌟 🌟 🌟
  Future<void> signInWithGoogleFirebase() async {
    isLoading = true;
    update();

    try {
      // ১. গুগলের পপআপ স্ক্রিন ওপেন করা
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading = false;
        update();
        return; // ইউজার পপআপ কেটে দিলে এখান থেকেই মেথড শেষ হবে
      }

      // ২. গুগল অ্যাকাউন্ট থেকে সিকিউরিটি টোকেন নেওয়া
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // ৩. ফায়ারবেসের জন্য ক্রেডেনশিয়াল (Credential) তৈরি করা
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // ৪. ফায়ারবেস অথেনটিকেশনে সাইন-ইন সম্পন্ন করা
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // ৫. ব্যাকএন্ডে পাঠানোর জন্য ফায়ারবেস থেকে মেইন idToken নেওয়া
        String? firebaseIdToken = await firebaseUser.getIdToken();

        if (firebaseIdToken == null) {
          Utils.errorSnackBar("Error", "Firebase token creation failed.");
          isLoading = false;
          update();
          return;
        }

        // ৬. এই ফায়ারবেস টোকেনটি আপনার কাস্টম ব্যাকএন্ড এপিআই-তে পাঠানো
        Map<String, String> body = {
          "role": "USER",
          "provider": "google",
          "providerUserId": firebaseIdToken,
          "name": "",
          "email": firebaseUser.email ?? "",
        };

        // কাস্টম ব্যাকএন্ডের এপিআই কল (আপনার আগের সিস্টেমের রেসপন্স হ্যান্ডেলিং ফলো করা হয়েছে)
        var response = await ApiService.post(
          ApiEndPoint.signIn, // সোশ্যাল লগইনের জন্য আলাদা এন্ডপয়েন্ট থাকলে তা এখানে বসাবেন
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          var data = response.data;

          // ৭. আপনার আগের কোডের মতোই সিস্টেমে এবং লোকাল স্টোরেজে সাকসেস টোকেন সেভ করা
          AppAuthStorage().setToken(data['data']["accessToken"]);

          LocalStorage.token = data['data']["accessToken"];
          LocalStorage.isLogIn = true;
          LocalStorage.userId = data['data']["id"];

          LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
          LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);

          // হোম নেভিগেশনে পাঠানো
          Get.offAllNamed(AppRoutes.homeNav);

          // ব্যাকগ্রাউন্ডে প্রোফাইল ডেটা লোড বা সিঙ্ক করা
          try {
            final response = await ApiService.get(
              ApiEndPoint.user,
              header: {"Authorization": "Bearer ${LocalStorage.token}"},
            );
            if (response.statusCode == 200) {
              final profileModel = ProfileModel.fromJson(response.data);
              LocalStorage.myName = profileModel.data?.name ?? "";
              LocalStorage.myEmail = profileModel.data?.email ?? "";
              LocalStorage.myImage = profileModel.data?.image ?? "";
            } else {
              Utils.errorSnackBar("Invalid Credentials", response.message);
            }
          } catch (e) {
            Utils.errorSnackBar(0, e.toString());
            debugPrint("================================${e.toString()}========================================");
          }
        } else {
          Get.snackbar(response.statusCode.toString(), response.message);
        }
      }
    } catch (e) {
      Utils.errorSnackBar("Google Auth Failed", e.toString());
      debugPrint("=================== GOOGLE AUTH ERROR: $e ===================");
    }

    isLoading = false;
    update();
    //
  }

  /// 🌟 Apple Sign-In with Firebase
  Future<void> signInWithAppleFirebase() async {
    isLoading = true;
    update();

    try {
      final appleProvider = AppleAuthProvider();
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      final UserCredential userCredential = await _auth.signInWithProvider(appleProvider);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        String? firebaseIdToken = await firebaseUser.getIdToken();

        if (firebaseIdToken == null) {
          Utils.errorSnackBar("Error", "Firebase token creation failed.");
          isLoading = false;
          update();
          return;
        }

        Map<String, String> body = {
          "role": "USER",
          "provider": "apple",
          "providerUserId": firebaseIdToken,
          "name": "dsf",
          "email": firebaseUser.email ?? "",
        };

        var response = await ApiService.post(
          "auth/social-login",
          body: body,
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          var data = response.data;

          AppAuthStorage().setToken(data['data']["accessToken"]);

          LocalStorage.token = data['data']["accessToken"];
          LocalStorage.isLogIn = true;
          LocalStorage.userId = data['data']["id"];

          LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
          LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
          LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);

          Get.offAllNamed(AppRoutes.homeNav);

          try {
            final response = await ApiService.get(
              ApiEndPoint.user,
              header: {"Authorization": "Bearer ${LocalStorage.token}"},
            );
            if (response.statusCode == 200) {
              final profileModel = ProfileModel.fromJson(response.data);
              LocalStorage.myName = profileModel.data?.name ?? "";
              LocalStorage.myEmail = profileModel.data?.email ?? "";
              LocalStorage.myImage = profileModel.data?.image ?? "";
            }
            if(response.statusCode==404){
              Utils.errorSnackBar("Need to Registration", "Account not found. Please sign up first.");
            }
          } catch (e) {
            Utils.errorSnackBar("Error", e.toString());
            debugPrint("Error fetching profile: $e");
          }
        } else {
          Get.snackbar(response.statusCode.toString(), response.message);
        }
      }
    } catch (e) {
      Utils.errorSnackBar("Apple Auth Failed", e.toString());
      debugPrint("=================== APPLE AUTH ERROR: $e ===================");
    }

    isLoading = false;
    update();
  }
}
