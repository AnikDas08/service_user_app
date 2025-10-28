import '../../../config/api/api_end_point.dart';
import '../../../services/api/api_service.dart';
import '../data/model/notification_model.dart';

/// Notification Repository - Fetches notifications from API
Future<List<NotificationModel>> notificationRepository(int page) async {
  try {
    // Make API call using ApiService.get()
    final response = await ApiService.get(
      "${ApiEndPoint.notifications}?page=$page",
      header: {
        'Content-Type': 'application/json',
        // Add authorization token if needed
        // 'Authorization': 'Bearer ${your_token}',
      },
    );

    // Check if API call was successful
    if (response.statusCode == 200 && response.data != null) {
      // Parse the response data
      List<NotificationModel> notifications = [];

      // Handle different response structures
      if (response.data is Map) {
        // If data is wrapped in an object (e.g., {data: [], ...})
        dynamic dataList = response.data['data'] ??
            response.data['notifications'] ??
            response.data['items'];

        // Check if dataList is actually a List before iterating
        if (dataList is List) {
          for (var item in dataList) {
            if (item is Map) {
              notifications.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
      } else if (response.data is List) {
        // If data is directly a list
        List dataList = response.data as List;
        for (var item in dataList) {
          if (item is Map) {
            notifications.add(NotificationModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }

      return notifications;
    } else {
      // API call failed
      print('Error fetching notifications: ${response.message}');
      return [];
    }
  } catch (e) {
// Handle any errors
print('Exception in notificationRepository: $e');
return [];
}
}