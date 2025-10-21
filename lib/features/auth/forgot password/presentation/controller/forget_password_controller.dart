import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../utils/app_utils.dart';
import '../../../change_password/presentation/widget/popup_button.dart';

class ForgetPasswordController extends GetxController {
  /// Loading for forget password
  bool isLoadingEmail = false;

  /// Loading for Verify OTP

  bool isLoadingVerify = false;
  bool isLoading = false;

  /// Loading for Creating New Password
  bool isLoadingReset = false;

  /// this is ForgetPassword Token , need to verification
  String forgetPasswordToken = '';


  /// here all Text Editing Controller
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? "user@gmail.com" : '',
  );
  TextEditingController otpController = TextEditingController(
    text: kDebugMode ? '123456' : '',
  );
  TextEditingController passwordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );
  TextEditingController confirmPasswordController = TextEditingController(
    text: kDebugMode ? 'hello123' : '',
  );

  /// create Forget Password Controller instance
  static ForgetPasswordController get instance =>
      Get.put(ForgetPasswordController());

  @override
  void dispose() {
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }



  /// Forget Password Api Call

  Future<void> forgotPasswordRepo() async {
    //Get.toNamed(AppRoutes.verifyEmail);
    //return;
    isLoadingEmail = true;
    update();

    Map<String, String> body = {"email": emailController.text};
    var response = await ApiService.post(
      ApiEndPoint.forgotPassword,
      body: body,
    );

    if (response.statusCode == 200) {
      Utils.successSnackBar(response.statusCode.toString(), response.message);
      Get.toNamed(AppRoutes.verifyEmail);
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }
    isLoadingEmail = false;
    update();
  }
  Future<void> resendOtp() async {
    //Get.toNamed(AppRoutes.verifyEmail);
    //return;
    isLoadingReset = true;
    update();

    Map<String, String> body = {"email": emailController.text};
    var response = await ApiService.post(
      ApiEndPoint.resendOtp,
      body: body,
    );

    if (response.statusCode == 200) {
      Get.toNamed(AppRoutes.verifyEmail);
      Get.snackbar("Successful", "Otp Send Successfully");
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }
    isLoadingReset = false;
    update();
  }

  /// Verify OTP Api Call

  Future<void> verifyOtpRepo() async {
    //Get.toNamed(AppRoutes.createPassword);
    //return;
    isLoadingVerify = true;
    update();
    Map<String, String> body = {
      "email": emailController.text,
      "oneTimeCode": otpController.text,
    };
    var response = await ApiService.post(ApiEndPoint.verifyOtp, body: body,);

    if (response.statusCode == 200) {
      var data = response.data;
      forgetPasswordToken = data['data']['resetPasswordToken'] ?? "";
      Get.toNamed(AppRoutes.createPassword);
    } else {
      //Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingVerify = false;
    update();
  }

  /// Create New Password Api Call

  Future<void> resetPasswordRepo() async {
    isLoadingReset = true;
    update();

    Map<String, String> header = {
      "authorization": forgetPasswordToken, // or use Forget-password: forgetPasswordToken
    };

    Map<String, String> body = {
      "newPassword": passwordController.text,
      "confirmPassword": confirmPasswordController.text,
    };

    print("Sending Reset Header: $header");

    var response = await ApiService.post(
      ApiEndPoint.resetPassword,
      body: body,
      header: header,
    );

    if (response.statusCode == 200) {
      simpleDialog();
      emailController.clear();
      otpController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoadingReset = false;
    update();
  }
}
