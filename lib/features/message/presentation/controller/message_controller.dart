// controllers/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chat_message_model.dart';

class ChatControllers extends GetxController {
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isTyping = false.obs;
  final RxString contactName = ''.obs;
  final RxString contactAvatar = ''.obs;


  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void initializeChat({
    required String name,
    String? avatar,
  }) {
    contactName.value = name;
    contactAvatar.value = avatar ?? '';
  }

  void sendTextMessage() {
    if (messageController.text.trim().isEmpty) return;

    final message = ChatMessage.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: messageController.text.trim(),
      isMe: true,
    );

    messages.add(message);
    messageController.clear();
    _scrollToBottom();

    // Don't simulate automatic responses - only show what user sends
  }

  Future<void> pickAndSendImage() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        final message = ChatMessage.image(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: image.path,
          isMe: true,
        );

        messages.add(message);
        _scrollToBottom();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickAndSendMultipleImages() async {
    try {
      final List<XFile> images = await imagePicker.pickMultiImage(
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        final imagePaths = images.map((image) => image.path).toList();

        final message = ChatMessage.multiImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePaths: imagePaths,
          isMe: true,
        );

        messages.add(message);
        _scrollToBottom();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> takePicture() async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        final message = ChatMessage.image(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: image.path,
          isMe: true,
        );

        messages.add(message);
        _scrollToBottom();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take picture: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent, // 🔑 reverse:true হলে minScrollExtent ব্যবহার করতে হবে
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              leading: Icon(Icons.photo_library, color: AppColors.primaryColor),
              title: Text('Gallery'),
              onTap: () {
                Get.back();
                pickAndSendImage();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.primaryColor),
              title: Text('Multiple Images'),
              onTap: () {
                Get.back();
                pickAndSendMultipleImages();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primaryColor),
              title: Text('Camera'),
              onTap: () {
                Get.back();
                takePicture();
              },
            ),
          ],
        ),
      ),
    );
  }

  void deleteMessage(String messageId) {
    messages.removeWhere((message) => message.id == messageId);
  }

  void clearAllMessages() {
    messages.clear();
  }
}