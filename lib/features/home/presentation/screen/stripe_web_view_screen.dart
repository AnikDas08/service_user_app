import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_nav_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/home_screen.dart';
import 'package:haircutmen_user_app/features/home/presentation/screen/invoice_screen.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewScreen extends StatelessWidget {
  final String checkoutUrl;
  const StripeWebViewScreen({super.key, required this.checkoutUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller:
              WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onNavigationRequest: (request) {
                      if (request.url.contains("success")) {
                       Get.offAllNamed(AppRoutes.homeNav);
                        Get.snackbar(
                          "Success",
                          "Payment successful",
                          backgroundColor: AppColors.success,
                          colorText: AppColors.white,
                        );
                        return NavigationDecision.prevent;
                      } else if (request.url.contains("cancel")) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvoiceScreen(),
                          ),
                        );
                        Get.snackbar(
                          "Cancel",
                          "Payment cancelled",
                          backgroundColor: AppColors.cancel,
                          colorText: AppColors.white,
                        );
                        return NavigationDecision.navigate;
                      }
                      return NavigationDecision.navigate;
                    },
                    onPageStarted: (_) {},
                    onPageFinished: (url) {
                      if (url.contains("success")) {
                        Get.offAllNamed(AppRoutes.homeNav);
                      } else if (url.contains("cancel")) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InvoiceScreen(),
                          ),
                        );
                      }
                    },
                    onWebResourceError: (error) {},
                  ),
                )
                ..loadRequest(Uri.parse(checkoutUrl)),
        ),
      ),
    );
  }
}
