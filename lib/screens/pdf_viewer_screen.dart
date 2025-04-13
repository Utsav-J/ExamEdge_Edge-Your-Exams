import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class PDFViewerScreen extends StatefulWidget {
  final String filePath;

  const PDFViewerScreen({
    super.key,
    required this.filePath,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkFile();
  }

  void _checkFile() {
    final file = File(widget.filePath);
    if (!file.existsSync()) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'PDF file not found';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        PDFView(
          filePath: widget.filePath,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: true,
          pageFling: true,
          onRender: (_pages) {
            setState(() {
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = 'Error loading PDF: $error';
            });
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
