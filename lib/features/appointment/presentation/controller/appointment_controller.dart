import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../data/model/booking_model.dart';


class AppointmentController extends GetxController {
  // Online status
  bool isOnline = true;

  // Selected filter (0: Upcoming, 1: Pending, 2: Canceled)
  int selectedFilter = 0;

  // Calendar state
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  // Sample booking data
  List<BookingModel> allBookings = [
    BookingModel(
      customerName: 'Angle Maria',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1256',
      price: '2500',
      profileImage: 'assets/images/customer1.jpg',
      status: BookingStatus.upcoming,
    ),
    BookingModel(
      customerName: 'MD SHAKIR AHMED',
      service: 'Haircut',
      date: '08.22.2025',
      time: '11:00 AM',
      bookingId: '1268',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.upcoming,
    ),
    BookingModel(
      customerName: 'Md Naimul Hasan',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1256',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.upcoming,
    ),
    BookingModel(
      customerName: 'Md Naimul Hasan',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1256',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.upcoming,
    ),
    BookingModel(
      customerName: 'Md Ananta Khan',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1270',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.pending,
    ),
    BookingModel(
      customerName: 'Md Ananta Khan',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1270',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.pending,
    ),
    BookingModel(
      customerName: 'Md Ananta Khan',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1270',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.pending,
    ),
    BookingModel(
      customerName: 'Md Delwar Hossain',
      service: 'Haircut',
      date: '08.22.2025',
      time: '10:00 AM',
      bookingId: '1272',
      price: '2500',
      profileImage: 'assets/images/item_image.png',
      status: BookingStatus.canceled,
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedDay = DateTime.now();
  }

  // Toggle online status
  void toggleOnlineStatus() {
    isOnline = !isOnline;
    update();

    // You can add additional logic here like API calls
    if (isOnline) {
      print('User is now online');
      // Call API to set status online
    } else {
      print('User is now offline');
      // Call API to set status offline
    }
  }

  // Change filter tab
  void changeFilter(int index) {
    selectedFilter = index;
    update();
  }

  // Get filtered bookings based on selected filter
  List<BookingModel> getFilteredBookings() {
    switch (selectedFilter) {
      case 0: // Upcoming
        return allBookings.where((booking) => booking.status == BookingStatus.upcoming).toList();
      case 1: // Pending
        return allBookings.where((booking) => booking.status == BookingStatus.pending).toList();
      case 2: // Canceled
        return allBookings.where((booking) => booking.status == BookingStatus.canceled).toList();
      default:
        return allBookings;
    }
  }

  // Calendar day selected
  void onDaySelected(DateTime selectedDate, DateTime focusedDate) {
    selectedDay = selectedDate;
    focusedDay = focusedDate;
    update();

    // You can add logic to filter bookings by selected date
    print('Selected date: ${selectedDate.toIso8601String()}');
  }

  // Calendar page changed
  void onPageChanged(DateTime focusedDate) {
    focusedDay = focusedDate;
    update();
  }

  // View booking details
  void viewBookingDetails(BookingModel booking) {
    print('Viewing booking details for: ${booking.customerName}');

    // Navigate to booking details page
    // Get.to(() => BookingDetailsScreen(booking: booking));

    // Or show a dialog with booking details
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
            _buildDetailRow('Customer', booking.customerName),
            _buildDetailRow('Service', booking.service),
            _buildDetailRow('Date', booking.date),
            _buildDetailRow('Time', booking.time),
            _buildDetailRow('Booking ID', booking.bookingId),
            _buildDetailRow('Price', 'BDT ${booking.price}'),
            _buildDetailRow('Status', booking.status.name.capitalize!),
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
  void acceptBooking(BookingModel booking) {
    print('Accepting booking: ${booking.bookingId}');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index] = BookingModel(
        customerName: booking.customerName,
        service: booking.service,
        date: booking.date,
        time: booking.time,
        bookingId: booking.bookingId,
        price: booking.price,
        profileImage: booking.profileImage,
        status: BookingStatus.upcoming,
      );
      update();
    }
  }

  // Reject booking (for pending bookings)
  void rejectBooking(BookingModel booking) {
    print('Rejecting booking: ${booking.bookingId}');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index] = BookingModel(
        customerName: booking.customerName,
        service: booking.service,
        date: booking.date,
        time: booking.time,
        bookingId: booking.bookingId,
        price: booking.price,
        profileImage: booking.profileImage,
        status: BookingStatus.canceled,
      );
      update();
    }
  }

  // Cancel upcoming booking
  void cancelBooking(BookingModel booking) {
    print('Canceling booking: ${booking.bookingId}');
    // Add API call logic here

    // Update booking status locally
    final index = allBookings.indexOf(booking);
    if (index != -1) {
      allBookings[index] = BookingModel(
        customerName: booking.customerName,
        service: booking.service,
        date: booking.date,
        time: booking.time,
        bookingId: booking.bookingId,
        price: booking.price,
        profileImage: booking.profileImage,
        status: BookingStatus.canceled,
      );
      update();
    }
  }

  // Mark booking as completed
  void completeBooking(BookingModel booking) {
    print('Completing booking: ${booking.bookingId}');
    // Add API call logic here

    // You can add a completed status or remove from list
    allBookings.removeWhere((b) => b.bookingId == booking.bookingId);
    update();
  }
}