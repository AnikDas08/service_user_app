import 'package:get/get.dart';
import 'package:haircutmen_user_app/utils/constants/app_string.dart';

class PrivacyPolicyModel {
  final String id;
  final String content;

  PrivacyPolicyModel({
    required this.id,
    required this.content,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyModel(
      id: json['_id'] ?? '',
      content: json['privacyPolicy'] ?? AppString.dataEmpty,
    );
  }
}
