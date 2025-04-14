import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:examedge/models/mcq.dart';
import 'package:examedge/models/faculty.dart';

class ApiService {
  static const String baseUrl = 'https://b1ea-34-19-127-113.ngrok-free.app';

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

  Future<List<MCQ>> generateMCQs(String filename, {int? startPage}) async {
    try {
      final url = Uri.parse(
          '$baseUrl/generate-mcqs/$filename${startPage != null ? '?start_page=$startPage' : ''}');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> mcqsJson = data['mcqs'];
        return mcqsJson.map((json) => MCQ.fromJson(json)).toList();
      } else {
        throw Exception('Failed to generate MCQs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating MCQs: $e');
    }
  }

  Future<Map<String, dynamic>> fetchBooks(String filename) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fetch-books/$filename'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch books: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching books: $e');
    }
  }

  Future<Map<String, dynamic>> fetchVideos(String filename) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fetch-videos/$filename'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to fetch videos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  Future<List<Faculty>> fetchFaculties(String filename) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/fetch-faculties/$filename'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final facultiesJson = data['faculties'] as List;
        return facultiesJson.map((json) => Faculty.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch faculties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching faculties: $e');
    }
  }
}
