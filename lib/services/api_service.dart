import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:examedge/models/mcq.dart';
import 'package:examedge/models/faculty.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late final FirebaseRemoteConfig _remoteConfig;
  static String? _baseUrl;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<void> initialize() async {
    _remoteConfig = FirebaseRemoteConfig.instance;
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.fetchAndActivate();
    _baseUrl = _remoteConfig.getString('backendBaseUrl');
    if (_baseUrl == null || _baseUrl!.isEmpty) {
      throw Exception('backendBaseUrl is not set in Remote Config');
    }
  }

  static Future<String> refreshAndGetBaseUrl() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.fetchAndActivate();

    final updatedBaseUrl = remoteConfig.getString('backendBaseUrl');

    if (updatedBaseUrl.isEmpty) {
      throw Exception(
          "Remote Config value 'backendBaseUrl' is missing or empty.");
    }

    _baseUrl = updatedBaseUrl;
    return _baseUrl!;
  }

  // Internal helper to ensure baseUrl is loaded before use
  Future<String> _getBaseUrl() async {
    if (_baseUrl == null) {
      return await refreshAndGetBaseUrl();
    }
    return _baseUrl!;
  }

  Future<Map<String, dynamic>> uploadPdf(File file) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/upload-pdf/');
    var request = http.MultipartRequest('POST', url);
    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return json.decode(responseData);
    } else {
      throw Exception('Failed to upload PDF: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> generateSummary(String filename) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/generate-summary/$filename');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to generate summary: ${response.statusCode}');
    }
  }

  Future<List<MCQ>> generateMCQs(String filename, {int? startPage}) async {
    final baseUrl = await _getBaseUrl();
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
  }

  Future<Map<String, dynamic>> fetchBooks(String filename) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/fetch-books/$filename');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch books: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchVideos(String filename) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/fetch-videos/$filename');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch videos: ${response.statusCode}');
    }
  }

  Future<List<Faculty>> fetchFaculties(String filename) async {
    final baseUrl = await _getBaseUrl();
    final url = Uri.parse('$baseUrl/fetch-faculties/$filename');
    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final facultiesJson = data['faculties'] as List;
      return facultiesJson.map((json) => Faculty.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch faculties: ${response.statusCode}');
    }
  }
}
