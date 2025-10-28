import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/features/scan/presentation/widgets/review_scan_bottomsheet.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../services/api/api_service.dart';
import '../../data/model/notification_model.dart';
import '../../repository/notification_repository.dart';

class NotificationsController extends GetxController {
  /// Notification List
  List<NotificationModel> notifications = [];

  /// Notification Loading Bar
  bool isLoading = false;

  /// Notification more Data Loading Bar
  bool isLoadingMore = false;

  /// No more notification data
  bool hasNoData = false;

  /// page no here
  int page = 0;

  /// Notification Scroll Controller
  ScrollController scrollController = ScrollController();

  /// Rating value
  RxInt selectedRating = 0.obs;
  String? providerId;

  /// Feedback controller
  TextEditingController feedbackController = TextEditingController();

  /// Current provider ID for review
  String? currentProviderId;

  /// Loading state for review submission
  RxBool isSubmittingReview = false.obs;

  /// Notification More data Loading function
  void moreNotification() {
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (isLoadingMore || hasNoData) return;
        isLoadingMore = true;
        update();
        page++;
        List<NotificationModel> list = await notificationRepository(page);
        if (list.isEmpty) {
          hasNoData = true;
        } else {
          notifications.addAll(list);
        }
        isLoadingMore = false;
        update();
      }
    });
  }

  /// Notification data Loading function
  getNotificationsRepo() async {
    if (isLoading || hasNoData) return;
    isLoading = true;
    update();

    page++;
    List<NotificationModel> list = await notificationRepository(page);
    if (list.isEmpty) {
      hasNoData = true;
    } else {
      notifications.addAll(list);
    }
    isLoading = false;
    update();
  }


  /// Handle notification item click
  void onNotificationTap(NotificationModel item) {
    // Check if title is "Booking Payment Successful"
    print("Id id ${item.title}");
    if (item.title == "Booking Completed Successfully") {
      // Get providerId from notification data
      providerId = item.referenceId?["_id"];
      print("Provider Id 😍😍😍😍 $providerId");
      if (providerId != null) {
        showReviewDialog();
        // Show review dialog
      } else {
        Get.snackbar(
          'Error',
          'Provider information not found',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  /// Set rating
  void setRating(int rating) {
    selectedRating.value = rating;
  }

  /// Show review bottom sheet
  void showReviewBottomSheet(String providerId) {
    // Reset values
    selectedRating.value = 0;
    feedbackController.clear();
    currentProviderId = providerId;

    // Show the review dialog
    //showReviewDialog();
  }

  /// Submit review to API
  Future<void> submitReview() async {
    // Validate rating
    if (selectedRating.value == 0) {
      Get.snackbar(
        'Error',
        'Please select a rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Validate comment
    if (feedbackController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please write a review',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmittingReview.value = true;

      // Prepare request body
      Map<String, dynamic> body = {
        "providerId": providerId,
        "rating": selectedRating.value,
        "comment": feedbackController.text.trim(),
      };

      // Make API call
      final response = await ApiService.post(
        "review",
        body: body,
        header: {
          'Content-Type': 'application/json',
        },
      );

      isSubmittingReview.value = false;

      // Check response
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back(); // Close bottom sheet
        Get.snackbar(
          'Success',
          'Review submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Reset values
        selectedRating.value = 0;
        feedbackController.clear();
        currentProviderId = null;
      } else {
        Get.snackbar(
          'Error',
          response.message ?? 'Failed to submit review',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isSubmittingReview.value = false;
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Notification Controller Instance create here
  static NotificationsController get instance =>
      Get.put(NotificationsController());

  /// Controller on Init
  @override
  void onInit() {
    getNotificationsRepo();
    moreNotification();
    super.onInit();
  }

  /// Dispose controllers
  @override
  void onClose() {
    scrollController.dispose();
    feedbackController.dispose();
    super.onClose();
  }
}