import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../services/storage/storage_keys.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../services/storage/storage_services.dart';
import '../../../../../utils/app_utils.dart';

class SignUpController extends GetxController {
  /// Sign Up Form Key

  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isLoadingReset = false;
  String countryCode = '+880'; // Stores selected country code
  String countryFlag = '🇧🇩';

  Timer? _timer;
  int start = 0;

  String time = "";

  List selectedOption = ["User", "Consultant"];

  String selectRole = "User";
  String? image;

  String signUpToken = '';

  static SignUpController get instance => Get.put(SignUpController());

  TextEditingController nameController = TextEditingController(
    text: kDebugMode ? "Namimul Hassan" : "",
  );
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? "developernaimul00@gmail.com" : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController phoneNumberController = TextEditingController(
    text: kDebugMode ? '1865965581' : '',
  );
  TextEditingController otpController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  TextEditingController locationController = TextEditingController(
    text: kDebugMode ? 'Dhaka' : '',
  );



  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  onCountryChange(Country value) {
    countryCode = value.dialCode.toString();
    print("Contry Code 😍😍😍😍 ${countryCode}");
    print("Contry Code 😍😍😍😍 ${countryFlag}");
    update();
  }

  setSelectedRole(value) {
    selectRole = value;
    update();
  }

  openGallery() async {
    image = await OtherHelper.openGallery();
    update();
  }

  signUpUser() async {
    //Get.toNamed(AppRoutes.verifyUser);
    //return;
    isLoading = true;
    print("😂😂😂😂${countryCode}");
    print("😍😍😍😍 ${countryFlag}");
    update();
    Map<String, String> body = {
      "role":"USER",
      "name":nameController.text,
      "email":emailController.text,
      "contact":phoneNumberController.text,
      "countryCode":countryCode,
      "location":locationController.text,
      "password":passwordController.text,
      "referralCode":"O-BQ7LRC"
    };

    var response = await ApiService.post(ApiEndPoint.signUp, body: body);

    if (response.statusCode == 200) {
      var data = response.data;
      Get.toNamed(AppRoutes.verifyUser);
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoading = false;
    update();
  }

  resendOtp() async {
    //Get.toNamed(AppRoutes.verifyUser);
    //return;
    isLoadingReset = true;
    update();
    Map<String, String> body = {
      "email":emailController.text,
    };

    var response = await ApiService.post(ApiEndPoint.resendOtp, body: body);

    if (response.statusCode == 200) {
      var data = response.data;
      Get.toNamed(AppRoutes.verifyUser);
      Get.snackbar("Successful", "Otp Send Successfully");
    } else {
      Utils.errorSnackBar(response.statusCode.toString(), response.message);
    }
    isLoadingReset = false;
    update();
  }

  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    start = 180; // Reset the start value
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        final minutes = (start ~/ 60).toString().padLeft(2, '0');
        final seconds = (start % 60).toString().padLeft(2, '0');

        time = "$minutes:$seconds";

        update();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> verifyOtpRepo() async {
    //Get.offAllNamed(AppRoutes.signIn);
    //return;

    isLoadingVerify = true;
    update();
    Map<String, String> body = {"email":emailController.text,"oneTimeCode": otpController.text};
    Map<String, String> header = {"SignUpToken": "signUpToken $signUpToken"};
    var response = await ApiService.post(
      ApiEndPoint.verifyUser,
      body: body,
      header: header,
    );

    if (response.statusCode == 200) {
      var data = response.data;

      /*LocalStorage.token = data['data']["accessToken"];
      LocalStorage.userId = data['data']["attributes"]["_id"];
      LocalStorage.myImage = data['data']["attributes"]["image"];
      LocalStorage.myName = data['data']["attributes"]["fullName"];
      LocalStorage.myEmail = data['data']["attributes"]["email"];
      LocalStorage.isLogIn = true;

      LocalStorage.setBool(LocalStorageKeys.isLogIn, LocalStorage.isLogIn);
      LocalStorage.setString(LocalStorageKeys.token, LocalStorage.token);
      LocalStorage.setString(LocalStorageKeys.userId, LocalStorage.userId);
      LocalStorage.setString(LocalStorageKeys.myImage, LocalStorage.myImage);
      LocalStorage.setString(LocalStorageKeys.myName, LocalStorage.myName);
      LocalStorage.setString(LocalStorageKeys.myEmail, LocalStorage.myEmail);*/

      // if (LocalStorage.myRole == 'consultant') {
      //   Get.toNamed(AppRoutes.personalInformation);
      // } else {
      //   Get.offAllNamed(AppRoutes.patientsHome);
      // }

      Get.offAllNamed(AppRoutes.signIn);
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingVerify = false;
    update();
  }
}
