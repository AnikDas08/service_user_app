import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/stripe_web_view_screen.dart';
import 'package:haircutmen_user_app/utils/app_utils.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import '../../../../utils/constants/app_colors.dart';

class InvoiceController extends GetxController {
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

  @override
  void onInit() {
    super.onInit();

    // Get invoice data from arguments
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      invoiceData = Get.arguments;
      _parseInvoiceData();
    }

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
    totalPrice.value = calculatedSubTotal;

    print("💰 SubTotal: ${subTotal.value}");
    print("🎯 Services: $selectedServices");
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

  void applyPromoCode() {
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

    // Mock promo code validation - Replace with actual API call
    Map<String, int> promoCodes = {
      'SAVE10': 10,
      'SAVE20': 20,
      'SAVE30': 30,
      'DISCOUNT15': 15,
      'SPECIAL25': 25,
    };

    String upperCode = code.toUpperCase();

    if (promoCodes.containsKey(upperCode)) {
      discountPercent.value = promoCodes[upperCode]!;
      discount.value = ((subTotal.value * discountPercent.value) / 100).round();
      totalPrice.value = subTotal.value - discount.value;
      isPromoApplied.value = true;

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
        'The promo code you entered is not valid',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
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
    // Validate payment
    if (totalPrice.value <= 0) {
      Get.snackbar(
        'Error',
        'Invalid payment amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

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
            _buildConfirmRow('Amount:', 'RSD ${totalPrice.value}'),
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
            onPressed: () {
              // Get.back(); // Close dialog
              // _createBooking();
              //stripe payment
              getCheckoutSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Confirm & Pay', style: TextStyle(color: Colors.white)),
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

  Future<void> getCheckoutSession() async {
    try {
      isProcessing.value = true;
      update();
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

      // Make API call
      final response = await ApiService.post(
        "booking",
        body: bookingBody,
        header: {
          "Authorization": "Bearer ${LocalStorage.token}",
          "Content-Type": "application/json",
        },
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Booking successful

        final result = await Get.to(
          StripeWebViewScreen(checkoutUrl: response.data['data']),
        );

        if (result == 'success') {
          _showSuccessDialog(response.data);
          Get.offAllNamed(AppRoutes.homeNav);
        }
        if (result == 'failed') {
          Utils.errorSnackBar("Error", "Payment failed. Please try again.");
        }
        if (result == 'cancelled') {
          Utils.errorSnackBar("Error", "Payment cancelled. Please try again.");
        }
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
