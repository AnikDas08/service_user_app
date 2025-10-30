import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/stripe_web_view_screen.dart';
import 'package:haircutmen_user_app/utils/app_utils.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';

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
  final RxString validPromoCode = ''.obs; // Store valid promo code

  // Dynamic fees from API
  final RxInt weatherFee = 0.obs;
  final RxInt convenienceFee = 0.obs;
  final RxInt arrivalFee = 0.obs;
  final RxDouble credits = 0.0.obs;

  @override
  void onInit() {
    super.onInit();

    // Get invoice data from arguments
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      invoiceData = Get.arguments;
      _parseInvoiceData();
    }

    // Fetch fees from API
    _fetchSystemFees();
    getCredit();

    print("📄 Invoice Data: $invoiceData");
  }

  void _parseInvoiceData() {
    // Extract selected services
    if (invoiceData['selectedServices'] != null) {
      selectedServices = List<Map<String, dynamic>>.from(
        invoiceData['selectedServices'],
      );
    }

    // Calculate subtotal
    int calculatedSubTotal = invoiceData['totalPrice'] ?? 0;
    subTotal.value = calculatedSubTotal;

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

        // Set weather fee
        if (data['weatherFee'] != null) {
          weatherFee.value = data['weatherFee']['amount'] ?? 0;
          print("weateher fee ${weatherFee.value}");
        }

        // Set convenience fee
        if (data['convenienceFee'] != null) {
          convenienceFee.value = data['convenienceFee']['amount'] ?? 0;
        }

        // Set arrival fee
        if (data['arrivalFee'] != null) {
          arrivalFee.value = data['arrivalFee']['amount'] ?? 0;
        }

        // Calculate total price after fees are loaded
        _calculateTotalPrice();

        print("✅ Fees loaded - Weather: ${weatherFee.value}, Convenience: ${convenienceFee.value}, Arrival: ${arrivalFee.value}");
      } else {
        print("⚠️ Failed to load system fees");
        // Calculate with zero fees
        _calculateTotalPrice();
      }
    } catch (e) {
      print("❌ Error fetching system fees: $e");
      // Calculate with zero fees
      _calculateTotalPrice();
    } finally {
      isLoadingFees.value = false;
    }
  }

  void _calculateTotalPrice() {
    // Step 1: Start with SubTotal
    int runningTotal = subTotal.value;
    print("💵 Step 1 - SubTotal: $runningTotal");

    // Step 2: Apply Credit FIRST (subtract from subtotal)
    int creditToApply = credits.value.toInt();
    if (creditToApply > runningTotal) {
      creditToApply = runningTotal; // Don't apply more credit than subtotal
    }
    runningTotal -= creditToApply;
    creditApplied.value = creditToApply; // Store applied credit
    print("💵 Step 2 - After Credit ($creditToApply): $runningTotal");

    // Step 3: Subtract Discount (from promo code)
    runningTotal -= discount.value;
    print("💵 Step 3 - After Discount (${discount.value}): $runningTotal");

    // Step 4: Add all Fees
    runningTotal += weatherFee.value;
    print("💵 Step 4a - After Weather Fee (${weatherFee.value}): $runningTotal");

    runningTotal += convenienceFee.value;
    print("💵 Step 4b - After Convenience Fee (${convenienceFee.value}): $runningTotal");

    runningTotal += arrivalFee.value;
    print("💵 Step 4c - After Arrival Fee (${arrivalFee.value}): $runningTotal");

    // ✅ DON'T set to 0 if negative - show the actual negative value in UI
    totalPrice.value = runningTotal;

    print("💵 ============ FINAL CALCULATION ============");
    print("💵 SubTotal: ${subTotal.value}");
    print("💵 - Credit Applied: $creditToApply");
    print("💵 - Discount: ${discount.value}");
    print("💵 + Weather Fee: ${weatherFee.value}");
    print("💵 + Convenience Fee: ${convenienceFee.value}");
    print("💵 + Arrival Fee: ${arrivalFee.value}");
    print("💵 = TOTAL: ${totalPrice.value}");
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
        'Error',
        'Please enter a promo code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Show loading indicator
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
                  'Validating promo code...',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Call API to validate promo code
      final response = await ApiService.get(
        "promo-code/$code",
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
        },
      );

      Get.back(); // Close loading dialog

      print("📡 Promo Code Response: ${response.statusCode}");
      print("📦 Promo Code Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final promoData = response.data['data'];

        // Extract discount percentage and promo code
        int discountValue = promoData['discount'] ?? 0;
        String promoCodeValue = promoData['code'] ?? code;

        discountPercent.value = discountValue;
        discount.value = ((subTotal.value * discountPercent.value) / 100).round();
        _calculateTotalPrice();
        isPromoApplied.value = true;
        validPromoCode.value = promoCodeValue; // Store the valid promo code

        Get.snackbar(
          'Success',
          'Promo code applied! You saved RSD ${discount.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Invalid Code',
          response.data['message'] ?? 'The promo code you entered is not valid',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      print("❌ Error validating promo code: $e");

      Get.snackbar(
        'Error',
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
    // ✅ Allow payment even if total is 0 or negative
    // Show payment confirmation dialog
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Confirm Payment',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConfirmRow('Provider:', providerName),
            SizedBox(height: 8),
            _buildConfirmRow('Date:', bookingDate),
            SizedBox(height: 8),
            _buildConfirmRow('Time:', bookingTime),
            SizedBox(height: 8),
            _buildConfirmRow(
                'Amount:',
                totalPrice.value < 0
                    ? '-RSD ${totalPrice.value.abs()}' // ✅ Show negative with minus sign
                    : 'RSD ${totalPrice.value}'
            ),
            SizedBox(height: 16),
            Text(
              'Do you want to proceed with the payment?',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
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
                : Text('Confirm & Pay', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Future<void> _createBooking() async {
    try {
      isProcessing.value = true;

      // Show loading dialog
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
                  Text(
                    'Processing your booking...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Prepare booking request body
      Map<String, dynamic> bookingBody = {
        "provider": invoiceData['providerId'],
        "services": invoiceData['selectedServiceIds'],
        "date": invoiceData['dateIso'],
        "slots":
        (invoiceData['slotsData'] as List).map((slot) {
          return {"start": slot['start'], "end": slot['end']};
        }).toList(),
        "amount": totalPrice.value,
      };

      // Add promo code if valid and applied
      if (isPromoApplied.value && validPromoCode.value.isNotEmpty) {
        bookingBody["promo_code"] = validPromoCode.value;
      }

      print("📤 Booking Request Body: $bookingBody");

      // Make API call
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

      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Booking successful
        _showSuccessDialog(response.data);
      } else {
        // Booking failed
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
      Get.back(); // Close loading dialog if open
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
                'Booking Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Your booking has been confirmed',
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
                    _buildSuccessRow('Provider', providerName),
                    Divider(height: 16),
                    _buildSuccessRow('Date', bookingDate),
                    Divider(height: 16),
                    _buildSuccessRow('Time', bookingTime),
                    Divider(height: 16),
                    _buildSuccessRow('Amount Paid', 'RSD ${totalPrice.value}'),
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
                  Get.back(); // Close success dialog
                  Get.back(); // Go back to previous screen
                  // Optionally navigate to bookings or home
                  // Get.offAllNamed(AppRoutes.homeNav);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Done',
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

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;

        // 🔹 কখনো কখনো response.data আবারও nested হতে পারে
        if (data is Map && data.containsKey('data')) {
          var rsdValue = data['data']['rsd'];
          if (rsdValue != null) {
            credits.value = double.tryParse(rsdValue.toString()) ?? 0.0;
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

      // Show loading dialog
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
                  Text(
                    'Processing your booking...',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Prepare booking request body
      Map<String, dynamic> bookingBody = {
        "provider": invoiceData['providerId'],
        "services": invoiceData['selectedServiceIds'],
        "date": invoiceData['dateIso'],
        "slots": (invoiceData['slotsData'] as List).map((slot) {
          return {"start": slot['start'], "end": slot['end']};
        }).toList(),
        "amount": totalPrice.value, // ✅ Send actual value (can be negative)
        "weatherFee": weatherFee.value,
        "convenienceFee": convenienceFee.value,
        "arrivalFee": arrivalFee.value,
        "discount": discount.value,
        "subTotal": subTotal.value,
      };

      // Add promo code if valid and applied
      if (isPromoApplied.value && validPromoCode.value.isNotEmpty) {
        bookingBody["promoCode"] = validPromoCode.value;
      }

      print("📤 Booking Request Body: $bookingBody");

      // Make API call
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

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data == null) {
          throw Exception("Response data is null");
        }

        // Check for different possible response structures
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
          Get.snackbar("Payment", response.message);
          Get.back();
          return;
        }

        // Navigate to Stripe WebView
        final result = await Get.to(
          StripeWebViewScreen(checkoutUrl: checkoutUrl),
        );

        if (result == 'success') {
          _showSuccessDialog(response.data);
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