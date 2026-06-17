import 'package:firebase_core/firebase_core.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/deep_link_handler.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';

import 'app.dart';
import 'config/dependency/dependency_injection.dart';
import 'firebase_options.dart';
import 'package:get_storage/get_storage.dart';
import 'services/notification/notification_service.dart';
import 'services/socket/socket_service.dart';
import 'services/storage/storage_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appLinks = AppLinks();
  // Handle initial link
  final uri = await appLinks.getInitialLink();
  if (uri != null) {
    DeepLinkHandler.pendingId = uri.queryParameters['id'];
  }
  // Handle incoming links
  appLinks.uriLinkStream.listen((uri) {
    String? id = uri.queryParameters['id'];
    if (id != null) {
      DeepLinkHandler.handle(id);
    }
  });

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();
  //await LocalStorage.getAllPrefData();
  await init.tryCatch();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent বা app primary color
      statusBarIconBrightness: Brightness.dark, // Android এর জন্য
      statusBarBrightness: Brightness.light, // iOS এর জন্য
    ),
  );
  runApp(const MyApp());
}

init() async {
  DependencyInjection dI = DependencyInjection();
  dI.dependencies();
  await Future.wait([
    LocalStorage.getAllPrefData(),
    NotificationService.initLocalNotification(),
  ]);
  SocketServices.connectToSocket();
}
