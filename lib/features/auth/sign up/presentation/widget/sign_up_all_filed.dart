import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:country_picker/country_picker.dart';
import '../../../../../utils/constants/app_colors.dart';
import '../../../../../utils/helpers/other_helper.dart';
import '../../../../../utils/constants/app_string.dart';
import '../../../../../component/text/common_text.dart';
import '../../../../../component/text_field/common_text_field.dart';
import '../controller/sign_up_controller.dart';

class SignUpAllField extends StatefulWidget {
  const SignUpAllField({super.key, required this.controller});
  final SignUpController controller;

  @override
  State<SignUpAllField> createState() => _SignUpAllFieldState();
}

class _SignUpAllFieldState extends State<SignUpAllField> {
  Country selectedCountry = Country(
    phoneCode: '880',
    countryCode: 'BD',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'Bangladesh',
    example: 'Bangladesh',
    displayName: 'Bangladesh',
    displayNameNoCountryCode: 'BD',
    e164Key: '',
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Name
        const CommonText(
          text: AppString.name_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
        ),
        SizedBox(height: 6),
        CommonTextField(
          hintText: AppString.hints_name,
          hintTextColor: AppColors.black100,
          controller: widget.controller.nameController,
          validator: OtherHelper.validator,
        ),

        /// Email
        const CommonText(
          text: AppString.email,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          top: 12,
          bottom: 6,
        ),
        CommonTextField(
          hintText: AppString.hint_email_text,
          hintTextColor: AppColors.black100,
          controller: widget.controller.emailController,
          validator: OtherHelper.emailValidator,
        ),

        /// Phone Number
        const CommonText(
          text: AppString.phone_number_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          top: 12,
          bottom: 6,
        ),
        _buildPhoneNumberField(),

        /// Location
        const CommonText(
          text: AppString.location_text,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.black400,
          bottom: 6,
          top: 12,
        ),
        Column(
          children: [
            CommonTextField(
              hintText: AppString.location_hint,
              hintTextColor: AppColors.black100,
              controller: widget.controller.locationController,
              validator: OtherHelper.validator,
              onChanged: widget.controller.onLocationChanged,
            ),
            if (widget.controller.locationSuggestions.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: AppColors.black50),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.controller.locationSuggestions.length,
                  itemBuilder: (context, index) {
                    final location = widget.controller.locationSuggestions[index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        location.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.roboto(
                          fontSize: 13.sp,
                          color: AppColors.black,
                        ),
                      ),
                      onTap: () {
                        widget.controller.selectLocation(location);
                        FocusScope.of(context).unfocus();
                        setState(() {});
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      controller: widget.controller.phoneNumberController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: GoogleFonts.roboto(fontSize: 14.sp, color: AppColors.black),
      validator: OtherHelper.validator,
      decoration: InputDecoration(
        hintText: AppString.hint_phone_number,
        prefixIcon: GestureDetector(
          onTap: () {
            showCountryPicker(
              context: context,
              showPhoneCode: true,
              onSelect: (Country country) {
                setState(() {
                  selectedCountry = country;
                });
                widget.controller.countryCode = '+${country.phoneCode}';
              },
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedCountry.flagEmoji),
                Text('+${selectedCountry.phoneCode}'),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}
