import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';

import '../../../../component/text/common_text.dart';
import '../../../../config/api/api_end_point.dart';
import '../../../../config/route/app_routes.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../../data/model/chat_list_model.dart';
import '../controller/chat_controller.dart';

class ChatListScreen extends StatelessWidget {
  ChatListScreen({super.key});

  final ChatControllers controller = Get.put(ChatControllers());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            AppString.message_text,
            style: GoogleFonts.roboto(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black400,
            ),
          ),
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: GetBuilder<ChatControllers>(
                builder: (_) {
                  return Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withOpacity(0.2),
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
                            controller: controller.searchController,
                            onChanged: (value) {
                              // controller.searchByName(value);
                            },
                            decoration: InputDecoration(
                              hintText: AppString.search_text,
                              hintStyle: GoogleFonts.roboto(
                                fontSize: 14.sp,
                                color: AppColors.black100,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                        controller.searchController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 18.sp,
                                color: AppColors.black100,
                              ),
                              onPressed: () {
                                controller.searchController.clear();
                              },
                            )
                            : SizedBox.shrink(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Message List
            Expanded(
              child: GetBuilder<ChatControllers>(
                builder: (_) {
                  if (controller.chats.isEmpty) {
                    return Center(
                      child: Text(
                        "No messages found",
                        style: GoogleFonts.roboto(
                          fontSize: 14.sp,
                          color: AppColors.black100,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    controller: controller.scrollController,
                    itemCount: controller.chats.length,
                    itemBuilder: (context, index) {
                      ChatModel message = controller.chats[index];
                      return _buildMessageItem(message);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(ChatModel message) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.message,
            parameters: {"id": message.id}
        ,arguments: {
          "name":message.participant.name,
          "image":message.participant.image,
            });
      },
      child: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: AppColors.black100,
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  ApiEndPoint.socketUrl+message.participant.image,
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                )
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
                      CommonText(
                        text: message.participant.name,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        textAlign: TextAlign.left,
                      ),
                      CommonText(
                        text: message.updatedAt.checkTime,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black100,
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.arrow_down_left_circle,
                        size: 16.sp,
                        color: AppColors.red500,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: CommonText(
                          text: message.latestMessage.text,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black400,
                          textAlign: TextAlign.left,
                          maxLines: 1,
                        ),
                      ),
                      // if (message.unreadCount != null &&
                      //     message.unreadCount! > 0) ...[
                      //   SizedBox(width: 8.w),
                      //   Container(
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 6.w,
                      //       vertical: 2.h,
                      //     ),
                      //     decoration: BoxDecoration(
                      //       color: AppColors.black50,
                      //       borderRadius: BorderRadius.circular(10.r),
                      //     ),
                      //     child: CommonText(
                      //       text: message.unreadCount.toString(),
                      //       fontSize: 8,
                      //       fontWeight: FontWeight.w500,
                      //       color: Colors.red,
                      //     ),
                      //   ),
                      // ],
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
