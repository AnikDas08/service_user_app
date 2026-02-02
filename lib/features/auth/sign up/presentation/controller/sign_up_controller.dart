import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:http/http.dart' as http;
import 'package:intl_phone_field/countries.dart';
import 'package:haircutmen_user_app/utils/helpers/other_helper.dart';

import '../../../../../config/route/app_routes.dart';
import '../../../../../services/api/api_service.dart';
import '../../../../../config/api/api_end_point.dart';
import '../../../../../utils/app_utils.dart';

/// -------------------------------
/// Location Model
/// -------------------------------
class LocationModel {
  final String placeId;
  final String displayName;
  final String lat;
  final String lon;

  // Address fields (OSM)
  final String houseNumber;
  final String road;
  final String neighbourhood;
  final String suburb;
  final String city;
  final String town;
  final String village;
  final String county;
  final String state;
  final String postcode;
  final String country;
  final String countryCode;

  // Computed fields
  final String shortName;
  final String searchableName;
  final String fullAddress;

  LocationModel({
    required this.placeId,
    required this.displayName,
    required this.lat,
    required this.lon,
    required this.houseNumber,
    required this.road,
    required this.neighbourhood,
    required this.suburb,
    required this.city,
    required this.town,
    required this.village,
    required this.county,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
    required this.shortName,
    required this.searchableName,
    required this.fullAddress,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final address = json['address'] ?? {};

    String getValue(String key) =>
        address[key]?.toString() ?? '';

    /// -------- Short Name (Most specific) --------
    String shortName =
    getValue('neighbourhood').isNotEmpty
        ? getValue('neighbourhood')
        : getValue('suburb').isNotEmpty
        ? getValue('suburb')
        : getValue('road').isNotEmpty
        ? getValue('road')
        : getValue('city').isNotEmpty
        ? getValue('city')
        : getValue('town').isNotEmpty
        ? getValue('town')
        : getValue('village').isNotEmpty
        ? getValue('village')
        : getValue('state');

    /// -------- Searchable Name --------
    List<String> searchParts = [];
    if (getValue('neighbourhood').isNotEmpty) {
      searchParts.add(getValue('neighbourhood'));
    }
    if (getValue('road').isNotEmpty) {
      searchParts.add(getValue('road'));
    }
    if (getValue('city').isNotEmpty) {
      searchParts.add(getValue('city'));
    } else if (getValue('town').isNotEmpty) {
      searchParts.add(getValue('town'));
    }

    String searchableName = searchParts.isNotEmpty
        ? searchParts.join(', ')
        : json['display_name'];

    /// -------- Full Address (Manual structured) --------
    List<String> fullParts = [
      getValue('house_number'),
      getValue('road'),
      getValue('neighbourhood'),
      getValue('suburb'),
      getValue('city'),
      getValue('town'),
      getValue('village'),
      getValue('county'),
      getValue('state'),
      getValue('postcode'),
      getValue('country'),
    ].where((e) => e.isNotEmpty).toList();

    String fullAddress = fullParts.join(', ');

    return LocationModel(
      placeId: json['place_id'].toString(),
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '',
      lon: json['lon'] ?? '',

      houseNumber: getValue('house_number'),
      road: getValue('road'),
      neighbourhood: getValue('neighbourhood'),
      suburb: getValue('suburb'),
      city: getValue('city'),
      town: getValue('town'),
      village: getValue('village'),
      county: getValue('county'),
      state: getValue('state'),
      postcode: getValue('postcode'),
      country: getValue('country'),
      countryCode: getValue('country_code'),

      shortName: shortName,
      searchableName: searchableName,
      fullAddress: fullAddress,
    );
  }
}


/// -------------------------------
/// SignUp Controller
/// -------------------------------
class SignUpController extends GetxController {
  /// Flags
  bool isPopUpOpen = false;
  bool isLoading = false;
  bool isLoadingVerify = false;
  bool isLoadingReset = false;

  /// Country
  String countryCode = '+880';
  String countryFlag = '🇧🇩';

  /// Timer
  Timer? _timer;
  Timer? _debounce;
  num start = 0;
  String time = "";

  /// Role
  List selectedOption = ["User", "Consultant"];
  String selectRole = "User";

  /// Image
  String? image;

  /// Token
  String signUpToken = '';

  /// Location
  List<LocationModel> locationSuggestions = [];
  bool isLocationLoading = false;
  String? latitude;
  String? longitude;

  static SignUpController get instance => Get.put(SignUpController());

  /// Controllers
  TextEditingController nameController =
  TextEditingController(text: kDebugMode ? "Namimul Hassan" : "");

  TextEditingController emailController =
  TextEditingController(text: kDebugMode ? "developernaimul00@gmail.com" : "");

  TextEditingController passwordController =
  TextEditingController(text: kDebugMode ? 'hello123' : '');

  TextEditingController confirmPasswordController =
  TextEditingController(text: kDebugMode ? 'hello123' : '');

  TextEditingController phoneNumberController =
  TextEditingController(text: kDebugMode ? '1865965581' : '');

  TextEditingController otpController =
  TextEditingController(text: kDebugMode ? '123456' : '');

  TextEditingController locationController =
  TextEditingController(text: kDebugMode ? 'Dhaka' : '');

  @override
  void dispose() {
    _timer?.cancel();
    _debounce?.cancel();
    super.dispose();
  }

  /// -------------------------------
  /// Country
  /// -------------------------------
  onCountryChange(Country value) {
    countryCode = value.dialCode.toString();
    update();
  }

  setSelectedRole(value) {
    selectRole = value;
    update();
  }

  /// -------------------------------
  /// Image
  /// -------------------------------
  openGallery() async {
    image = await OtherHelper.openGallery();
    update();
  }

  /// -------------------------------
  /// LOCATION AUTOCOMPLETE
  /// -------------------------------

  void onLocationChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchLocation(value);
    });
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      locationSuggestions.clear();
      update();
      return;
    }

    isLocationLoading = true;
    update();

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
          '?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=5'

    );

    final response = await http.get(
      url,
      headers: {
        "User-Agent": "HaircutMenApp"
      },
    );

    if (response.statusCode == 200) {
      debugPrint("RAW LOCATION RESPONSE 👉 ${response.body}");

      final List data = jsonDecode(response.body);

      debugPrint("PARSED LIST LENGTH 👉 ${data.length}");

      locationSuggestions =
          data.map((e) => LocationModel.fromJson(e)).toList();
    }

    isLocationLoading = false;
    update();
  }



  void selectLocation(LocationModel location) {
    locationController.text = location.displayName;
    latitude = location.lat;
    longitude = location.lon;
    locationSuggestions.clear();
    update();
  }

  /// -------------------------------
  /// SIGN UP
  /// -------------------------------
  signUpUser() async {
    isLoading = true;
    update();

    // Change the type to Map<String, dynamic> to allow different data types
    Map<String, dynamic> body = {
      "role": "USER",
      "name": nameController.text,
      "email": emailController.text,
      "contact": phoneNumberController.text,
      "countryCode": countryCode,
      "location": locationController.text,
      "latitude": latitude ?? "",
      "longitude": longitude ?? "",
      "password": passwordController.text,
      "coordinates": [longitude ?? 0.0, latitude ?? 0.0],
      "referralCode": "O-BQ7LRC"
    };

    var response = await ApiService.post(ApiEndPoint.signUp, body: body);

    if (response.statusCode == 200) {
      Get.toNamed(AppRoutes.verifyUser);
    } else {
      Utils.errorSnackBar(
        response.statusCode.toString(),
        response.message,
      );
    }

    isLoading = false;
    update();
  }

  /// -------------------------------
  /// OTP
  /// -------------------------------
  resendOtp() async {
    isLoadingReset = true;
    update();

    var response = await ApiService.post(
      ApiEndPoint.resendOtp,
      body: {"email": emailController.text},
    );

    if (response.statusCode == 200) {
      Get.snackbar(
        AppString.successful,
        AppString.otp_send_successful_text,
      );
    } else {
      Utils.errorSnackBar(
        response.statusCode.toString(),
        response.message,
      );
    }

    isLoadingReset = false;
    update();
  }

  void startTimer() {
    _timer?.cancel();
    start = 180;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (start > 0) {
        start--;
        time =
        "${(start ~/ 60).toString().padLeft(2, '0')}:${(start % 60).toString().padLeft(2, '0')}";
        update();
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> verifyOtpRepo() async {
    isLoadingVerify = true;
    update();

    var response = await ApiService.post(
      ApiEndPoint.verifyUser,
      body: {
        "email": emailController.text,
        "oneTimeCode": otpController.text,
      },
      header: {"SignUpToken": "signUpToken $signUpToken"},
    );

    if (response.statusCode == 200) {
      Utils.successSnackBar(
        AppString.successful,
        response.message,
      );
      Get.offAllNamed(AppRoutes.signIn);
    } else {
      Get.snackbar(
        response.statusCode.toString(),
        response.message,
      );
    }

    isLoadingVerify = false;
    update();
  }
}
