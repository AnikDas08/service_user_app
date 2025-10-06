// screens/message_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../message/data/model/chat_message_model.dart';
import '../controller/contract_support_controller.dart';

class ContractsScreen extends StatelessWidget {
  const ContractsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ContractController controller = Get.put(ContractController());

    // Initialize chat data
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              CustomAppBar(title: "Contracts & Support",),
              // Messages List - MAIN CHANGES HERE
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return Center(
                      child: CommonText(
                        text: 'No messages yet\nStart a conversation!',
                        fontSize: 16,
                        color: AppColors.black400,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: controller.scrollController,
                    // KEY CHANGE: Add reverse: false and ensure proper indexing
                    reverse: true,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      return _buildMessageBubble(message, controller);
                    },
                  );
                }),
              ),

              // Message Input Area
              _buildMessageInput(controller),
            ],
          ),
        ),
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

  Widget _buildMessageBubble(ChatMessage message, ContractController controller) {
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
                          ? AppColors.primaryColor
                          : AppColors.black50,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                        bottomLeft: Radius.circular(message.isMe ? 20.r : 4.r),
                        bottomRight: Radius.circular(message.isMe ? 4.r : 20.r),
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
                  color: AppColors.black400,
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
          text: message.message ?? '',
          fontSize: 16,
          color: message.isMe ? Colors.white : AppColors.textColor,
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

  Widget _buildMessageInput(ContractController controller) {
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
          // Text Input
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.black50,
                borderRadius: BorderRadius.circular(25.r),
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
              padding: EdgeInsets.all(8),
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100.r),
                boxShadow:[ BoxShadow(
                  color: AppColors.black50,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
                ],
              ),
              child: SvgPicture.asset(
                "assets/icons/take_image.svg",
                height: 24.h,
                width: 23.h,
                color: Color(0xff836AB1),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Send button
          GestureDetector(
            onTap: () => controller.sendTextMessage(),
            child: Container(
              width: 40.w,
              height: 40.w,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                boxShadow:[ BoxShadow(
                  color: AppColors.black50,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
                ],
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: SvgPicture.asset(
                "assets/icons/send_icon.svg",
                height: 24.h,
                width: 23.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(ChatMessage message, ContractController controller) {
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