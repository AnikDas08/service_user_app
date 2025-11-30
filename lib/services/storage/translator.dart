import 'package:get/get.dart';
// If using auto_translator, import it instead:
// import 'package:auto_translator/auto_translator.dart';

class StaticTranslator extends GetxController {
  // Option 1: Use auto_translator's built-in method
  static Future<String> translateText(String text, String targetLang) async {
    try {
      // Example with auto_translator (check package docs for exact API):
      final translated = await text.tr; // or AutoTranslator.translate(text, to: targetLang)
      return translated;
    } catch (e) {
      print('Translation error: $e');
      return text; // Return original on error
    }
  }

  // Option 2: Use GetX built-in localization
  static String getTranslation(String key) {
    return key.tr; // GetX's translation method
  }
}