import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/invoice_controller.dart';
import 'package:haircutmen_user_app/features/home/widget/custom_button_home.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(
      init: InvoiceController(),
      builder: (controller) => Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomAppBar(title: "Invoice",),
                  // Header with image
                  _buildHeader(controller),
                  SizedBox(height: 5.h),
                  CommonText(
                    text: "Angel maria",
                    fontWeight: FontWeight.w500,
                    fontSize: 18.sp,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 10.h),
                  RowDetail(title: "Date",value: ": 12.16.25",),
                  SizedBox(height: 10.h,),
                  RowDetail(title: "Time",value: ": 9:16",),
                  SizedBox(height: 10.h,),

                  SizedBox(height: 30.h,),

                  CommonText(
                    textAlign: TextAlign.start,
                    text: "Use Promo Code(Optional)",
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 10.h,),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: "Enter Promo Code",
                          controller: controller.promoCode,
                          borderRadius: 4,
                          paddingHorizontal: 10,
                          paddingVertical: 10,
                        ),
                      ),
                      SizedBox(width: 16,),
                      IntrinsicWidth(child: CustomButton(text: "Apply", isSelected: true, onTap: (){}))
                    ],
                  ),
                  SizedBox(height: 30.h,),

                  // Services Table
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.black300.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Table(
                      border: TableBorder(
                        verticalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
                        horizontalInside: BorderSide(color: AppColors.black300.withOpacity(0.3)),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1.2),
                        2: FlexColumnWidth(1),
                      },
                      children: [
                        // Header Row
                        TableRow(
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8.r),
                              topRight: Radius.circular(8.r),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Service",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Service Type",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Price",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black400,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Data Row 1
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Hair Cut",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black300,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Zero Cut",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black300,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "200RSD",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primaryColor,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        // Data Row 2
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Hair Cut",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black300,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "Color with cut",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.black300,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(12.w),
                              child: CommonText(
                                text: "200RSD",
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.primaryColor,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        textAlign: TextAlign.start,
                        text: "Sub Total",
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.black400,
                      ),
                      SizedBox(
                        width: 80,
                        child: CommonText(
                          textAlign: TextAlign.start,
                          text: ": RSD 2500",
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.black400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        textAlign: TextAlign.start,
                        text: "Discount(30%)",
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.black400,
                      ),
                      SizedBox(
                        width: 80,
                        child: CommonText(
                          textAlign: TextAlign.start,
                          text: ": RSD 200",
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.black400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.h,),
                  Container(
                    height: 2,
                    color: AppColors.black200,
                  ),
                  SizedBox(height: 5.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CommonText(
                        textAlign: TextAlign.start,
                        text: "Total Price",
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.primaryColor,
                      ),
                      SizedBox(
                        width: 80,
                        child: CommonText(
                          textAlign: TextAlign.start,
                          text: " RSD 2300",
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50.h,),
                  CustomButton(
                      text: "Pay",
                      isSelected: true,
                      onTap: (){
                        //Get.offAllNamed(AppRoutes.homeNav);
                      })

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildHeader(InvoiceController controller) {
    final provider = controller.serviceProvider;
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10.r)),
        child: Image.asset(
          "${provider["image"] }"?? "assets/images/service_provider.png",
          width: double.infinity,
          height: 147.h,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class RowDetail extends StatelessWidget {
  final String title;
  final String value;
  const RowDetail({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 150.w,
          child: CommonText(
            textAlign: TextAlign.start,
            text: title,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.black400,
          ),
        ),
        CommonText(
          textAlign: TextAlign.start,
          text: value,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: AppColors.black400,
        ),
      ],
    );
  }
}
