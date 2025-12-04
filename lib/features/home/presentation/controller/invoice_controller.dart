import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/stripe_web_view_screen.dart';
import 'package:haircutmen_user_app/features/profile/presentation/controller/profile_controller.dart';
import 'package:haircutmen_user_app/utils/app_utils.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';

class InvoiceController extends GetxController {
  final RxInt creditApplied = 0.obs;
  // Text Controllers
  TextEditingController promoCode = TextEditingController();

  // Invoice Data
  Map<String, dynamic> invoiceData = {};
  List<Map<String, dynamic>> selectedServices = [];

  // Observable values
  final RxInt subTotal = 0.obs;
  final RxInt discount = 0.obs;
  final RxInt totalPrice = 0.obs;
  final RxInt discountPercent = 0.obs;
  final RxBool isPromoApplied = false.obs;
  final RxBool isProcessing = false.obs;
  final RxBool isLoadingFees = true.obs;
  final RxString validPromoCode = ''.obs;

  // Dynamic fees from API
  final RxInt weatherFee = 0.obs;
  final RxInt convenienceFee = 0.obs;
  final RxInt arrivalFee = 0.obs;
  final RxDouble credits = 0.0.obs;

  // ✅ NEW: Track which fees are enabled
  final RxBool isWeatherFeeOn = false.obs;
  final RxBool isConvenienceFeeOn = false.obs;
  final RxBool isArrivalFeeOn = false.obs;

  num runningTotal = 0;
  num amountTotal = 0;

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      invoiceData = Get.arguments;
      _parseInvoiceData();
    }

    _fetchSystemFees();
    getCredit();

    print("📄 Invoice Data: $invoiceData");
  }

  void _parseInvoiceData() {
    if (invoiceData['selectedServices'] != null) {
      selectedServices = List<Map<String, dynamic>>.from(
        invoiceData['selectedServices'],
      );
    }

    num calculatedSubTotal = invoiceData['totalPrice'] ?? 0;
    subTotal.value = calculatedSubTotal.toInt();

    print("💰 SubTotal: ${subTotal.value}");
    print("🎯 Services: $selectedServices");
  }

  Future<void> _fetchSystemFees() async {
    try {
      isLoadingFees.value = true;

      final response = await ApiService.get(
        "system",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      print("📡 System Fees Response: ${response.statusCode}");
      print("📦 System Fees Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];

        // ✅ Weather Fee - only set if isOn is true
        if (data['weatherFee'] != null) {
          bool isOn = data['weatherFee']['isOn'] ?? false;
          isWeatherFeeOn.value = isOn;
          weatherFee.value = isOn ? (data['weatherFee']['amount'] ?? 0) : 0;
          print("🌤️ Weather Fee - isOn: $isOn, amount: ${weatherFee.value}");
        }

        // ✅ Convenience Fee - only set if isOn is true
        if (data['convenienceFee'] != null) {
          bool isOn = data['convenienceFee']['isOn'] ?? false;
          isConvenienceFeeOn.value = isOn;
          convenienceFee.value = isOn ? (data['convenienceFee']['amount'] ?? 0) : 0;
          print("💼 Convenience Fee - isOn: $isOn, amount: ${convenienceFee.value}");
        }

        // ✅ Arrival Fee - only set if isOn is true
        if (data['arrivalFee'] != null) {
          bool isOn = data['arrivalFee']['isOn'] ?? false;
          isArrivalFeeOn.value = isOn;
          arrivalFee.value = isOn ? (data['arrivalFee']['amount'] ?? 0) : 0;
          print("🚗 Arrival Fee - isOn: $isOn, amount: ${arrivalFee.value}");
        }

        _calculateTotalPrice();

        print("✅ Fees loaded successfully");
      } else {
        print("⚠️ Failed to load system fees");
        _calculateTotalPrice();
      }
    } catch (e) {
      print("❌ Error fetching system fees: $e");
      _calculateTotalPrice();
    } finally {
      isLoadingFees.value = false;
    }
  }

  void _calculateTotalPrice() {
    // Step 1: Start with SubTotal
    runningTotal = subTotal.value;
    print("💵 Step 1 - SubTotal: $runningTotal");

    // Step 2: Subtract Discount (from promo code) FIRST
    runningTotal -= discount.value;
    print("💵 Step 2 - After Discount (${discount.value}): $runningTotal");

    // Step 3: Add all Fees (only if they are enabled)
    if (isWeatherFeeOn.value) {
      runningTotal += weatherFee.value;
      print("💵 Step 3a - After Weather Fee (${weatherFee.value}): $runningTotal");
    }

    if (isConvenienceFeeOn.value) {
      runningTotal += convenienceFee.value;
      print("💵 Step 3b - After Convenience Fee (${convenienceFee.value}): $runningTotal");
    }

    if (isArrivalFeeOn.value) {
      runningTotal += arrivalFee.value;
      print("💵 Step 3c - After Arrival Fee (${arrivalFee.value}): $runningTotal");
    }

    // Step 4: Calculate how much credit can be applied
    num creditToApply = credits.value.toInt();
    if (creditToApply > runningTotal) {
      creditToApply = runningTotal; // Don't apply more credit than total
    }
    if (runningTotal < 0) {
      creditToApply = 0; // Don't apply credit if total is already negative
    }
    creditApplied.value = creditToApply.toInt();
    print("💵 Step 4 - Credit Available: ${credits.value}, Applied: $creditToApply");

    // Step 5: Subtract applied credit from total
    amountTotal = runningTotal;
    runningTotal -= creditToApply;
    print("💵 Step 5 - After Credit ($creditToApply): $runningTotal");

    // Ensure total doesn't go below 0
    if (runningTotal < 0) {
      runningTotal = 0;
    }

    totalPrice.value = runningTotal.toInt();

    print("💵 ============ FINAL CALCULATION ============");
    print("💵 SubTotal: ${subTotal.value}");
    print("💵 - Discount: ${discount.value}");
    if (isWeatherFeeOn.value) print("💵 + Weather Fee: ${weatherFee.value}");
    if (isConvenienceFeeOn.value) print("💵 + Convenience Fee: ${convenienceFee.value}");
    if (isArrivalFeeOn.value) print("💵 + Arrival Fee: ${arrivalFee.value}");
    print("💵 - Credit Applied: $creditToApply");
    print("💵 = TOTAL TO PAY: ${totalPrice.value}");
    print("💵 ==========================================");
  }

  // Getters for UI
  String get providerName {
    if (invoiceData['provider'] != null &&
        invoiceData['provider']['user'] != null) {
      return invoiceData['provider']['user']['name'] ?? 'Service Provider';
    }
    return invoiceData['providerName'] ?? 'Service Provider';
  }

  String? get providerImage {
    if (invoiceData['provider'] != null &&
        invoiceData['provider']['user'] != null) {
      return invoiceData['provider']['user']['image'];
    }
    return invoiceData['providerImage'];
  }

  String get bookingDate {
    return invoiceData['date'] ?? 'Not set';
  }

  String get bookingTime {
    if (invoiceData['timeSlots'] != null && invoiceData['timeSlots'] is List) {
      List<dynamic> slots = invoiceData['timeSlots'];
      if (slots.isNotEmpty) {
        return slots.join(', ');
      }
    }
    return 'Not set';
  }

  String get bookingDuration {
    return invoiceData['totalDuration'] ?? '';
  }

  Future<void> applyPromoCode() async {
    String code = promoCode.text.trim();

    if (code.isEmpty) {
      Get.snackbar(
        AppString.error,
        AppString.promo_code_hints,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      Get.dialog(
        Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                Text(
                  AppString.validat_promo_code,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await ApiService.get(
        "promo-code/$code",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      Get.back();

      print("📡 Promo Code Response: ${response.statusCode}");
      print("📦 Promo Code Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final promoData = response.data['data'];

        num discountValue = promoData['discount'] ?? 0;
        String promoCodeValue = promoData['code'] ?? code;

        discountPercent.value = discountValue.toInt();
        discount.value = ((subTotal.value * discountPercent.value) / 100).round();
        _calculateTotalPrice();
        isPromoApplied.value = true;
        validPromoCode.value = promoCodeValue;

        Get.snackbar(
          AppString.successful,
          '${AppString.code_here_now} RSD ${discount.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          AppString.invalied_code,
          response.data['message'] ?? 'The promo code you entered is not valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      print("❌ Error validating promo code: $e");

      Get.snackbar(
        AppString.error,
        'Failed to validate promo code. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildConfirmRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void processPayment() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          AppString.confirm_pay,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow(AppString.provider, providerName),
            SizedBox(height: 8),
            _buildConfirmRow('${AppString.date}:', bookingDate),
            SizedBox(height: 8),
            _buildConfirmRow('${AppString.time}:', bookingTime),
            SizedBox(height: 8),
            if (creditApplied.value > 0) ...[
              _buildConfirmRow('${AppString.credit_applied}:', 'RSD ${creditApplied.value}'),
              SizedBox(height: 8),
            ],
            _buildConfirmRow('${AppString.payment_pay}:', 'RSD ${totalPrice.value}'),
            SizedBox(height: 16),
            Text(
              AppString.process,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(AppString.cancel, style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              await getCheckoutSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isProcessing.value
                ? CircularProgressIndicator()
                : Text(AppString.payConfirm, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(dynamic responseData) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle, color: Colors.green, size: 64),
              ),
              SizedBox(height: 20),
              Text(
                AppString.booking_successful,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                AppString.booking_confirmed_text,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildSuccessRow(AppString.provider, providerName),
                    Divider(height: 16),
                    _buildSuccessRow(AppString.date, bookingDate),
                    Divider(height: 16),
                    _buildSuccessRow(AppString.time, bookingTime),
                    Divider(height: 16),
                    if (creditApplied.value > 0) ...[
                      _buildSuccessRow(AppString.credit_use, 'RSD ${creditApplied.value}'),
                      Divider(height: 16),
                    ],
                    _buildSuccessRow(AppString.payment_pay, 'RSD ${totalPrice.value}'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  AppString.done_button,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildSuccessRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.black,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Future<void> getCredit() async {
    try {
      final response = await ApiService.get(
        "user/get-rsd",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      print("📡 Credit API Status: ${response.statusCode}");
      print("📦 Credit API Response: ${response.data}");

      if (response.statusCode == 200) {
        dynamic data = response.data;

        if (data is Map && data.containsKey('data')) {
          var rsdValue = data['data']['rsd'];
          if (rsdValue != null) {
            credits.value = double.tryParse(rsdValue.toString()) ?? 0.0;
            _calculateTotalPrice(); // Recalculate when credit is loaded
            print("✅ Credit Updated: ${credits.value}");
          } else {
            print("⚠️ RSD not found in data");
          }
        } else {
          print("⚠️ Invalid data format: ${response.data}");
        }
      } else {
        print("⚠️ Credit API failed: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Error in getCredit(): $e");
    }
  }

  Future<void> getCheckoutSession() async {
    print("Starting checkout session... Token: ${LocalStorage.token}");

    try {
      isProcessing.value = true;

      Get.dialog(
        WillPopScope(
          onWillPop: () async => false,
          child: Center(
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // ✅ Prepare booking request body with only enabled fees
      Map<String, dynamic> bookingBody = {
        "provider": invoiceData['providerId'],
        "services": invoiceData['selectedServiceIds'],
        "date": invoiceData['dateIso'],
        "slots": (invoiceData['slotsData'] as List).map((slot) {
          return {"start": slot['start'], "end": slot['end']};
        }).toList(),
        "amount": amountTotal,
        "weatherFee": isWeatherFeeOn.value ? weatherFee.value : 0,
        "convenienceFee": isConvenienceFeeOn.value ? convenienceFee.value : 0,
        "arrivalFee": isArrivalFeeOn.value ? arrivalFee.value : 0,
        "discount": discount.value,
        "subTotal": subTotal.value,
        "creditApplied": creditApplied.value,
      };
      print("Boking : 😂😂😂😂 ${bookingBody}");

      if (isPromoApplied.value && validPromoCode.value.isNotEmpty) {
        bookingBody["promoCode"] = validPromoCode.value;
      }

      print("📤 Booking Request Body: $bookingBody");

      final response = await ApiService.post(
        "booking",
        body: bookingBody,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
      );

      print("📡 Booking Response Status: ${response.statusCode}");
      print("📦 Booking Response Data: ${response.data}");

      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? checkoutUrl;

        if (response.data['data'] != null && response.data['data'] is String) {
          checkoutUrl = response.data['data'];
        } else if (response.data['checkoutUrl'] != null) {
          checkoutUrl = response.data['checkoutUrl'];
        } else if (response.data['url'] != null) {
          checkoutUrl = response.data['url'];
        } else if (response.data['data'] != null && response.data['data']['url'] != null) {
          checkoutUrl = response.data['data']['url'];
        }

        print("🔗 Checkout URL: $checkoutUrl");

        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          // Payment completed with credit only
          Utils.successSnackBar("Success", "Payment completed successfully using credit");
          Get.find<ProfileController>().getProfile();
          Get.offAllNamed(AppRoutes.homeNav);
          return;
        }

        // Navigate to Stripe WebView
        final result = await Get.to(
          StripeWebViewScreen(checkoutUrl: checkoutUrl),
        );

        if (result == 'success') {
          _showSuccessDialog(response.data);
          Get.find<ProfileController>().getProfile();
          Get.offAllNamed(AppRoutes.homeNav);
        } else if (result == 'failed') {
          Utils.errorSnackBar("Error", "Payment failed. Please try again.");
        } else if (result == 'cancelled') {
          Utils.errorSnackBar("Error", "Payment cancelled. Please try again.");
        }
      } else {
        Get.snackbar(
          'Booking Failed',
          response.data['message'] ?? 'Failed to create booking',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      print("❌ Error creating booking: $e");

      Get.snackbar(
        'Error',
        'Failed to create booking: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    promoCode.dispose();
    super.onClose();
  }
}