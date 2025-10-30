import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/config/api/api_end_point.dart';
import 'package:haircutmen_user_app/features/home/widget/custom_button_home.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../component/image/common_image.dart';
import '../../../../component/text/common_text.dart';
import '../../../../utils/constants/app_colors.dart';
import '../../../../utils/constants/app_string.dart';
import '../controller/service_details_controller.dart';
import '../widgets/avalibe_dialog.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceDetailsController>(
      init: ServiceDetailsController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Obx(() {
            // Show loading indicator
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              );
            }
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomAppBar(
                        title: AppString.view_profile_text,
                        rightIcon: Icons.share,
                        showRightButton: true,
                        onRightButtonTap: () {
                          Share.share(
                            'Check this out! https://example.com',
                            subject: 'Sharing from my app',
                          );
                        },
                      ),

                      SizedBox(height: 20.h),

                      // Header with image
                      _buildHeader(controller),
                      SizedBox(height: 20.h),

                      // Profile info section
                      _buildProfileInfo(controller),
                      SizedBox(height: 20.h),

                      // Services section
                      _buildServicesList(controller),
                      SizedBox(height: 20.h),

                      // About me section
                      _buildAboutMe(controller),
                      SizedBox(height: 20.h),

                      // Work photos section
                      _buildWorkPhotos(controller),
                      SizedBox(height: 20.h),

                      // Reviews section
                      _buildReviews(controller),
                      SizedBox(height: 30.h), // Space for bottom button
                    ],
                  ),
                ),
              ),
            );
          }),

          // Bottom button
          bottomNavigationBar: Obx(() {
            if (controller.isLoading.value || controller.providerData == null) {
              return SizedBox.shrink();
            }
            return _buildBottomButton(controller);
          }),
        );
      },
    );
  }

  Widget _buildHeader(ServiceDetailsController controller) {
    // Priority: user image > service images > default image
    String? imageUrl;

    if (controller.providerImage != null && controller.providerImage!.isNotEmpty) {
      imageUrl = controller.providerImage;
    } else if (controller.providerData?.serviceImages.isNotEmpty == true) {
      imageUrl = controller.providerData!.serviceImages.first;
    }

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        child: controller.providerImage!=null
            ? Image.network(
          ApiEndPoint.socketUrl+controller.providerImage!,
          width: double.infinity,
          height: 147.h,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
                child: Container(
                  height: 110.h,
                  width: double.infinity,
                  color: AppColors.white,
                  child: Center(
                    child: CommonText(
                      text: "Image not available",
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black300,
                    ),
                  ),
                )
            );
          },
        )
            : Image.asset(
          "assets/images/image_here.png",
          width: double.infinity,
          height: 147.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ServiceDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: controller.providerName,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.black400,
              textAlign: TextAlign.left,
            ),
            Row(
              children: [
                Icon(
                  Icons.star,
                  size: 24,
                  color: Colors.amber,
                ),
                SizedBox(width: 4.w),
                Obx(
                 ()=> CommonText(
                    text: controller.averageRating.value.toString(),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black300,
                  ),
                ),
                SizedBox(width: 4.w),
                Obx(
                ()=> CommonText(
                    text: "(${controller.totalReviews.value.toString()})",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black200,
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 10.h),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  "assets/icons/propetion_icon.svg",
                  height: 20,
                  width: 20,
                ),
                SizedBox(width: 4.w),
                CommonText(
                  text: controller.services.isNotEmpty
                      ? controller.services.first['name']
                      : "Haircut",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black400,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            CustomButton(
                text: AppString.avilable_button,
                fontSize: 12,
                height: 30,
                isSmall: true,
                isSelected: false,
                onTap: ()async{
                  await controller.showAvailability();
                  // Then show dialog
                  _showAvailabilityBottomSheet(Get.context!);
                }
            )
          ],
        ),

        SizedBox(height: 12.h),

        Row(
          children: [
            SvgPicture.asset(
              "assets/icons/location_icon.svg",
              height: 20,
              width: 20,
            ),
            SizedBox(width: 4.w),
            CommonText(
              text: "Distance :${controller.providerDistance}",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.black300,
              textAlign: TextAlign.left,
            ),
          ],
        ),

        SizedBox(height: 18.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CommonText(
              text: "Spoken : ",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black400,
            ),
            CommonText(
              text: controller.spokenLanguagesText,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesList(ServiceDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "All Services",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black400,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 12.h),

        // Use GetBuilder instead of Obx for better state management
        GetBuilder<ServiceDetailsController>(
          builder: (controller) => ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.services.length,
            separatorBuilder: (context, index) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final service = controller.services[index];
              final isSelected = service['selected'] ?? false;

              return GestureDetector(
                onTap: () {
                  controller.toggleServiceSelection(service['id']);
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : AppColors.black50,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () {
                          controller.toggleServiceSelection(service['id']);
                        },
                        child: Container(
                          width: 24.w,
                          height: 24.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryColor : AppColors.black200,
                              width: 2,
                            ),
                            color: isSelected ? AppColors.primaryColor : Colors.transparent,
                          ),
                          child: isSelected
                              ? Icon(
                            Icons.check,
                            size: 16.sp,
                            color: Colors.white,
                          )
                              : null,
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: CommonText(
                                    text: service['name'],
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.black400,
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                CommonText(
                                  text: "- ${service['type'] ?? 'Standard'}",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black300,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),

                            SizedBox(height: 4.h),

                            Row(
                              children: [
                                CommonText(
                                  text: "60 min",
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.black200,
                                  textAlign: TextAlign.left,
                                ),
                                SizedBox(width: 8.w),
                                CommonText(
                                  text: "• ${service['price']}",
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryColor,
                                  textAlign: TextAlign.left,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        SizedBox(height: 16.h),

        // Show selected services summary
        GetBuilder<ServiceDetailsController>(
          builder: (controller) {
            if (controller.selectedServiceIds.isEmpty) {
              return SizedBox.shrink();
            }

            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        text: "Selected Services (${controller.selectedServiceIds.length})",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                        textAlign: TextAlign.left,
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.clearAllSelections();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: CommonText(
                            text: "Clear All",
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Show selected services list
                  Column(
                    children: controller.getSelectedServices().map((service) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CommonText(
                              text: "• ${service['name']}",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black400,
                              textAlign: TextAlign.left,
                            ),
                            CommonText(
                              text: "${service['price']}",
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryColor,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 8.h),

                  Container(
                    width: double.infinity,
                    height: 1.h,
                    color: AppColors.primaryColor.withOpacity(0.3),
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        text: "Total Duration: 60 min",
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black400,
                        textAlign: TextAlign.left,
                      ),
                      CommonText(
                        text: "Total: RSD ${controller.getTotalPrice()}",
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutMe(ServiceDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.about_me_text,
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.black400,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 8.h),

        CommonText(
          text: controller.providerAbout,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.black300,
          textAlign: TextAlign.left,
          maxLines: 10,
        ),
      ],
    );
  }

  Widget _buildWorkPhotos(ServiceDetailsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: AppString.work_photo_text,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black400,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 12.h),

        GetBuilder<ServiceDetailsController>(
          builder: (controller) {
            // Check if there are service images
            if (controller.providerData?.serviceImages.isEmpty ?? true) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: CommonText(
                    text: "No work photos available",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black200,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                childAspectRatio: 1.0,
              ),
              itemCount: controller.providerData?.serviceImages.length ?? 0,
              itemBuilder: (context, index) {
                final imagePath = controller.providerData?.serviceImages[index];

                // Construct full image URL - remove leading slash if present
                String fullImageUrl = '';
                if (imagePath != null && imagePath.isNotEmpty) {
                  // Remove leading slash from imagePath to avoid double slashes
                  final cleanPath = imagePath.startsWith('/')
                      ? imagePath.substring(1)
                      : imagePath;
                  fullImageUrl = '${ApiEndPoint.imageUrl}/$cleanPath';
                }

                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                    fullImageUrl,
                    width: double.infinity,
                    height: 115.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $fullImageUrl');
                      return Container(
                        width: double.infinity,
                        height: 115.h,
                        color: AppColors.black100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported,
                              size: 40.sp,
                              color: AppColors.black200,
                            ),
                            SizedBox(height: 4.h),
                            CommonText(
                              text: "Image unavailable",
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: AppColors.black200,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 115.h,
                        color: AppColors.black50,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                      : Container(
                    width: double.infinity,
                    height: 115.h,
                    color: AppColors.black100,
                    child: Icon(
                      Icons.image,
                      size: 40.sp,
                      color: AppColors.black200,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildReviews(ServiceDetailsController controller) {
    return Obx(() {
      // Show loading indicator
      if (controller.isLoadingReviews.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ),
        );
      }

      // Show empty state if no reviews
      if (controller.review.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 48.sp,
                  color: AppColors.black200,
                ),
                SizedBox(height: 8.h),
                CommonText(
                  text: "No reviews yet",
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black200,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      // Show reviews list
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with average rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                text: "Reviews (${controller.totalReviews.value})",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.black400,
                textAlign: TextAlign.left,
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 20.sp,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 4.w),
                  CommonText(
                    text: controller.averageRating.value.toStringAsFixed(1),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black400,
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Reviews list
          ...List.generate(controller.review.length, (index) {
            final review = controller.review[index];
            final user = review['user'] ?? {};
            final userName = user['name'] ?? 'Anonymous';
            final userImage = user['image'];
            final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // User image
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.r),
                          color: AppColors.black100,
                        ),
                        child: userImage != null && userImage.toString().isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(100.r),
                          child: Image.network(
                            ApiEndPoint.socketUrl + userImage.toString(),
                            width: 48.w,
                            height: 48.w,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 48.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(100.r),
                                ),
                                child: Center(
                                  child: Text(
                                    userInitial,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                            : Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Center(
                            child: Text(
                              userInitial,
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: userName,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black400,
                              textAlign: TextAlign.left,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                // Star rating
                                ...List.generate(5, (starIndex) {
                                  double rating = (review['rating'] ?? 0).toDouble();
                                  return Icon(
                                    starIndex < rating.floor()
                                        ? Icons.star
                                        : (starIndex < rating
                                        ? Icons.star_half
                                        : Icons.star_border),
                                    size: 16.sp,
                                    color: Colors.amber,
                                  );
                                }),
                                SizedBox(width: 8.w),
                                CommonText(
                                  text: (review['rating'] ?? 0).toString(),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black300,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.h),

                  // Review comment
                  CommonText(
                    text: review['comment'] ?? 'No comment',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black300,
                    textAlign: TextAlign.left,
                    maxLines: 10,
                  ),

                  // Review date (if you want to show it)
                  if (review['createdAt'] != null) ...[
                    SizedBox(height: 6.h),
                    CommonText(
                      text: _formatDate(review['createdAt']),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black200,
                      textAlign: TextAlign.left,
                    ),
                  ],

                  // Divider between reviews
                  if (index < controller.review.length - 1) ...[
                    SizedBox(height: 12.h),
                    Divider(
                      color: AppColors.black100,
                      height: 1.h,
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      );
    });
  }

  String _formatDate(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      DateTime now = DateTime.now();

      Duration difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else if (difference.inDays < 30) {
        int weeks = (difference.inDays / 7).floor();
        return '$weeks ${weeks == 1 ? "week" : "weeks"} ago';
      } else if (difference.inDays < 365) {
        int months = (difference.inDays / 30).floor();
        return '$months ${months == 1 ? "month" : "months"} ago';
      } else {
        int years = (difference.inDays / 365).floor();
        return '$years ${years == 1 ? "year" : "years"} ago';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildBottomButton(ServiceDetailsController controller) {
    return Container(
        padding: EdgeInsets.all(20.w),
        color: AppColors.background,
        child: CustomButton(
            text: AppString.book_now_button,
            isSelected: true,
            onTap: () => controller.bookNow())
    );
  }

  void _showAvailabilityBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AvailabilityDialog(),
    );
  }
}