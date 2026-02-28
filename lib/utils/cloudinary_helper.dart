import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryHelper {
  // Constants for Cloudinary (Ideally these should be in a config/env file)
  static const String cloudName = "dpfhr81ee";
  static const String uploadPreset = "coet_images";

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
