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
  bool isLoadingMore = false;

  // Online status
  bool isOnline = true;

  // Selected filter (0: Upcoming, 1: Pending, 2: Canceled)
  int selectedFilter = 0;

  // Calendar state
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // All bookings from API (raw data)
  List<Map<String, dynamic>> allBookings = [];
  RxString name="".obs;
  RxString image="".obs;

  // Pagination data
  Map<String, int> currentPage = {
    'Pending': 1,
    'Upcoming': 1,
    'Canceled': 1,
  };

  Map<String, int> totalPages = {
    'Pending': 1,
    'Upcoming': 1,
    'Canceled': 1,
  };

  Map<String, int> totalItems = {
    'Pending': 0,
    'Upcoming': 0,
    'Canceled': 0,
  };

  // ScrollController for pagination
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    selectedDay = DateTime.now();
    setupScrollListener();
    fetchAllBookings();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // Setup scroll listener for infinite scroll
  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
        // User is near the bottom, load more data
        loadMoreBookings();
      }
    });
  }

  // Fetch all bookings (initial load)
  Future<void> fetchAllBookings() async {
    isLoading = true;
    update();

    // Clear existing bookings and reset pagination
    allBookings.clear();
    currentPage = {
      'Pending': 1,
      'Upcoming': 1,
      'Canceled': 1,
    };

    try {
      await Future.wait([
        fetchBookingsByStatus('Pending', page: 1),
        fetchBookingsByStatus('Upcoming', page: 1),
        fetchBookingsByStatus('Canceled', page: 1),
      ]);
    } catch (e) {
      print('Error fetching bookings: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Load more bookings for current filter
  Future<void> loadMoreBookings() async {
    if (isLoadingMore) return;

    String statusFilter = _getStatusFromFilter(selectedFilter);

    // Check if there are more pages to load
    if (currentPage[statusFilter]! >= totalPages[statusFilter]!) {
      print('No more pages to load for $statusFilter');
      return;
    }

    isLoadingMore = true;
    update();

    try {
      int nextPage = currentPage[statusFilter]! + 1;
      await fetchBookingsByStatus(statusFilter, page: nextPage);
      currentPage[statusFilter] = nextPage;
    } catch (e) {
      print('Error loading more bookings: $e');
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  // Fetch bookings by status with pagination
  Future<void> fetchBookingsByStatus(String status, {int page = 1}) async {
    try {
      // Format selected date for API
      String dateParam = '';
      if (selectedDay != null) {
        DateTime date = selectedDay!;
        // Convert to UTC and format as ISO string
        String formattedDate = DateTime.utc(date.year, date.month, date.day).toIso8601String();
        dateParam = '&date=$formattedDate';
      }

      final response = await ApiService.get('booking?status=$status&page=$page$dateParam');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> bookingsData = response.data['data'] ?? [];

        // Update pagination info
        if (response.data['pagination'] != null) {
          final pagination = response.data['pagination'];
          totalPages[status] = pagination['totalPages'] ?? 1;
          totalItems[status] = pagination['total'] ?? 0;
          print('$status - Page: ${pagination['page']}, Total Pages: ${pagination['totalPages']}, Total Items: ${pagination['total']}');
        }

        for (var booking in bookingsData) {
          if (booking is Map<String, dynamic>) {
            // Avoid duplicates
            if (!allBookings.any((b) => b['_id'] == booking['_id'])) {
              allBookings.add(booking);
            }
          }
        }

        update();
      }
    } catch (e) {
      print('Error fetching $status bookings: $e');
    }
  }

  // Refresh bookings (pull to refresh)
  Future<void> refreshBookings() async {
    await fetchAllBookings();
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

    // Reset scroll position
    if (scrollController.hasClients) {
      scrollController.jumpTo(0);
    }
  }

  // Get status string from filter index
  String _getStatusFromFilter(int filterIndex) {
    switch (filterIndex) {
      case 0: // Upcoming
        return 'Upcoming';
      case 1: // Pending
        return 'Pending';
      case 2: // Canceled
        return 'Canceled';
      default:
        return 'Upcoming';
    }
  }

  // Get filtered bookings based on selected filter
  List<Map<String, dynamic>> getFilteredBookings() {
    String statusFilter = _getStatusFromFilter(selectedFilter);

    return allBookings.where((booking) {
      String bookingStatus = booking['status']?.toString() ?? '';
      return bookingStatus.toLowerCase() == statusFilter.toLowerCase();
    }).toList();
  }

  // Check if there are more pages to load
  bool hasMorePages() {
    String statusFilter = _getStatusFromFilter(selectedFilter);
    return currentPage[statusFilter]! < totalPages[statusFilter]!;
  }

  // Get pagination info text
  String getPaginationInfo() {
    String statusFilter = _getStatusFromFilter(selectedFilter);
    int showing = getFilteredBookings().length;
    int total = totalItems[statusFilter]!;
    return 'Showing $showing of $total';
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
    if (booking['user'] != null && booking['user'] is Map) {
      return booking['user']['name'] ?? 'Customer';
    }
    return 'Customer';
  }

  // Get parsed user image
  String getUserImage(Map<String, dynamic> booking) {
    if (booking['user'] != null && booking['user'] is Map) {
      String? imageUrl = booking['user']['image'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }
    return 'assets/images/item_image.png';
  }

  // Get provider name
  String getProviderName(Map<String, dynamic> booking) {
    if (booking['provider'] != null && booking['provider'] is Map) {
      return booking['provider']['name'] ?? 'Provider';
    }
    return 'Provider';
  }

  // Get provider image
  String getProviderImage(Map<String, dynamic> booking) {
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
      allBookings[index]['status'] = 'Canceled';
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
      allBookings[index]['status'] = 'Canceled';
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