import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../models/recent_document.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  String? _errorMessage;
  late StorageService _storageService;
  final _apiService = ApiService();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.init();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _processDocument() async {
    if (!_isInitialized) {
      setState(() {
        _errorMessage = 'Storage service not initialized';
      });
      return;
    }

    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'Please select a PDF file first';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      // Upload to backend
      final uploadResponse = await _apiService.uploadPdf(_selectedFile!);

      // if (uploadResponse == null) {
      //   throw 'Upload failed: No response from server';
      // }

      final uniqueFilename = uploadResponse['unique_filename'];
      if (uniqueFilename == null) {
        throw 'Upload failed: No filename received';
      }

      // Save to local storage
      final document = RecentDocument(
        fileName: _selectedFile!.path.split('/').last,
        fileType: 'pdf',
        localFilePath: _selectedFile!.path,
        lastAccessed: DateTime.now(),
        uniqueFilename: uniqueFilename.toString(), // Ensure it's a string
      );

      await _storageService.saveRecentDocument(document);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            e is String ? e : 'Error processing document: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.upload_file,
                      size: 48,
                      color: Color.fromARGB(255, 211, 188, 253),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFile != null
                          ? 'Selected: ${_selectedFile!.path.split('/').last}'
                          : 'No file selected',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isUploading ? null : _pickFile,
                      icon: const Icon(Icons.file_upload),
                      label: const Text('Select PDF'),
                    ),
                  ],
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _processDocument,
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Processing...' : 'Process Document'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
