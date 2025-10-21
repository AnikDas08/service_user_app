import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/custom_appbar/custom_appbar.dart';
import 'package:haircutmen_user_app/utils/extensions/extension.dart';
import '../../../../../component/button/common_button.dart';
import '../../../../../component/text/common_text.dart';
import '../controller/sign_up_controller.dart';
import '../../../../../../utils/constants/app_colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../../../utils/constants/app_string.dart';

class VerifyUser extends StatefulWidget {
  const VerifyUser({super.key});

  @override
  State<VerifyUser> createState() => _VerifyUserState();
}

class _VerifyUserState extends State<VerifyUser> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /// App Bar Section starts here
      body: GetBuilder<SignUpController>(
        builder: (controller) {
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SafeArea(
              child: Column(
                children: [
                  CustomAppBar(title: ""),
                  /// Logo text here
                  const CommonText(
                    text: AppString.onboarding_text,
                    fontSize: 24,
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                    maxLines: 2,
                    bottom: 20,
                  ).center,
              
                  /// Verify User Container here
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.black50),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x408E8E8E),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
              
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          /// OTP Title here
                          CommonText(
                            text: AppString.verify_email_text,
                            fontSize: 18,
                            bottom: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryColor,
                          ),
              
                          /// instruction how to get OTP
                          Center(
                            child: CommonText(
                              text:
                                  AppString.verify_email_text,
                              fontSize: 14,
                              bottom: 20,
                              maxLines: 2,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
              
                          /// OTP Filed here
                          Flexible(
                            flex: 0,
                            child: PinCodeTextField(
                              controller: controller.otpController,
                              autoDisposeControllers: false,
                              cursorColor: AppColors.primaryColor,
                              appContext: (context),
                              autoFocus: true,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(4.r),
                                fieldHeight: 60.h,
                                fieldWidth: 60.w,
                                activeFillColor: AppColors.transparent,
                                selectedFillColor: AppColors.transparent,
                                inactiveFillColor: AppColors.transparent,
                                borderWidth: 0.5.w,
                                selectedColor: AppColors.black50,
                                activeColor: AppColors.black50,
                                inactiveColor: AppColors.black50,
                              ),
                              length: 6,
                              keyboardType: TextInputType.number,
                              autovalidateMode: AutovalidateMode.disabled,
                              enableActiveFill: true,
                              validator: (value) {
                                if (value != null && value.length == 6) {
                                  return null;
                                } else {
                                  return AppString.otpIsInValid;
                                }
                              },
                            ),
                          ),
              
                          ///  Submit Button here
                          CommonButton(
                            titleText: AppString.continue_button,
                            isLoading: controller.isLoadingVerify,
                            onTap: () {
                              if (formKey.currentState!.validate()) {
                                controller.verifyOtpRepo();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30.h,),
                  /// Resend OTP Button here
                  CommonButton(
                    titleText: AppString.resend_button,
                    buttonWidth: MediaQuery.of(context).size.width*0.6,
                    isLoading: controller.isLoadingReset,
                    titleColor: AppColors.primaryColor,
                    buttonColor: AppColors.transparent,
                    borderColor: AppColors.primaryColor,
                    onTap: () {
                        controller.resendOtp();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
