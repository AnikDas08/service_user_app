import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompleteProfileController extends GetxController {
  // Text Controllers
  final TextEditingController aboutMeController = TextEditingController();
  final TextEditingController serviceTypeController = TextEditingController();
  final TextEditingController additionalServiceController = TextEditingController();
  final TextEditingController languageController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController pricePerHourController = TextEditingController();

  // Observable variables
  RxDouble serviceDistance = 0.0.obs;
  RxBool isPrivacyAccepted = false.obs;
  RxList<String> uploadedImages = <String>[].obs;
  Rx<File?> profileImage = Rx<File?>(null);

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Static data
  final List<String> serviceTypes = [
    'Hair Cut',
    'Beard Trim',
    'Hair Styling',
    'Hair Wash',
    'Facial',
    'Massage'
  ];

  final List<String> languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Arabic',
    'Bengali'
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize default values if needed
    languageController.text = "English";
  }

  @override
  void onClose() {
    // Dispose controllers
    aboutMeController.dispose();
    serviceTypeController.dispose();
    additionalServiceController.dispose();
    languageController.dispose();
    locationController.dispose();
    priceController.dispose();
    pricePerHourController.dispose();
    super.onClose();
  }

  // Methods
  void updateServiceDistance(double value) {
    serviceDistance.value = value;
  }

  void togglePrivacyAcceptance() {
    isPrivacyAccepted.value = !isPrivacyAccepted.value;
  }

  void selectFromDropdown(TextEditingController controller, String value) {
    controller.text = value;
    update(); // Update UI
  }

  // Handle profile image upload
  Future<void> handleImageUpload() async {
    try {
      // Show bottom sheet for image source selection
      await _showImageSourceBottomSheet();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload image: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Show image source selection bottom sheet
  Future<void> _showImageSourceBottomSheet() async {
    await Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Select Image Source",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _pickImageFromSource(ImageSource.camera);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Camera"),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    _pickImageFromSource(ImageSource.gallery);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Gallery"),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Pick image from selected source
  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
        Get.snackbar(
          "Success",
          "Profile image updated successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Handle work photos upload
  Future<void> handleWorkPhotosUpload() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFiles.isNotEmpty) {
        // Check if total images don't exceed 10
        if (uploadedImages.length + pickedFiles.length > 10) {
          Get.snackbar(
            "Error",
            "Maximum 10 images allowed. You can add ${10 - uploadedImages.length} more images.",
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Add new images to the list
        for (XFile file in pickedFiles) {
          uploadedImages.add(file.path);
        }

        Get.snackbar(
          "Success",
          "${pickedFiles.length} image(s) uploaded successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green[100],
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to upload work photos: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remove uploaded work photo
  void removeWorkPhoto(int index) {
    if (index >= 0 && index < uploadedImages.length) {
      uploadedImages.removeAt(index);
    }
  }

  bool validateForm() {
    if (aboutMeController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill About Me field");
      return false;
    }
    if (serviceTypeController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please select Service Type");
      return false;
    }
    if (locationController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill Primary Location");
      return false;
    }
    if (priceController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill Price field");
      return false;
    }
    if (pricePerHourController.text.trim().isEmpty) {
      Get.snackbar("Error", "Please fill Price Per Hour field");
      return false;
    }
    if (!isPrivacyAccepted.value) {
      Get.snackbar("Error", "Please accept Privacy Policy and Terms & Conditions");
      return false;
    }
    return true;
  }

  void confirmProfile() {
    if (validateForm()) {
      // Handle profile confirmation
      print("Profile confirmed successfully");
      print("About Me: ${aboutMeController.text}");
      print("Service Type: ${serviceTypeController.text}");
      print("Additional Service: ${additionalServiceController.text}");
      print("Language: ${languageController.text}");
      print("Location: ${locationController.text}");
      print("Service Distance: ${serviceDistance.value.round()} km");
      print("Price: ${priceController.text}");
      print("Price Per Hour: ${pricePerHourController.text}");
      print("Profile Image: ${profileImage.value?.path ?? 'No image selected'}");
      print("Work Photos: ${uploadedImages.length} images uploaded");

      Get.snackbar(
        "Success",
        "Profile completed successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );

      // Navigate to next screen or call API
      // Get.toNamed('/next-screen');
    }
  }
}