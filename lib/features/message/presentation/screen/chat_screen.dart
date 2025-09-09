import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haircutmen_user_app/utils/app_bar/custom_appbars.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

import '../../../../component/text/common_text.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../data/model/message_model.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - you can replace this with your actual data
    final List<MessageItem> messages = [
      MessageItem(
        name: "John Doe",
        message: "Hi Can I Help You Today?",
        time: "09:02 Am",
        avatar:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face",
        unreadCount: 2,
      ),
      MessageItem(
        name: "John Doe",
        message: "Hey, how are you doing?",
        time: "08:45 Am",
        avatar:
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
        unreadCount: 1,
      ),
      MessageItem(
        name: "Jane Smith",
        message: "The meeting is scheduled for tomorrow",
        time: "Yesterday",
        avatar:
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
      ),
      MessageItem(
        name: "Mike Johnson",
        message: "Thanks for your help!",
        time: "Yesterday",
        avatar:
            "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop&crop=face",
      ),
      MessageItem(
        name: "Sohidul Hasan",
        message: "Hi Can I Help You Today?",
        time: "09:02 Am",
        avatar:
            "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face",
        unreadCount: 2,
      ),
      MessageItem(
        name: "John Doe",
        message: "Hey, how are you doing?",
        time: "08:45 Am",
        avatar:
            "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face",
        unreadCount: 1,
      ),
      MessageItem(
        name: "Jane Smith",
        message: "The meeting is scheduled for tomorrow",
        time: "Yesterday",
        avatar:
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
      ),
      MessageItem(
        name: "Jane Smith",
        message: "The meeting is scheduled for tomorrow",
        time: "Yesterday",
        avatar:
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
      ),
      MessageItem(
        name: "Jane Smith",
        message: "The meeting is scheduled for tomorrow",
        time: "Yesterday",
        avatar:
            "https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face",
      ),
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppString.message_text),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Container(
                height: 38.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 12.w),
                      child: Icon(
                        CupertinoIcons.search,
                        size: 18.sp,
                        color: AppColors.black100,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: AppString.search_text,
                          hintStyle: GoogleFonts.roboto(
                            fontSize: 14.sp,
                            color: AppColors.black100,
                            fontWeight: FontWeight.w400,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Message List
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageItem(message);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(MessageItem message) {
    return GestureDetector(
      onTap: (){
        Get.toNamed(AppRoutes.message);
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ClipOval(
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.black100,
                  shape: BoxShape.circle,
                ),
                child:
                    //message.avatar != null
                        /*? Image.network(
                          message.avatar!,
                          width: 50.w,
                          height: 50.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              CupertinoIcons.person_fill,
                              size: 24.sp,
                              color: AppColors.black100,
                            );
                          },
                        )
                        : Icon(
                          CupertinoIcons.person_fill,
                          size: 24.sp,
                          color: AppColors.black100,
                        ),*/
                Image.asset(
                  "assets/images/profile_image.png",
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 12.w),

            // Message Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Name
                      CommonText(
                        text: message.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        textAlign: TextAlign.left,
                      ),

                      // Time
                      CommonText(
                        text: message.time,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black100,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),

                  SizedBox(height:8.h),

                  Row(
                    children: [
                      // Error icon (if exists
                      Icon(
                        CupertinoIcons.arrow_down_left_circle,
                        size: 16.sp,
                        color: AppColors.red500,
                      ),
                      SizedBox(width: 6.w),

                      // Message text
                      Expanded(
                        child: CommonText(
                          text: message.message,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black400,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                      ),

                      // Unread count badge
                      if (message.unreadCount != null &&
                          message.unreadCount! > 0) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.black50,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: CommonText(
                            text: message.unreadCount.toString(),
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
