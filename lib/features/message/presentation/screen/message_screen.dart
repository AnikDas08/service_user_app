// screens/message_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chat_message_model.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatControllers controller = Get.put(ChatControllers());

    // Initialize chat data
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return Center(
                  child: CommonText(
                    text: "No messages yet\nStart a conversation!",
                    fontSize: 16,
                    color: AppColors.black400,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                );
              }
              return Expanded(
                child: Obx(() {
                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true, // 🔑 সবসময় নিচ থেকে শুরু
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: controller.messages.isEmpty ? 1 : controller.messages.length,
                    itemBuilder: (context, index) {
                      // যখন লিস্ট ফাঁকা → Placeholder নিচে বসবে
                      if (controller.messages.isEmpty) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(top: Get.height * 0.7), // স্ক্রল করলে উপরে যাবে
                            child: CommonText(
                              text: "No messages yet\nStart a conversation!",
                              fontSize: 16,
                              color: AppColors.black400,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      // যখন মেসেজ আছে → নিচ থেকে দেখাবে
                      final message =
                      controller.messages[controller.messages.length - 1 - index];
                      return _buildMessageBubble(message, controller);
                    },
                  );
                }),
              );

            }),
          ),

          // Message Input Area
          _buildMessageInput(controller),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          CupertinoIcons.back,
          size: 24.sp,
          color: AppColors.textColor,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          // Profile Picture
          ClipOval(
              child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.black50,
                    shape: BoxShape.circle,
                  ),
                  child:Image.asset("assets/images/profile_image.png")
              )
          ),

          SizedBox(width: 12.w),

          // Contact Name
          Expanded(
            child: CommonText(
              text: "Joey Dhon",
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textColor,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ChatControllers controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            // Other person's avatar
            ClipOval(
              child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppColors.black50,
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset("assets/images/profile_image.png")
              ),
            ),
            SizedBox(width: 8.w),
          ],

          // Message Content
          Flexible(
            child: Column(
              crossAxisAlignment: message.isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: () => _showMessageOptions(message, controller),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: Get.width * 0.75,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: message.isMe
                          ? AppColors.red50
                          : AppColors.black50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6.r),
                        topRight: Radius.circular(6.r),
                        bottomLeft: Radius.circular(message.isMe ? 6.r : 0.r),
                        bottomRight: Radius.circular(message.isMe ? 0.r : 6.r),
                      ),
                    ),
                    child: _buildMessageContent(message),
                  ),
                ),
                SizedBox(height: 4.h),
                // Timestamp
                CommonText(
                  text: _formatTime(message.timestamp),
                  fontSize: 12,
                  color: AppColors.black100,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
          ),

          if (message.isMe) SizedBox(width: 8.w),
        ],
      ),
    );
  }
  Widget _buildMessageContent(ChatMessage message) {
    switch (message.type) {
      case MessageType.text:
        return CommonText(
          text: message.message,
          fontSize: 12,
          color: message.isMe ? AppColors.black300 : AppColors.black300,
          textAlign: TextAlign.left,
          maxLines: 100,
        );
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(
                File(message.imagePaths!.first),
                width: 200.w,
                height: 200.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200.w,
                    height: 200.w,
                    color: AppColors.black50,
                    child: Icon(
                      CupertinoIcons.photo,
                      size: 40.sp,
                      color: AppColors.black400,
                    ),
                  );
                },
              ),
            ),
            if (message.message.isNotEmpty) ...[
              SizedBox(height: 8.h),
              CommonText(
                text: message.message,
                fontSize: 16,
                color: message.isMe ? Colors.white : AppColors.textColor,
                textAlign: TextAlign.left,
                maxLines: 100,
              ),
            ],
          ],
        );
      case MessageType.multiImage:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Grid
            SizedBox(
              width: 220.w,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: message.imagePaths!.length > 1 ? 2 : 1,
                  crossAxisSpacing: 4.w,
                  mainAxisSpacing: 4.h,
                  childAspectRatio: 1,
                ),
                itemCount: message.imagePaths!.length > 4 ? 4 : message.imagePaths!.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(message.imagePaths![index]),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.black50,
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 30.sp,
                                color: AppColors.black400,
                              ),
                            );
                          },
                        ),
                      ),
                      // Show +X overlay for additional images
                      if (index == 3 && message.imagePaths!.length > 4)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Center(
                            child: Text(
                              '+${message.imagePaths!.length - 4}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            if (message.message.isNotEmpty) ...[
              SizedBox(height: 8.h),
              CommonText(
                text: message.message,
                fontSize: 16,
                color: message.isMe ? Colors.white : AppColors.textColor,
                textAlign: TextAlign.left,
                maxLines: 100,
              ),
            ],
          ],
        );
    }
  }

  Widget _buildMessageInput(ChatControllers controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.black50,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Attachment button


          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(25.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.4),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ]
              ),
              child: TextField(
                controller: controller.messageController,
                decoration: InputDecoration(
                  hintText: "Type......",
                  hintStyle: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.black400,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onSubmitted: (text) => controller.sendTextMessage(),
                textInputAction: TextInputAction.send,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),

          SizedBox(width: 12.w),
          GestureDetector(
            onTap: () => controller.showImageSourceDialog(),
            child: Container(
              width: 44.w,
              height: 44.w,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.4),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ]
              ),
              child: Icon(
                CupertinoIcons.photo,
                size: 24.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Send button
          GestureDetector(
            onTap: () => controller.sendTextMessage(),
            child: Container(
              padding: EdgeInsets.all(10.w),
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gray.withOpacity(0.6),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ]
              ),
              child: SvgPicture.asset(
                "assets/icons/send_icon.svg",
                color: AppColors.primaryColor,
                height: 24,
                width: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
  void _showMessageOptions(ChatMessage message, ChatControllers controller) {
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
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Message'),
              onTap: () {
                Get.back();
                controller.deleteMessage(message.id);
              },
            ),
            if (message.type != MessageType.text) ...[
              ListTile(
                leading: Icon(Icons.download, color: AppColors.primaryColor),
                title: Text('Save Image'),
                onTap: () {
                  Get.back();
                  // Implement save image functionality
                  Get.snackbar(
                    'Success',
                    'Image saved to gallery',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryColor,
                    colorText: Colors.white,
                  );
                  controller.contactAvatar.value.isNotEmpty ? controller.contactAvatar.value : controller.contactName.value;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'Pm' : 'Am';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }
}