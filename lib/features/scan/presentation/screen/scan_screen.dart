import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/scan_controller.dart';

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScanController>(
      init: ScanController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Scan')),
          body: const Center(child: Text('Scan Screen')),
        );
      },
    );
  }
}
