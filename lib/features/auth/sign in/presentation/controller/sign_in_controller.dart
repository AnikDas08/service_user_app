import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
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

  /// email and password Controller here
  TextEditingController emailController = TextEditingController(
    text: kDebugMode ? 'pamed91463@ametitas.com' : '',
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
          ///rtrfgg
          Utils.errorSnackBar(response.statusCode, response.message);
        }
      } catch (e) {
        Utils.errorSnackBar(0, e.toString());
      }

      emailController.clear();
      passwordController.clear();
    } else {
      Get.snackbar(response.statusCode.toString(), response.message);
    }

    isLoading = false;
    update();
  }
}
