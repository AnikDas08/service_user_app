import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/component/text_field/common_text_field.dart';
import 'package:haircutmen_user_app/features/home/presentation/controller/invoice_controller.dart';
import 'package:haircutmen_user_app/features/home/widget/custom_button_home.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';
import '../../../../config/api/api_end_point.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(
      init: InvoiceController(),
      builder: (controller) => Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomAppBar(title: AppString.invoice_text),

                  SizedBox(height: 10.h),

                  _buildProviderSection(controller),

                  SizedBox(height: 20.h),

                  _buildBookingDetails(controller),

                  SizedBox(height: 30.h),

                  CommonText(
                    textAlign: TextAlign.start,
                    text: AppString.use_promocode,
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: AppColors.black400,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: CommonTextField(
                          hintText: AppString.promo_code_hints,
                          controller: controller.promoCode,
                          borderRadius: 4,
                          paddingHorizontal: 10,
                          paddingVertical: 10,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      IntrinsicWidth(
                        child: CustomButton(
                          text: AppString.apply_button,
                          isSelected: true,
                          onTap: () {
                            controller.applyPromoCode();
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 30.h),

                  _buildServicesTable(controller),

                  SizedBox(height: 16.h),

                  _buildPriceSummary(controller),

                  SizedBox(height: 50.h),

                  CustomButton(
                    text: AppString.pay_button,
                    isSelected: true,
                    onTap: () {
                      controller.processPayment();
                    },
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderSection(InvoiceController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.providerImage != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: controller.providerImage != null
                ? Image.network(
              '${ApiEndPoint.socketUrl}${controller.providerImage}',
              width: double.infinity,
              height: 147.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 147.h,
                  color: AppColors.black100,
                  child: Icon(
                    Icons.person,
                    size: 48.sp,
                    color: AppColors.black200,
                  ),
                );
              },
            )
                : Image.asset(
              "assets/images/noImage.png",
              width: double.infinity,
              height: 147.h,
              fit: BoxFit.cover,
            ),
          ),
        SizedBox(height: 10.h),
        CommonText(
          text: controller.providerName,
          fontWeight: FontWeight.w500,
          fontSize: 18.sp,
          color: AppColors.black400,
        ),
      ],
    );
  }

  Widget _buildBookingDetails(InvoiceController controller) {
    return Column(
      children: [
        RowDetail(
          title: AppString.date,
          value: ": ${controller.bookingDate}",
        ),
        SizedBox(height: 10.h),
        RowDetail(
          title: AppString.time,
          value: ": ${controller.bookingTime}",
        ),
      ],
    );
  }

  Widget _buildServicesTable(InvoiceController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black300.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Table(
        border: TableBorder(
          verticalInside:
          BorderSide(color: AppColors.black300.withOpacity(0.3)),
          horizontalInside:
          BorderSide(color: AppColors.black300.withOpacity(0.3)),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1),
          1: FlexColumnWidth(1.2),
          2: FlexColumnWidth(1),
        },
        children: [
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
                  text: AppString.service,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black400,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12.w),
                child: CommonText(
                  text: AppString.service_type,
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
          ...controller.selectedServices.map((service) {
            return TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CommonText(
                    text: service['name'] ?? 'Service',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black300,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CommonText(
                    text: service['type'] ?? 'Standard',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black300,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CommonText(
                    text: service['price'] ?? '0 RSD',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.primaryColor,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildPriceSummary(InvoiceController controller) {
    return Obx(() => controller.isLoadingFees.value
        ? Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      ),
    )
        : Column(
      children: [
        // Sub Total
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
              width: 100.w,
              child: CommonText(
                textAlign: TextAlign.end,
                text: "RSD ${controller.subTotal}",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.black400,
              ),
            ),
          ],
        ),

        // ✅ Weather Fee - Only show if enabled
        if (controller.isWeatherFeeOn.value) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                textAlign: TextAlign.start,
                text: "Weather Fee",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.black400,
              ),
              SizedBox(
                width: 100.w,
                child: CommonText(
                  textAlign: TextAlign.end,
                  text: "RSD ${controller.weatherFee}",
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
        ],

        // ✅ Convenience Fee - Only show if enabled
        if (controller.isConvenienceFeeOn.value) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                textAlign: TextAlign.start,
                text: "Convenience Fee",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.black400,
              ),
              SizedBox(
                width: 100.w,
                child: CommonText(
                  textAlign: TextAlign.end,
                  text: "RSD ${controller.convenienceFee}",
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
        ],

        // ✅ Arrival Fee - Only show if enabled
        if (controller.isArrivalFeeOn.value) ...[
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CommonText(
                textAlign: TextAlign.start,
                text: "Arrival Fee",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.black400,
              ),
              SizedBox(
                width: 100.w,
                child: CommonText(
                  textAlign: TextAlign.end,
                  text: "RSD ${controller.arrivalFee}",
                  fontWeight: FontWeight.w400,
                  fontSize: 14.sp,
                  color: AppColors.black400,
                ),
              ),
            ],
          ),
        ],

        // Discount
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              textAlign: TextAlign.start,
              text: "Discount (${controller.discountPercent}%)",
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.black400,
            ),
            SizedBox(
              width: 100.w,
              child: CommonText(
                textAlign: TextAlign.end,
                text: controller.discount.value > 0
                    ? "- RSD ${controller.discount.value}"
                    : "RSD 0",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: controller.discount.value > 0
                    ? Colors.green
                    : AppColors.black400,
              ),
            ),
          ],
        ),

        // Credit
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              textAlign: TextAlign.start,
              text: "Credit",
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: AppColors.black400,
            ),
            SizedBox(
              width: 100.w,
              child: CommonText(
                textAlign: TextAlign.end,
                text: controller.credits.value > 0
                    ? "RSD ${controller.credits.value.toStringAsFixed(2)}"
                    : "RSD 0",
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: controller.credits.value > 0
                    ? Colors.blue
                    : AppColors.black400,
              ),
            ),
          ],
        ),

        // Divider
        SizedBox(height: 10.h),
        Container(
          height: 2,
          color: AppColors.black200,
        ),
        SizedBox(height: 10.h),

        // Total Price
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CommonText(
              textAlign: TextAlign.start,
              text: "Total Price",
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
              color: AppColors.primaryColor,
            ),
            SizedBox(
              width: 100.w,
              child: CommonText(
                textAlign: TextAlign.end,
                text: "RSD ${controller.totalPrice.value}",
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ],
    ));
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
        Expanded(
          child: CommonText(
            textAlign: TextAlign.start,
            text: value,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: AppColors.black400,
          ),
        ),
      ],
    );
  }
}