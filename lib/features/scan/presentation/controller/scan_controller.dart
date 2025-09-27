import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../widgets/qr_dialog_screen.dart';


class QRScannerController extends GetxController {
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  var isFlashOn = false.obs;
  var isScanning = true.obs;
  var scannedData = ''.obs;
  var selectedRating = 0.obs;
  TextEditingController feedbackController = TextEditingController();
  TextEditingController barController = TextEditingController();


  @override
  void dispose() {
    controller?.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  // Add these methods to your QRScannerController class
  void setRating(int rating) {
    selectedRating.value = rating;
  }

  void submitFeedback() {
    // Handle feedback submission logic here
    print('Rating: ${selectedRating.value}');
    print('Feedback: ${feedbackController.text}');

    // Close the bottom sheet
    Get.back();

    // Reset values
    selectedRating.value = 0;
    feedbackController.clear();

    // You can add API call or other logic here
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (isScanning.value && scanData.code != null) {
        onCodeScanned(scanData.code!);
      }
    });
  }

  void onCodeScanned(String code) {
    if (!isScanning.value) return;

    isScanning.value = false;
    scannedData.value = code;

    // Vibrate on successful scan
    HapticFeedback.lightImpact();

    // Show success dialog
    showSuccessDialog();
  }

  void showSuccessDialog() {
    showQrDialog();
  }

  void toggleFlash() async {
    if (controller != null) {
      await controller!.toggleFlash();
      isFlashOn.value = !isFlashOn.value;
    }
  }

  void resumeScanning() {
    isScanning.value = true;
    controller?.resumeCamera();
  }

  void pauseScanning() {
    isScanning.value = false;
    controller?.pauseCamera();
  }

  void scanFromGallery() {
    // Implementation for scanning from gallery
    // You can use image_picker and qr_code_tools packages
    print('Scan from gallery functionality');
  }
}

