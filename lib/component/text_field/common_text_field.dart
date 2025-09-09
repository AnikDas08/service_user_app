import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants/app_colors.dart';
import '../text/common_text.dart';

class CommonTextField extends StatelessWidget {
  CommonTextField({
    super.key,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.prefixIconData,
    this.isPassword = false,
    this.controller,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.mexLength,
    this.maxLines = 1,
    this.minLines, // Added minLines parameter
    this.validator,
    this.prefixText,
    this.paddingHorizontal = 16,
    this.paddingVertical = 20,
    this.borderRadius = 10,
    this.inputFormatters,
    this.fillColor = AppColors.transparent,
    this.hintTextColor = AppColors.textFiledColor,
    this.labelTextColor = AppColors.textFiledColor,
    this.textColor = AppColors.black,
    this.borderColor = AppColors.black50,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.onSubmitted,
    this.onTap,
    this.onChanged,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.height, // Made height optional
    this.isMultiline = false, // Added flag for multiline fields
  });

  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final Widget? prefixIcon;
  final IconData? prefixIconData;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? labelTextColor;
  final Color? hintTextColor;
  final Color? textColor;
  final Color borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double paddingHorizontal;
  final double paddingVertical;
  final double borderRadius;
  final int? mexLength;
  final int? maxLines;
  final int? minLines; // Added minLines
  final bool isPassword;
  final double? height; // Made optional
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool isMultiline; // Added multiline flag
  final TextAlign textAlign;
  final RxBool obscureText = false.obs;
  final Function(String)? onSubmitted;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final TextInputAction textInputAction;
  final FormFieldValidator? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    // Determine if this should be a multiline field
    bool shouldBeMultiline = isMultiline || (maxLines != null && maxLines! > 1) || minLines != null;

    Widget textField = TextFormField(
      autovalidateMode: AutovalidateMode.onUnfocus,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: isPassword ? obscureText.value : false,
      textInputAction: textInputAction,
      maxLength: mexLength,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      textAlign: textAlign,
      cursorColor: AppColors.primaryColor,
      inputFormatters: inputFormatters,
      style: GoogleFonts.roboto(
        fontSize: 14.sp,
        color: textColor,
        fontWeight: FontWeight.w400,
      ),
      onFieldSubmitted: onSubmitted,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        errorMaxLines: 2,
        filled: true,
        prefixIcon: prefixIcon ??
            (prefixIconData != null
                ? Icon(prefixIconData, color: hintTextColor, size: 20.sp)
                : null),
        fillColor: fillColor,
        counterText: "",
        contentPadding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal.w,
          vertical: shouldBeMultiline ? paddingVertical.h : paddingVertical.h,
        ),
        border: _buildBorder(borderColor),
        enabledBorder: _buildBorder(borderColor),
        focusedBorder: _buildBorder(focusedBorderColor ?? borderColor),
        disabledBorder: _buildBorder(AppColors.black50.withOpacity(0.5)),
        errorBorder: _buildBorder(borderColor),
        focusedErrorBorder: _buildBorder(borderColor),
        hintText: hintText,
        labelText: labelText,
        hintStyle: GoogleFonts.roboto(
          fontSize: 12.sp,
          color: hintTextColor,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: 14.sp,
          color: labelTextColor,
          fontWeight: FontWeight.w400,
        ),
        errorStyle: GoogleFonts.roboto(
          fontSize: 12.sp,
          color: errorBorderColor ?? AppColors.red,
        ),
        prefix: prefixText != null
            ? CommonText(
          text: prefixText!,
          fontWeight: FontWeight.w400,
          fontSize: 14.sp,
          color: textColor!,
        )
            : null,
        suffixIcon: isPassword ? _buildPasswordSuffixIcon() : suffixIcon,
      ),
    );

    // If it's a single line field and height is specified, wrap in Container
    if (!shouldBeMultiline && height != null) {
      return Container(
        height: height,
        child: textField,
      );
    }

    // For multiline fields, don't restrict height
    return textField;
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius.r),
      borderSide: BorderSide(color: color, width: 1.w),
    );
  }

  Widget _buildPasswordSuffixIcon() {
    return GestureDetector(
      onTap: ()=>toggle(),
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: 12.w),
        child: Obx(
              () => Icon(
            obscureText.value
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            size: 20.sp,
            color: AppColors.black200,
          ),
        ),
      ),
    );
  }

  void toggle() {
    obscureText.value = !obscureText.value;
  }
}