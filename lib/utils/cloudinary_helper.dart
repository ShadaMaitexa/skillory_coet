import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryHelper {
  // Constants for Cloudinary (Ideally these should be in a config/env file)
  static const String cloudName = "dvzq5mv7x"; // Placeholder - you should replace with your cloud name
  static const String uploadPreset = "skillory_proofs"; // Placeholder - you must create an 'Unsigned' preset in Cloudinary settings

  static Future<String?> uploadFile(File file) async {
    try {
      String url = "https://api.cloudinary.com/v1_1/$cloudName/upload";
      
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path),
        "upload_preset": uploadPreset,
      });

      Dio dio = Dio();
      Response response = await dio.post(url, data: formData);

      if (response.statusCode == 200) {
        return response.data["secure_url"];
      }
      return null;
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }
}
