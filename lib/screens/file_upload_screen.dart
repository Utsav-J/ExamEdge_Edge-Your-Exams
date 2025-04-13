import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
// import 'package:provider/provider.dart';
// import '../providers/chat_provider.dart';
import '../services/storage_service.dart';
import '../models/recent_document.dart';
import 'document_screen.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _selectedFileName;
  String? _selectedFileType;
  String? _selectedFilePath;
  bool _isDragging = false;
  late StorageService _storageService;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.init();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'pptx'],
      );

      if (result != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
          _selectedFileType = result.files.single.extension;
          _selectedFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<String> _saveFileLocally(String originalPath) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _selectedFileName!;
    final savedFile = File('${directory.path}/$fileName');

    // Copy the file to local storage
    await File(originalPath).copy(savedFile.path);
    return savedFile.path;
  }

  void _processFile() async {
    if (_selectedFileName == null || _selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a file first'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Save to recent documents
    final localFilePath = await _saveFileLocally(_selectedFilePath!);
    await _storageService.addRecentDocument(
      RecentDocument(
        fileName: _selectedFileName!,
        fileType: _selectedFileType!,
        lastAccessed: DateTime.now(),
        localFilePath: localFilePath,
      ),
    );

    // Wait for 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    // Close the loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Navigate to document screen
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DocumentScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // File Upload Section
            DragTarget<Object>(
              onWillAccept: (data) {
                setState(() {
                  _isDragging = true;
                });
                return true;
              },
              onAccept: (data) {
                setState(() {
                  _isDragging = false;
                });
                // Handle file drop
                _pickFile();
              },
              onLeave: (data) {
                setState(() {
                  _isDragging = false;
                });
              },
              builder: (context, candidateData, rejectedData) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: _isDragging
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isDragging
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isDragging
                            ? 'Drop your file here'
                            : 'Drag and drop your file here',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'or',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.file_upload),
                        label: const Text('Browse Files'),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Supported formats: PDF, PPT, PPTX',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Selected File Info
            if (_selectedFileName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected File',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            _selectedFileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.slideshow,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedFileName = null;
                                _selectedFileType = null;
                                _selectedFilePath = null;
                              });
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _processFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Process Document'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
