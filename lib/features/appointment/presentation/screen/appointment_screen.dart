import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/appointment_controller.dart';

class AppointmentScreen extends StatelessWidget {
  const AppointmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(
      init: AppointmentController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text('Appointment')),
          body: const Center(child: Text('Appointment Screen')),
        );
      },
    );
  }
}
