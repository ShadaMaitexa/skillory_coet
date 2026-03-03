import 'package:dio/dio.dart';
import '../utils/email_constants.dart';

class EmailService {
  final Dio _dio = Dio();

  Future<void> sendApprovalEmail({
    required String facultyName,
    required String facultyEmail,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        'https://api.emailjs.com/api/v1.0/email/send',
        data: {
          'service_id': EmailConstants.serviceId,
          'template_id': EmailConstants.templateId,
          'user_id': EmailConstants.publicKey,
          'template_params': {
            'to_email': facultyEmail,
            'subject': 'Skillory COET: Registration Approved',
            'message': 'Hello $facultyName,\n\nYour registration as $role has been approved by the admin.\n\nYou can now log in to the Skillory COET application with your registered email and password.\n\nRegards,\nSkillory Admin',
          },
        },
      );


      if (response.statusCode == 200) {
        print('Email sent successfully!');
      } else {
        print('Failed to send email: ${response.data}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}
