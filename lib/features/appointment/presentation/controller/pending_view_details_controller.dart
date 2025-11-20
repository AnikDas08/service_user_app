import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/appointment_controller.dart';

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
  var duration = '60 Minutes Duration'.obs;
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
          _parseBookingData();
        }
      }
    } catch (e) {
      print('Error fetching booking details: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch booking details',
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

    // Parse date
    if (bookingData['date'] != null) {
      try {
        DateTime dateTime = DateTime.parse(bookingData['date']);
        date.value = '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
      } catch (e) {
        date.value = '00.00.0000';
      }
    }

    // Parse time (start time) - 24 hour format
    if (bookingData['slots'] != null && bookingData['slots'].isNotEmpty) {
      try {
        List<String> timeSlots = [];

        for (var slot in bookingData['slots']) {
          DateTime startTime = DateTime.parse(slot['start']);
          num hour = startTime.hour;
          num minute = startTime.minute;
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
    duration.value = '60 Minutes Duration';

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

      // Get the booking start time
      DateTime bookingStartTime = DateTime.parse(bookingData['slots'][0]['start']);

      // Get current time
      DateTime currentTime = DateTime.now();

      // Calculate the penalty deadline (booking time minus penalty hours)
      DateTime penaltyDeadline = bookingStartTime.subtract(Duration(hours: penaltyTime.value));

      print("🕐 Current Time: $currentTime");
      print("📅 Booking Start Time: $bookingStartTime");
      print("⚠️ Penalty Deadline: $penaltyDeadline");
      print("⏰ Penalty Time: ${penaltyTime.value} hours");

      // Check if current time is after penalty deadline and before booking time
      // This means we're within the penalty period
      bool withinPenalty = currentTime.isAfter(penaltyDeadline) && currentTime.isBefore(bookingStartTime);

      print("💰 Within Penalty Period: $withinPenalty");

      return withinPenalty;

    } catch (e) {
      print("Error checking penalty time: $e");
      return false;
    }
  }

  // Get the appropriate cancellation message
  String getCancellationMessage() {
    if (isWithinPenaltyTime()) {
      return "Are you sure you want to cancel this appointment? Please note, a 30% cancellation fee will apply. If you like to proceed then click yes for cancel.";
    } else {
      return "Are you sure you want to cancel this appointment?";
    }
  }

  // Cancel booking
  Future<void> cancelBooking() async {
    try {
      String fullBookingId = bookingData['_id'] ?? '';

      if (fullBookingId.isEmpty) {
        Get.snackbar(
          'Error',
          'Invalid booking ID',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Make DELETE API call to cancel booking
      final response = await ApiService.delete('booking/$fullBookingId');

      if (response.statusCode == 200) {
        print('Booking cancelled: $fullBookingId');

        Get.find<AppointmentController>().fetchAllBookings();
        Get.offAllNamed(AppRoutes.homeNav);
        Get.snackbar(
          'Success',
          'Booking cancelled successfully',
          snackPosition: SnackPosition.BOTTOM,
        );

      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to cancel booking',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

    } catch (e) {
      print('Error cancelling booking: $e');
      Get.snackbar(
        'Error',
        'Failed to cancel booking',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}