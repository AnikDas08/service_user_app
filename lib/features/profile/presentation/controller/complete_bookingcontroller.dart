import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../services/api/api_service.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../config/route/app_routes.dart';

class CompletedBookingController extends GetxController {
  // Loading state
  bool isLoading = false;
  bool isLoadingMore = false;

  // List for completed bookings
  List<Map<String, dynamic>> completedBookings = [];

  // Pagination data for 'Completed' status
  int currentPage = 1;
  int totalPages = 1;
  int totalItems = 0;

  // ScrollController for pagination
  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    setupScrollListener();
    fetchCompletedBookings();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // Setup scroll listener for infinite scroll
  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreCompletedBookings();
      }
    });
  }

  // Fetch initial completed bookings
  Future<void> fetchCompletedBookings() async {
    isLoading = true;
    update();

    // Clear existing bookings and reset pagination
    completedBookings.clear();
    currentPage = 1;
    totalPages = 1;
    totalItems = 0;

    try {
      await _fetchBookingsByStatus('Completed', page: 1);
    } catch (e) {
      print('Error fetching completed bookings: $e');
    } finally {
      isLoading = false;
      update();
    }
  }

  // Load more completed bookings
  Future<void> loadMoreCompletedBookings() async {
    if (isLoadingMore) return;

    // Check if there are more pages to load
    if (currentPage >= totalPages) {
      print('No more completed pages to load');
      return;
    }

    isLoadingMore = true;
    update();

    try {
      int nextPage = currentPage + 1;
      await _fetchBookingsByStatus('Completed', page: nextPage);
      currentPage = nextPage;
    } catch (e) {
      print('Error loading more completed bookings: $e');
    } finally {
      isLoadingMore = false;
      update();
    }
  }

  // Private method to fetch bookings by status
  Future<void> _fetchBookingsByStatus(String status, {int page = 1}) async {
    try {
      // API call targeting only 'Completed' status
      final response = await ApiService.get('booking?status=$status&page=$page');

      if (response.statusCode == 200) {
        final List<dynamic> bookingsData = response.data['data'] ?? [];

        // Update pagination info
        if (response.data['pagination'] != null) {
          final pagination = response.data['pagination'];
          totalPages = pagination['totalPages'] ?? 1;
          totalItems = pagination['total'] ?? 0;
          print(
              'Completed - Page: ${pagination['page']}, Total Pages: $totalPages, Total Items: $totalItems');
        }

        for (var booking in bookingsData) {
          if (booking is Map<String, dynamic>) {
            // Avoid duplicates
            if (!completedBookings.any((b) => b['_id'] == booking['_id'])) {
              completedBookings.add(booking);
            }
          }
        }

        update();
      }
    } catch (e) {
      print('Error fetching $status bookings: $e');
    }
  }

  // Accessor used by the UI (equivalent to getFilteredBookings in the old controller)
  List<Map<String, dynamic>> getFilteredBookings() {
    // Since this controller only deals with completed bookings, we just return the list.
    return completedBookings;
  }

  // Refresh bookings (pull to refresh)
  Future<void> refreshCompletedBookings() async {
    await fetchCompletedBookings();
  }

  // Get formatted date (UTC to Local conversion)
  String getFormattedDate(Map<String, dynamic> booking) {
    if (booking['date'] != null) {
      try {
        DateTime dateUtc = DateTime.parse(booking['date']);
        DateTime dateLocal = dateUtc.toLocal(); // Convert UTC to Local
        return '${dateLocal.month.toString().padLeft(2, '0')}.${dateLocal.day.toString().padLeft(2, '0')}.${dateLocal.year}';
      } catch (e) {
        print('Error parsing date: $e');
        return 'N/A';
      }
    }
    return 'N/A';
  }

  // Get formatted time range (UTC to Local conversion)
  String getFormattedTimeRange(Map<String, dynamic> booking) {
    if (booking['slots'] != null && booking['slots'].isNotEmpty) {
      try {
        List<String> timeSlots = [];
        for (var slot in booking['slots']) {
          DateTime startTimeUtc = DateTime.parse(slot['start']);
          DateTime endTimeUtc = DateTime.parse(slot['end']);

          // Convert UTC to Local time
          DateTime startTimeLocal = startTimeUtc.toLocal();
          DateTime endTimeLocal = endTimeUtc.toLocal();

          String startFormatted =
              '${startTimeLocal.hour.toString().padLeft(2, '0')}:${startTimeLocal.minute.toString().padLeft(2, '0')}';
          String endFormatted =
              '${endTimeLocal.hour.toString().padLeft(2, '0')}:${endTimeLocal.minute.toString().padLeft(2, '0')}';

          timeSlots.add('$startFormatted - $endFormatted');
        }
        return timeSlots.join(', ');
      } catch (e) {
        print('Error parsing time: $e');
        return 'N/A';
      }
    }
    return 'N/A';
  }

  // Get service categories (comma-separated)
  String getServiceNames(Map<String, dynamic> booking) {
    if (booking['services'] != null && booking['services'] is List) {
      List<String> categoryNames = [];
      for (var service in booking['services']) {
        if (service is Map &&
            service['category'] != null &&
            service['category'] is Map) {
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
    return 'assets/images/item_image.png'; // Default placeholder
  }

  // Get amount
  String getAmount(Map<String, dynamic> booking) {
    return booking['amount']?.toString() ?? '0';
  }

  // Get booking ID (last 4 digits)
  String getBookingId(Map<String, dynamic> booking) {
    if (booking['_id'] != null && booking['_id'].toString().length >= 4) {
      return booking['_id']
          .toString()
          .substring(booking['_id'].toString().length - 4);
    }
    return '0000';
  }

  // Get full booking ID
  String getFullBookingId(Map<String, dynamic> booking) {
    return booking['_id']?.toString() ?? '';
  }

  // Check if there are more pages to load
  bool hasMorePages() {
    return currentPage < totalPages;
  }

  // Get pagination info text
  String getPaginationInfo() {
    num showing = completedBookings.length;
    num total = totalItems;
    return 'Showing $showing of $total';
  }
}