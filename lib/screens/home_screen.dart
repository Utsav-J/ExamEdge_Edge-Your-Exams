import 'package:chat_gpt_clone/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:provider/provider.dart';
// import '../providers/chat_provider.dart';
import '../services/storage_service.dart';
import '../models/recent_document.dart';
import 'file_upload_screen.dart';
import 'document_screen.dart';
import 'pdf_viewer_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StorageService _storageService;
  List<RecentDocument> _recentDocuments = [];

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.init();
    _loadRecentDocuments();
  }

  void _loadRecentDocuments() {
    setState(() {
      _recentDocuments = _storageService.getRecentDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('ExamEdge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FileUploadScreen(),
                ),
              ).then((_) => _loadRecentDocuments());
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () {
              themeProvider.setThemeMode(
                  themeProvider.isDarkMode ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Welcome Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to ExamEdge',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your study materials to get started',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Recent Documents Section
          Text(
            'Recent Documents',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          if (_recentDocuments.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'No recent documents',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
            )
          else
            ..._recentDocuments.map((doc) => Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            doc.fileType == 'pdf'
                                ? Icons.picture_as_pdf
                                : Icons.slideshow,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          doc.fileName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Last accessed: ${_getTimeAgo(doc.lastAccessed)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                if (doc.fileType == 'pdf')
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.visibility),
                                    label: const Text('View PDF'),
                                    onPressed: () => _viewPDF(doc),
                                  ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.auto_stories),
                                  label: const Text('Study'),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DocumentScreen(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _viewPDF(RecentDocument document) async {
    if (document.fileType != 'pdf') return;

    try {
      final file = File(document.localFilePath);
      if (!file.existsSync()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('PDF file not found'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
        return;
      }

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PDFViewerScreen(filePath: document.localFilePath),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
