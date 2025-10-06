
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
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
          body: SafeArea(
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
                    _buildAboutMe(),
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
          ),

          // Bottom button
          bottomNavigationBar: _buildBottomButton(controller),
        );
      },
    );
  }

  Widget _buildHeader(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        child: CommonImage(
          imageSrc: provider["image"] ?? "assets/images/service_provider.png",
          width: double.infinity,
          height: 147.h,
          fill: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ServiceDetailsController controller) {
    final provider = controller.serviceProvider;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              text: provider["name"] ?? "Angle Mariomi",
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
                CommonText(
                  text: "4.5",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black300,
                ),
                SizedBox(width: 4.w),
                CommonText(
                  text: "(200)",
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black200,
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
                  text: provider["service"] ?? "Haircut",
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
                onTap: () => _showAvailabilityBottomSheet(Get.context!)
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
              text: "Distance :2Km",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.black300,
              textAlign: TextAlign.left,
            ),
          ],
        ),

        SizedBox(height: 18.h),
        Row(
          children: [
            CommonText(
              text: "Spoken : ",
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.black400,
            ),
            Expanded(
              child: CommonText(
                text: "English, Russian, Serbian",
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryColor,
              ),
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
                  print("Tapping service: ${service['name']}, Current selected: $isSelected");
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
                                  text: service['duration'],
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
                              text: "${service['price']} (${service['duration']})",
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
                        text: "Total Duration: 2 hour",
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

  Widget _buildAboutMe() {
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
          text: "With 15 Years Of Experience In The Hair Styling Industry, I'm Passionate About Bringing My Clients Up The Next Level. Come See How I Can Transform Your Feeling When You're Looking For A Fresh Cut, A Bold New Look Or Even Spring Shaving. Process To Make You Look Handsome Or More Attractive. I Have A Deal I Want To Stay By Locking Across Different Styles And Textures, Ensuring That Each Client Leaves Looking And Feeling Their Best.",
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
          text: AppString.photo_customer_four,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.black400,
          textAlign: TextAlign.left,
        ),

        SizedBox(height: 12.h),

        Obx(() {
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.0,
            ),
            itemCount: controller.workPhotos.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: CommonImage(
                  imageSrc: "assets/images/item_image.png",
                  width: double.infinity,
                  height: 115.h,
                  fill: BoxFit.cover,
                ),
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildReviews(ServiceDetailsController controller) {
    // Sample reviews data
    final reviews = [
      {
        "name": "Rahad Ullah",
        "image": "assets/images/profile_image.png",
        "rating": 5,
        "comment":
        "He Does A Great Job. I Had His Hair Cut A Few Days Ago. Always Tells All My Expectations | Always Provide Top Service."
      },
      {
        "name": "John Doe",
        "image": "assets/images/profile_image.png",
        "rating": 4,
        "comment":
        "Very professional and friendly. Will come back again for sure!"
      },
      {
        "name": "Jane Smith",
        "image": "assets/images/profile_image.png",
        "rating": 3,
        "comment": "Good service but took longer than expected."
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(reviews.length, (index) {
        final review = reviews[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: CommonImage(
                      imageSrc: review["image"].toString(),
                      size: 48.w,
                      fill: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: review["name"].toString(),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black400,
                        textAlign: TextAlign.left,
                      ),
                      Row(
                        children: List.generate(
                          5,
                              (starIndex) =>
                              Icon(
                                Icons.star,
                                size: 24.sp,
                                color: starIndex <
                                    int.parse(review["rating"].toString())
                                    ? Colors.amber
                                    : AppColors.black100,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              CommonText(
                text: review["comment"].toString(),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: AppColors.black300,
                textAlign: TextAlign.left,
                maxLines: 10,
              ),
            ],
          ),
        );
      }),
    );
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