// screens/message_screen.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/other_widgets/common_loader.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/message/data/model/message_model.dart';
import 'package:haircutmen_user_app/services/storage/storage_services.dart';

import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../data/model/chart_message_model.dart';
import '../../data/model/chat_message_model.dart';
import '../controller/message_controller.dart';

class MessageScreen extends StatelessWidget {
  MessageScreen({super.key});

  final MessageController con = MessageController.instance;

  String id = Get.parameters['id'] ?? '';
  String name = "";
  String image = "";

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      con.scrollController = ScrollController();
      con.init(id);
    });
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(),
      body: GetBuilder<MessageController>(
        builder: (controller) => Column(
          children: [
            // Messages List
            Expanded(
              child: controller.isLoading
                  ? CommonLoader()
                  : controller.messages.isEmpty
                  ? Center(
                child: CommonText(
                  text: "No messages yet\nStart a conversation!",
                  fontSize: 16,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              )
                  : ListView.builder(
                controller: controller.scrollController,
                reverse: true,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 8.h,
                ),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),

            // Message Input Area
            _buildMessageInput(controller),
          ],
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
              child: con.image.isNotEmpty
                  ? Image.network(
                ApiEndPoint.socketUrl + con.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    CupertinoIcons.person_fill,
                    color: AppColors.black400,
                    size: 24.sp,
                  );
                },
              )
                  : Icon(
                CupertinoIcons.person_fill,
                color: AppColors.black400,
                size: 24.sp,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Contact Name
          Expanded(
            child: CommonText(
              text: con.name,
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

  Widget _buildMessageBubble(MessageModel message) {
    bool isMe = message.sender.id == LocalStorage.userId;
    return GetBuilder<MessageController>(
      builder: (controller) => Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              // Other person's avatar
              ClipOval(
                child: Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: BoxDecoration(
                    color: AppColors.black50,
                    shape: BoxShape.circle,
                  ),
                  child: message.sender.image.isNotEmpty
                      ? Image.network(
                    ApiEndPoint.socketUrl + message.sender.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                          "assets/images/profile_image.png");
                    },
                  )
                      : Image.asset("assets/images/profile_image.png"),
                ),
              ),
              SizedBox(width: 8.w),
            ],

            // Message Content
            Flexible(
              child: Column(
                crossAxisAlignment:
                isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                        color: isMe ? AppColors.red50 : AppColors.black50,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6.r),
                          topRight: Radius.circular(6.r),
                          bottomLeft: Radius.circular(isMe ? 6.r : 0.r),
                          bottomRight: Radius.circular(isMe ? 0.r : 6.r),
                        ),
                      ),
                      child: _buildMessageContent(message, isMe),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // Timestamp
                  CommonText(
                    text: _formatTime(message.createdAt),
                    fontSize: 12,
                    color: AppColors.black100,
                    fontWeight: FontWeight.w400,
                  ),
                ],
              ),
            ),

            if (isMe) SizedBox(width: 8.w),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(MessageModel message, bool isMe) {
    switch (message.type) {
      case "text":
        return CommonText(
          text: message.text,
          fontSize: 12,
          color: AppColors.black300,
          textAlign: TextAlign.left,
          maxLines: 100,
        );

      case "image":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: message.image.isNotEmpty
                  ? Image.network(
                ApiEndPoint.socketUrl + message.image,
                width: 200.w,
                height: 200.w,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200.w,
                    height: 200.w,
                    color: AppColors.black50,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
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
              )
                  : Container(
                width: 200.w,
                height: 200.w,
                color: AppColors.black50,
                child: Icon(
                  CupertinoIcons.photo,
                  size: 40.sp,
                  color: AppColors.black400,
                ),
              ),
            ),
            if (message.text.isNotEmpty) ...[
              SizedBox(height: 8.h),
              CommonText(
                text: message.text,
                fontSize: 14,
                color: AppColors.black300,
                textAlign: TextAlign.left,
                maxLines: 100,
              ),
            ],
          ],
        );

      case "multiImage":
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Multi Image UI will be here"),
            // You can uncomment your GridView later
          ],
        );

      default:
        return CommonText(
          text: "Unsupported message type",
          fontSize: 12,
          color: AppColors.red,
        );
    }
  }

  Widget _buildMessageInput(MessageController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.black50, width: 0.5)),
      ),
      child: Row(
        children: [
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
                  ),
                ],
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
                onSubmitted: (text) => controller.addNewMessage(),
                textInputAction: TextInputAction.send,
                maxLines: null,
                minLines: 1,
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Image picker button
          InkWell(
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
                  ),
                ],
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
            onTap: () => controller.addNewMessage(),
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
                ],
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

  void _showMessageOptions(MessageModel message, MessageController controller) {
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
                // controller.deleteMessage(message.id);
              },
            ),
            if (message.type == "image") ...[
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
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final amPm = dateTime.hour >= 12 ? 'Pm' : 'Am';
    return '${hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} $amPm';
  }
}