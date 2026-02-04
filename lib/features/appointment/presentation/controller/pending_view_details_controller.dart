import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/appointment_controller.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../config/route/app_routes.dart';
import '../../../../services/api/api_service.dart';
import '../../../../services/storage/storage_services.dart';

class PendingViewDetailsController extends GetxController {
  // Loading state - make it observable
  var isLoading = false.obs;

  // Booking details - store raw API data
  var bookingData = <String, dynamic>{}.obs;

  // Parsed fields for easy access - make them observable
  var bookingId = ''.obs;
  var providerName = ''.obs;
  var providerImage = ''.obs;
  var providerLocation = ''.obs;
  var serviceName = ''.obs;
  var date = ''.obs;
  var time = ''.obs;
  var description = '';
  var image = '';
  var duration = '${AppString.minutes_duration_text}'.obs;
  var amount = ''.obs;
  RxString rating = "".obs;
  RxInt reviewCount = 0.obs;

  // Penalty time from system settings
  var penaltyTime = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get booking ID from arguments
    if (Get.arguments != null && Get.arguments['bookingId'] != null) {
      String fullBookingId = Get.arguments['bookingId'];
      fetchBookingDetails(fullBookingId);
    }
    _fetchSystemFees();
  }

  // Fetch booking details from API
  Future<void> fetchBookingDetails(String id) async {
    isLoading.value = true;

    try {
      final response = await ApiService.get('booking/$id');

      if (response.statusCode == 200) {
        // API returns data as a List, get the first item
        if (response.data['data'] is List && response.data['data'].isNotEmpty) {
          bookingData.value = response.data['data'][0];
          rating.value = response.data['data'][0]['ratings']["averageRating"].toString()??"";
          reviewCount.value = response.data['data'][0]['ratings']['totalReviews']??0;
          description = response.data['data'][0]['bookingDescription'] ?? "N/A";
          image=response.data["data"][0]["image"]??"";
          _parseBookingData();
        }
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      Get.snackbar(
        AppString.error,
        AppString.failed_fetch_booking,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

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
      print("Error fetching system fees: $e");
    }
  }

  // Parse booking data from API response
  // ============================================
// FIX: Update _parseBookingData() method
// Convert UTC date and time to Local time
// ============================================

  void _parseBookingData() {
    // Provider details
    if (bookingData['provider'] != null && bookingData['provider'] is Map) {
      providerName.value = bookingData['provider']['name'] ?? 'Provider';
      providerImage.value = bookingData['provider']['image'] ?? '';
      providerLocation.value = bookingData['provider']['primaryLocation'] ?? 'Location';
    }

    print("provider name : 😍😍😍😍${providerName.value}");

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
    duration.value = '60 ${AppString.minutes_duration_text}';

    // Amount
    amount.value = bookingData['amount']?.toString() ?? '0';

    // Booking ID (last 4 digits)
    if (bookingData['_id'] != null && bookingData['_id'].toString().length >= 4) {
      bookingId.value = bookingData['_id'].toString().substring(bookingData['_id'].toString().length - 4);
    }
  }

  // Check if cancellation is within penalty time
  bool isWithinPenaltyTime() {
    try {
      if (bookingData['slots'] == null || bookingData['slots'].isEmpty) {
        return false;
      }

      // Parse UTC booking start time from API
      // Example: "2025-11-27T20:00:00.000Z" is in UTC
      DateTime bookingStartTimeUtc = DateTime.parse(bookingData['slots'][0]['start']);

      // Convert to local time (Bangladesh time is UTC+6)
      DateTime bookingStartTimeLocal = bookingStartTimeUtc.toLocal();

      // Get current local time
      DateTime currentTime = DateTime.now();

      // Calculate the penalty deadline
      // If penaltyTime = 2 hours, and booking is at 14:00, penalty starts at 12:00
      DateTime penaltyDeadline = bookingStartTimeLocal.subtract(
          Duration(hours: penaltyTime.value)
      );

      print("🕐 Current Time (Local): $currentTime");
      print("📅 Booking Start Time (Local): $bookingStartTimeLocal");
      print("⚠️ Penalty Deadline (Local): $penaltyDeadline");
      print("⏰ Penalty Time: ${penaltyTime.value} hours");

      // Within penalty = Current time is AFTER penalty deadline AND BEFORE booking time
      // Example: If booking is at 14:00, penalty is 2 hours
      // - Penalty starts at: 12:00 (14:00 - 2 hours)
      // - If current time is 13:00 → within penalty (fee applies)
      // - If current time is 11:00 → NOT within penalty (no fee)
      // - If current time is 15:00 → booking already passed
      bool withinPenalty = currentTime.isAfter(penaltyDeadline) &&
          currentTime.isBefore(bookingStartTimeLocal);

      print("💰 Within Penalty Period: $withinPenalty");

      return withinPenalty;

    } catch (e) {
      print("❌ Error checking penalty time: $e");
      return false;
    }
  }

  // Get the appropriate cancellation message
  String getCancellationMessage() {
    if (isWithinPenaltyTime()) {
      // Show penalty message if canceling within penalty time window
      return AppString.cancel_booking_detail;
    } else {
      // Show normal message if canceling outside penalty time window
      return AppString.appointment_booking;
    }
  }

  // Cancel booking
  Future<void> cancelBooking() async {
    try {
      String fullBookingId = bookingData['_id'] ?? '';

      if (fullBookingId.isEmpty) {
        Get.snackbar(
          AppString.error,
          AppString.valid_booking_id,
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
          backgroundColor: Colors.green,
          colorText: Colors.white,
          AppString.booking_cancel_successful,
          snackPosition: SnackPosition.BOTTOM,
        );

      } else {
        Get.snackbar(
          AppString.error,
          response.message ?? 'Failed to cancel booking',
          backgroundColor: Colors.red,
          colorText: Colors.white,
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
}