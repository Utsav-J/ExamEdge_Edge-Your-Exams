import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'chat_screen.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _selectedFileName;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      setState(() => _isLoading = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null) {
        setState(() {
          _selectedFileName = result.files.single.name;
        });
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleAction(String action) {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a file first')),
      );
      return;
    }

    // Navigate to chat screen with the selected action
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          initialMessage: 'I want to $action the file: $_selectedFileName',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      color: Color(0xFF10A37F),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _selectedFileName ?? 'No file selected',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _pickFile,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload),
                      label: Text(_selectedFileName == null
                          ? 'Upload File'
                          : 'Change File'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildActionButton(
                  context,
                  'Summarize',
                  Icons.summarize,
                  () => _handleAction('summarize'),
                ),
                _buildActionButton(
                  context,
                  'Generate MCQ',
                  Icons.quiz,
                  () => _handleAction('generate MCQ from'),
                ),
                _buildActionButton(
                  context,
                  'Find Study Materials',
                  Icons.school,
                  () => _handleAction('find study materials related to'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: 160,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        ),
      ),
    );
  }
}
