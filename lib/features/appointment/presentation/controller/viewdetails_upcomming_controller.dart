// Complete ViewdetailsUpcommingController with penalty time support

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';
import 'appointment_controller.dart';

class ViewdetailsUpcommingController extends GetxController {
  // Loading state - make it observable
  var isLoading = false.obs;

  // Booking details - store raw API data
  var bookingData = <String, dynamic>{}.obs;

  // Parsed fields for easy access - make them observable
  var bookingId = ''.obs;
  var providerName = '';
  var providerImage = '';
  var providerLocation = ''.obs;
  var serviceName = ''.obs;
  var description = '';
  var image = '';
  var date = ''.obs;
  var time = ''.obs;
  var duration = '60 ${AppString.minutes_duration_text}'.obs;
  var amount = ''.obs;
  var subTotal = ''.obs;
  var avgDuration = ''.obs;
  RxString rating = "".obs;
  RxInt reviewCount = 0.obs;
  String chantId = "";

  // Penalty time from system settings
  var penaltyTime = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch penalty time from system API
    _fetchSystemFees();

    // Get booking ID from arguments
    if (Get.arguments != null && Get.arguments['bookingId'] != null) {
      String fullBookingId = Get.arguments['bookingId'];
      fetchBookingDetails(fullBookingId);
    }
  }

  // Fetch system fees including penalty time
  Future<void> _fetchSystemFees() async {
    try {
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
        // Store penalty time (in hours)
        penaltyTime.value = data['penaltyTime'] ?? 0;
        print("⏰ Penalty Time: ${penaltyTime.value} hours");
      }
    } catch (e) {
      print("❌ Error fetching system fees: $e");
    }
  }

  // Fetch booking details from API
  Future<void> fetchBookingDetails(String id) async {
    isLoading.value = true;

    try {
      final response = await ApiService.get('booking/$id');

      if (response.statusCode == 200) {
        // API returns data as a List, get the first item
        bookingData.value = response.data['data'][0];
        rating.value = (response.data['data'][0]['ratings']["averageRating"] ?? 0).toStringAsFixed(2);
        reviewCount.value = response.data['data'][0]['ratings']['totalReviews'] ?? 0;
        chantId = response.data['data'][0]['chatId'] ?? "";
        description = response.data['data'][0]['bookingDescription'] ?? "N/A";
        image=response.data["data"][0]["image"]??"";
        _parseBookingData();
      }
    } catch (e) {
      print('❌ Error fetching booking details: $e');
      Get.snackbar(
        AppString.error,
        AppString.failed_fetch_booking,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Parse booking data from API response
  void _parseBookingData() {
    // Provider details
    if (bookingData['provider'] != null && bookingData['provider'] is Map) {
      providerName = bookingData['provider']['name'] ?? 'Provider';
      providerImage = bookingData['provider']['image'] ?? '';
      providerLocation.value = bookingData['provider']['primaryLocation'] ?? 'Location';
    }

    print("provider name : 😍😍😍😍${providerName}");

    // Service name from category
    if (bookingData['services'] != null && bookingData['services'] is List) {
      List<String> categoryNames = [];
      for (var service in bookingData['services']) {
        if (service is Map && service['category'] != null && service['category'] is Map) {
          String? categoryName = service['category']['name'];
          if (categoryName != null && categoryName.isNotEmpty) {
            categoryNames.add(categoryName);
          }
        }
      }
      if (categoryNames.isNotEmpty) {
        serviceName.value = categoryNames.join(', ');
      } else {
        serviceName.value = 'Service';
      }
    } else {
      serviceName.value = 'Service';
    }

    // ✅ FIX: Parse date and convert UTC to Local
    if (bookingData['date'] != null) {
      try {
        // Parse UTC date from API
        DateTime dateTimeUtc = DateTime.parse(bookingData['date']);

        // Convert UTC to Local
        DateTime dateTimeLocal = dateTimeUtc.toLocal();

        // Use local date for display
        date.value = '${dateTimeLocal.day.toString().padLeft(2, '0')}.${dateTimeLocal.month.toString().padLeft(2, '0')}.${dateTimeLocal.year}';
      } catch (e) {
        date.value = '00.00.0000';
      }
    }

    // ✅ FIX: Parse time (start time) and convert UTC to Local - 24 hour format
    if (bookingData['slots'] != null && bookingData['slots'].isNotEmpty) {
      try {
        List<String> timeSlots = [];

        for (var slot in bookingData['slots']) {
          // Parse UTC time from API
          DateTime startTimeUtc = DateTime.parse(slot['start']);

          // Convert UTC to Local time
          DateTime startTimeLocal = startTimeUtc.toLocal();

          // Use local time for display
          int hour = startTimeLocal.hour;
          int minute = startTimeLocal.minute;

          String formattedTime = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
          timeSlots.add(formattedTime);
        }

        // Join all time slots with comma
        time.value = timeSlots.join(', ');
      } catch (e) {
        time.value = '10:00';
      }
    }

    // Duration is always 1 hour (60 minutes)
    int avgDurationMinutes = bookingData['provider']?['avgDuration'] ?? 60;
    duration.value = _minutesToDurationLabel(avgDurationMinutes);

    // Amount
    amount.value = bookingData['amount']?.toString() ?? '0';
    subTotal.value = bookingData['subTotal']?.toString() ?? '0';
    avgDuration.value = bookingData['provider']?['avgDuration']?.toString() ?? '0';

    // Booking ID (last 4 digits)
    if (bookingData['_id'] != null && bookingData['_id'].toString().length >= 4) {
      bookingId.value = bookingData['_id'].toString().substring(bookingData['_id'].toString().length - 4);
    }
  }

  // Check if the current time is AFTER the booking started
  bool isPastOrder() {
    try {
      if (bookingData['slots'] == null || bookingData['slots'].isEmpty) return false;
      DateTime bookingStartTimeLocal = DateTime.parse(bookingData['slots'][0]['start']).toLocal();
      return DateTime.now().isAfter(bookingStartTimeLocal);
    } catch (e) {
      return false;
    }
  }

  // Check if the current time is inside the Penalty Window (Deadline < Current < Start)
  bool isWithinPenaltyTime() {
    try {
      if (bookingData['slots'] == null || bookingData['slots'].isEmpty) return false;

      DateTime bookingStartTimeLocal = DateTime.parse(bookingData['slots'][0]['start']).toLocal();
      DateTime penaltyDeadline = bookingStartTimeLocal.subtract(Duration(hours: penaltyTime.value));
      DateTime currentTime = DateTime.now();

      return currentTime.isAfter(penaltyDeadline) && currentTime.isBefore(bookingStartTimeLocal);
    } catch (e) {
      return false;
    }
  }

  // Helper to check if a penalty or restriction applies (Both Past and Late)
  bool shouldShowPenaltyMessage() {
    return isPastOrder() || isWithinPenaltyTime();
  }

  // Get the appropriate cancellation message
  String getCancellationMessage() {
    // If it's a past order OR within the penalty window, show the detailed penalty message
    if (shouldShowPenaltyMessage()) {
      return AppString.cancel_booking_detail;
    }

    // Otherwise, show the standard appointment text
    return AppString.appointment_booking;
  }

  // Cancel booking
  Future<void> cancelBooking() async {
    try {
      String fullBookingId = bookingData['_id'] ?? '';

      if (fullBookingId.isEmpty) {
        Get.snackbar(
          AppString.error,
          AppString.valid_booking_id,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Make DELETE API call to cancel booking
      final response = await ApiService.delete('booking/$fullBookingId');

      if (response.statusCode == 200) {
        print('✅ Booking cancelled successfully: $fullBookingId');

        // Refresh appointments list
        Get.find<AppointmentController>().fetchAllBookings();

        // Navigate back to home
        Get.offAllNamed(AppRoutes.homeNav);

        // Show success message
        Get.snackbar(
          AppString.successful,
          AppString.booking_cancel_successful,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? 'Failed to cancel booking',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('❌ Error cancelling booking: $e');
      Get.snackbar(
        AppString.error,
        AppString.failed_booking,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  String _minutesToDurationLabel(int minutes) {
    switch (minutes) {
      case 30: return '30 ${AppString.minutes_duration_text}';
      case 60: return '1 Hour';
      case 90: return '1 Hour 30 ${AppString.minutes_duration_text}';
      case 120: return '2 Hour';
      case 150: return '2 Hour 30 ${AppString.minutes_duration_text}';
      case 180: return '3 Hour';
      default: return '$minutes ${AppString.minutes_duration_text}';
    }
  }
}