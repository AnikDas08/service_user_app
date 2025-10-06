import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class InvoiceController extends GetxController {

  Map<String, dynamic> serviceProvider = {};
  TextEditingController promoCode=TextEditingController();
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    serviceProvider = Get.arguments ?? {};
    print("service $serviceProvider");
  }

}