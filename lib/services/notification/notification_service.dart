import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

class NotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initLocalNotification() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    var androidInitializationSettings =
    const AndroidInitializationSettings("@mipmap/ic_launcher");
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) {
          // print("Route");
          // Get.toNamed(AppRoute.notification);
        });
  }

  static Future<void> showNotification(dynamic message) async {
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
      //largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'), // App icon as large icon
      icon: '@mipmap/ic_launcher', // Small icon
      ticker: "ticker",
    );

    DarwinNotificationDetails darwinNotificationDetails =
    const DarwinNotificationDetails(
        presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          0, message['title'], message['message'], notificationDetails);
    });
  }
}