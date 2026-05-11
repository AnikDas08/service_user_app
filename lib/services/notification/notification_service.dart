import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotification() async {
    // Request Android permission
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    // Request iOS permission
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    var androidInitializationSettings =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          // print("Route");
          // Get.toNamed(AppRoute.notification);
        });
  }

  static Future<void> showNotification(dynamic message) async {
    try {
      // Extract notification data safely
      String title = message['title']?.toString() ?? 'New Notification';
      String body = message['message']?.toString() ?? message['body']?.toString() ?? 'You have a new message';

      // Show snackbar for immediate feedback
      print("sender ${message["sender"]}");
      if(message['sender']["_id"]!=LocalStorage.userId){
        Get.snackbar(title, body);
      }

      // Create Android notification details
      AndroidNotificationChannel channel = AndroidNotificationChannel(
          Random.secure().nextInt(10000).toString(),
          "High Importance Notification",
          importance: Importance.max);

      AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: "your channel Description",
        importance: Importance.high,
        priority: Priority.high,
        color: AppColors.primaryColor,
        colorized: true, // Makes the notification background colored
        icon: '@mipmap/ic_launcher', // Small icon
        ticker: "ticker",
      );

      // Create iOS notification details with proper configuration
      DarwinNotificationDetails darwinNotificationDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        subtitle: body,
        threadIdentifier: "velodora_notifications",
      );

      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails, iOS: darwinNotificationDetails);

      // Show notification with proper delay
      Future.delayed(Duration.zero, () async {
        try {
          await flutterLocalNotificationsPlugin.show(
              Random.secure().nextInt(10000), // Use random ID to avoid conflicts
              title,
              body,
              notificationDetails,
              payload: message.toString() // Pass full message as payload
          );
        } catch (e) {
          print("Error showing notification: $e");
        }
      });
    } catch (e) {
      print("Error in showNotification: $e");
      // Fallback to simple notification
      Get.snackbar("Notification", message['title']?.toString() ?? 'New Message');
    }
  }
}