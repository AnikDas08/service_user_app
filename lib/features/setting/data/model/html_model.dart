import 'package:haircutmen_user_app/utils/constants/app_string.dart';

class HtmlModel {
  final String id;
  final String content;

  HtmlModel({
    required this.id,
    required this.content,
  });

  factory HtmlModel.fromJson(Map<String, dynamic> json) {
    return HtmlModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? AppString.dataEmpty,
    );
  }
}
