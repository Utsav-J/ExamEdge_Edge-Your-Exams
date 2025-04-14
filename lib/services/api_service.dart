import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'https://a285-34-70-242-210.ngrok-free.app';

  Future<Map<String, dynamic>> uploadPdf(File file) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/upload-pdf/'));
      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(responseData);
      } else {
        throw Exception('Failed to upload PDF: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading PDF: $e');
    }
  }

  Future<Map<String, dynamic>> generateSummary(String filename) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate-summary/$filename'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating summary: $e');
    }
  }
}
