import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:haircutmen_user_app/component/text/common_text.dart';
import 'package:haircutmen_user_app/config/route/app_routes.dart';
import 'package:haircutmen_user_app/utils/constants/app_colors.dart';

import '../../../../utils/constants/app_string.dart';
import '../../../../utils/custom_appbar/custom_appbar.dart';
import '../../../home/widget/custom_button_home.dart';

class PersonalInformationScreen extends StatelessWidget {
  const PersonalInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(title: AppString.personal_information,),
                SizedBox(height: 30,),
                Center(
                  child: CircleAvatar(
                    radius: 60.sp,
                    backgroundColor: Colors.transparent,
                    child: Image.asset(
                      "assets/images/profile_image.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 26,),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(14),
                  constraints: BoxConstraints(),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:[
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InformationRow(title: AppString.full_name,value: "Sohidul Islam",),
                      SizedBox(height: 12),
                      InformationRow(title: AppString.email_text,value: "sohidul@gmail.com",),
                      SizedBox(height: 12),
                      InformationRow(title: AppString.contact_text,value: "787859767856",),
                      SizedBox(height: 12),
                      InformationRow(title: AppString.location_text,value: "Dhaka,Bangladesh",),
                      SizedBox(height: 12),
                    ],
                  ),
                ),
                SizedBox(height: 20.h,),
                CustomButton
                  (text: AppString.edit_profile_button,
                    isSelected: true,
                    onTap: (){
                      Get.toNamed(AppRoutes.editProfile);
                    })
              ],
            ),
          ),
        )
    );
  }
}

class InformationRow extends StatelessWidget {
  String title;
  String value;

  InformationRow({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 100,
          child: CommonText(
            text: title,
            fontSize: 14,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w400,
            color: AppColors.black400,
          ),
        ),
        Expanded(
          child: CommonText(
            text: ": $value",
            fontSize: 14,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w400,
            color: AppColors.black400,
          ),
        ),
      ],
    );
  }
}
