import 'package:get/get.dart';

import '../../../../services/api/api_service.dart';

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
  var date = ''.obs;
  var time = ''.obs;
  var duration = '60 Minutes Duration'.obs;
  var amount = ''.obs;
  RxString rating = "".obs;
  RxInt reviewCount = 0.obs;
  String chantId="";

  @override
  void onInit() {
    super.onInit();
    // Get booking ID from arguments
    if (Get.arguments != null && Get.arguments['bookingId'] != null) {
      String fullBookingId = Get.arguments['bookingId'];
      fetchBookingDetails(fullBookingId);
    }
  }

  // Fetch booking details from API
  Future<void> fetchBookingDetails(String id) async {
    isLoading.value = true;

    try {
      final response = await ApiService.get('booking/$id');

      if (response.statusCode == 200 && response.data != null) {
        // API returns data as a List, get the first item
          bookingData.value = response.data['data'][0];
          rating.value = response.data['data'][0]['ratings']["averageRating"].toString()??"";
          reviewCount.value = response.data['data'][0]['ratings']['totalReviews']??0;
          chantId=response.data['data'][0]['chatId']??"";
          _parseBookingData();
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
          int hour = startTime.hour;
          int minute = startTime.minute;
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

  // Cancel booking
  Future<void> cancelBooking() async {
    try {
      // Add your cancel booking API call here
      String fullBookingId = bookingData['_id'] ?? '';
      // final response = await ApiService.put('booking/$fullBookingId/cancel', {});

      print('Booking cancelled: $fullBookingId');

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