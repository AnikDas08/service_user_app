import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../config/route/app_routes.dart';

class AppointmentController extends GetxController {
  // Loading state
  bool isLoading = false;

  // Online status
  bool isOnline = true;

  // Selected filter (0: Upcoming, 1: Pending, 2: Canceled)
  int selectedFilter = 0;

  // Calendar state
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // All bookings from API (raw data)
  List<Map<String, dynamic>> allBookings = [];

  @override
  void onInit() {
    super.onInit();
    selectedDay = DateTime.now();
    fetchAllBookings();
  }

  // Fetch all bookings
  Future<void> fetchAllBookings() async {
    isLoading = true;
    update();

    // Clear existing bookings before fetching new data
    allBookings.clear();

    try {
      await Future.wait([
        fetchBookingsByStatus('Pending'),
        fetchBookingsByStatus('Upcoming'),
        fetchBookingsByStatus('Cancelled'),
      ]);
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Fetch bookings by status
  Future<void> fetchBookingsByStatus(String status) async {
    try {
      // Format selected date for API
      String dateParam = '';
      if (selectedDay != null) {
        DateTime date = selectedDay!;
        // Convert to UTC and format as ISO string
        String formattedDate = DateTime.utc(date.year, date.month, date.day).toIso8601String();
        dateParam = '&date=$formattedDate';
      }

      final response = await ApiService.get('booking?status=$status$dateParam');

      if (response.statusCode==200 && response.data != null) {
        final List<dynamic> bookingsData = response.data['data'] ?? [];

        for (var booking in bookingsData) {
          if (booking is Map<String, dynamic>) {
            allBookings.add(booking);
          }
        }

        update();
      }
    } catch (e) {
      print('Error fetching $status bookings: $e');
    }
  }

  // Toggle online status
  void toggleOnlineStatus() {
    isOnline = !isOnline;
    update();

    if (isOnline) {
      print('User is now online');
    } else {
      print('User is now offline');
    }
  }

  // Change filter tab
  void changeFilter(int index) {
    selectedFilter = index;
    update();
  }

  // Get filtered bookings based on selected filter
  List<Map<String, dynamic>> getFilteredBookings() {
    String statusFilter;
    switch (selectedFilter) {
      case 0: // Upcoming
        statusFilter = 'Upcoming';
        break;
      case 1: // Pending
        statusFilter = 'Pending';
        break;
      case 2: // Canceled
        statusFilter = 'Cancelled';
        break;
      default:
        return allBookings;
    }

    return allBookings.where((booking) {
      String bookingStatus = booking['status']?.toString() ?? '';
      return bookingStatus.toLowerCase() == statusFilter.toLowerCase();
    }).toList();
  }

  // Calendar day selected
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    selectedDay = selectedDate;
    focusedDay = focusedDate;
    update();

    print('Selected date: ${selectedDate.toIso8601String()}');

    // Fetch bookings for the selected date
    fetchAllBookings();
  }

  // Calendar page changed
  void onPageChanged(DateTime focusedDate) {
    focusedDay = focusedDate;
    update();
  }

  // Get parsed user name
  String getUserName(Map<String, dynamic> booking) {
    if (booking['provider'] != null && booking['provider'] is Map) {
      return booking['provider']['name'] ?? 'Customer';
    }
    return 'Customer';
  }

  // Get parsed user image
  String getUserImage(Map<String, dynamic> booking) {
    if (booking['provider'] != null && booking['provider'] is Map) {
      String? imageUrl = booking['provider']['image'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }
    return 'assets/images/item_image.png';
  }

  // Get service categories (comma-separated)
  String getServiceNames(Map<String, dynamic> booking) {
    if (booking['services'] != null && booking['services'] is List) {
      List<String> categoryNames = [];
      for (var service in booking['services']) {
        if (service is Map && service['category'] != null && service['category'] is Map) {
          String? categoryName = service['category']['name'];
          if (categoryName != null && categoryName.isNotEmpty) {
            categoryNames.add(categoryName);
          }
        }
      }
      if (categoryNames.isNotEmpty) {
        return categoryNames.join(', ');
      }
    }
    return 'Service';
  }

  // Get formatted date
  String getFormattedDate(Map<String, dynamic> booking) {
    if (booking['date'] != null) {
      try {
        DateTime date = DateTime.parse(booking['date']);
        return '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}.${date.year}';
      } catch (e) {
        return '08.22.2025';
      }
    }
    return '08.22.2025';
  }

  // Get formatted time (24-hour format)
  String getFormattedTime(Map<String, dynamic> booking) {
    if (booking['slots'] != null && booking['slots'].isNotEmpty) {
      try {
        DateTime startTime = DateTime.parse(booking['slots'][0]['start']);
        int hour = startTime.hour;
        int minute = startTime.minute;
        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      } catch (e) {
        return '10:00';
      }
    }
    return '10:00';
  }

  // Get booking ID (last 4 digits)
  String getBookingId(Map<String, dynamic> booking) {
    if (booking['_id'] != null && booking['_id'].toString().length >= 4) {
      return booking['_id'].toString().substring(booking['_id'].toString().length - 4);
    }
    return '0000';
  }

  // Get full booking ID
  String getFullBookingId(Map<String, dynamic> booking) {
    return booking['_id']?.toString() ?? '';
  }

  // Get amount
  String getAmount(Map<String, dynamic> booking) {
    return booking['amount']?.toString() ?? '0';
  }

  // View booking details
  void viewBookingDetails(Map<String, dynamic> booking) {
    String userName = getUserName(booking);
    print('Viewing booking details for: $userName');

    // If it's a pending booking, navigate to pending details screen
    if (selectedFilter == 1) {
      Get.toNamed(
        AppRoutes.view_detail_pending,
        arguments: {'bookingId': getFullBookingId(booking)},
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: CommonText(
          text: 'Booking Details',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Customer', getUserName(booking)),
            _buildDetailRow('Service', getServiceNames(booking)),
            _buildDetailRow('Date', getFormattedDate(booking)),
            _buildDetailRow('Time', getFormattedTime(booking)),
            _buildDetailRow('Booking ID', getBookingId(booking)),
            _buildDetailRow('Price', 'BDT ${getAmount(booking)}'),
            _buildDetailRow('Status', booking['status']?.toString() ?? 'N/A'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: CommonText(
              text: 'Close',
              fontSize: 14.sp,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: CommonText(
              text: '$label:',
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700]!,
            ),
          ),
          Expanded(
            child: CommonText(
              text: value,
              fontSize: 14.sp,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Accept booking (for pending bookings)
  void acceptBooking(Map<String, dynamic> booking) {
    String bookingId = getFullBookingId(booking);
    print('Accepting booking: $bookingId');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index]['status'] = 'Upcoming';
      update();
    }
  }

  // Reject booking (for pending bookings)
  void rejectBooking(Map<String, dynamic> booking) {
    String bookingId = getFullBookingId(booking);
    print('Rejecting booking: $bookingId');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index]['status'] = 'Cancelled';
      update();
    }
  }

  // Cancel upcoming booking
  void cancelBooking(Map<String, dynamic> booking) {
    String bookingId = getFullBookingId(booking);
    print('Canceling booking: $bookingId');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index]['status'] = 'Cancelled';
      update();
    }
  }

  // Mark booking as completed
  void completeBooking(Map<String, dynamic> booking) {
    String bookingId = getFullBookingId(booking);
    print('Completing booking: $bookingId');
    // Add API call logic here

    allBookings.removeWhere((b) => b['_id'] == booking['_id']);
    update();
  }
}