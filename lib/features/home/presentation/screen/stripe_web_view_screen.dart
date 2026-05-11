import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class StripeWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  const StripeWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<StripeWebViewScreen> createState() => _StripeWebViewScreenState();
}

class _StripeWebViewScreenState extends State<StripeWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains("success")) {
              Get.snackbar(
                AppString.successful,
                AppString.payment_successful,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
              Get.offAllNamed(AppRoutes.homeNav);
              return NavigationDecision.prevent;
            } else if (request.url.contains("cancel")) {
              Get.back(result: 'cancelled');
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            if (url.contains("success")) {
              Get.snackbar(
                AppString.successful,
                AppString.payment_successful,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.success,
                colorText: Colors.white,
              );
              Get.offAllNamed(AppRoutes.homeNav);
            } else if (url.contains("cancel")) {
              Get.back(result: 'cancelled');
            }
          },
          onWebResourceError: (error) {
            setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _handleBack() {
    Get.back(result: 'cancelled');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _handleBack();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _handleBack,
          ),
          title: Text(
            AppString.pay_button.tr,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
