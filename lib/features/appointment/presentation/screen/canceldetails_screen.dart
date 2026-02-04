import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/pending_view_details_controller.dart';
import 'package:haircutmen_user_app/features/appointment/presentation/controller/service_cancel_controller.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../component/image_view/imageview_class.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_string.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';

class CanceldetailsScreen extends StatelessWidget {
  const CanceldetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ServiceCancelController());

    return Scaffold(
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomAppBar(
                  title: AppString.status_show,
                  titleColor: AppColors.primaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              //Sized
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          controller.providerImage.value.isNotEmpty?Container(
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: GestureDetector(
                              onTap: (){
                                if (controller.providerImage.value.isNotEmpty) {
                                  ImageViewerScreen.openSingle(
                                    Get.context!,
                                    ApiEndPoint.socketUrl+controller.providerImage.value,
                                  );
                                }
                                else{
                                  ImageViewerScreen.openSingle(
                                    Get.context!,
                                    "assets/images/noImage.png",
                                  );
                                }
                              },
                              child: CircleAvatar(
                                backgroundImage: controller.providerImage.value.isNotEmpty
                                    ? NetworkImage(ApiEndPoint.socketUrl+controller.providerImage.value)
                                    : AssetImage("assets/images/noImage.png"),
                                radius: 45,
                              ),
                            ),
                          ):Image.asset("assets/images/noImage.png",width: 45,height: 45,),
                          SizedBox(width: 12.w),
                          // Booking Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CommonText(
                                  text: controller.providerName.value,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black400,
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/propetion_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black400,
                                    ),
                                    SizedBox(width: 4.w),
                                    CommonText(
                                      text: controller.serviceName.value,
                                      fontSize: 14.sp,
                                      color: AppColors.black400,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 18,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: 4.w),
                                    Obx(
                                          () => CommonText(
                                        text: controller.rating.value.toString(),
                                        fontSize: 12.sp,
                                        color: AppColors.black300,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Obx(
                                          () => CommonText(
                                        text: "(${controller.reviewCount.value.toString()})",
                                        fontSize: 12.sp,
                                        color: AppColors.black200,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SvgPicture.asset(
                                      "assets/icons/location_icon.svg",
                                      width: 16.w,
                                      height: 16.h,
                                      color: AppColors.black300,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: CommonText(
                                        text: controller.providerLocation.value,
                                        fontSize: 12.sp,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.start,
                                        color: AppColors.black300,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/day_icon.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.black400,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: controller.date.value,
                                fontSize: 14.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              CommonText(
                                text: "${AppString.booking_id} : ${controller.bookingId.value}",
                                fontSize: 14.sp,
                                color: AppColors.black400,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                "assets/icons/time_icon.svg",
                                width: 16.w,
                                height: 16.h,
                                color: AppColors.primaryColor,
                              ),
                              SizedBox(width: 4.w),
                              CommonText(
                                text: controller.time.value,
                                fontSize: 14.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),
                          CommonText(
                            text: controller.duration.value,
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          CommonText(
                            text: controller.serviceName.value,
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(width: 10),
                          CommonText(
                            text: ":RSD ${controller.amount.value}",
                            fontSize: 14.sp,
                            color: AppColors.black400,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: "${AppString.description_text_here}:",
                            fontSize: 14.sp,
                            textAlign: TextAlign.start,
                            color: AppColors.black500,
                            fontWeight: FontWeight.w500,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: CommonText(
                              text: controller.description,
                              fontSize: 14.sp,
                              color: AppColors.black400,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: "Reference Image",
                      textAlign: TextAlign.start,
                      fontSize: 18.sp,
                    ),
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: (){
                        if (controller.image != "") {
                          ImageViewerScreen.openSingle(
                            Get.context!,
                            ApiEndPoint.socketUrl + controller.image,
                            isNetwork: true,
                          );
                        }
                        else{
                          ImageViewerScreen.openSingle(
                              Get.context!,
                              "assets/images/noImage.png",
                              isNetwork: false
                          );
                        }
                      },
                      child: Image.network(
                        ApiEndPoint.socketUrl+controller.image,
                        width: double.infinity,
                        height: 150.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Image.asset("assets/images/noImage.png"),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}