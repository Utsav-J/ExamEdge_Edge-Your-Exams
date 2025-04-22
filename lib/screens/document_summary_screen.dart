import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/document_summary.dart';
import '../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DocumentSummaryScreen extends StatefulWidget {
  final String uniqueFilename;

  const DocumentSummaryScreen({
    super.key,
    required this.uniqueFilename,
  });

  @override
  State<DocumentSummaryScreen> createState() => _DocumentSummaryScreenState();
}

class _DocumentSummaryScreenState extends State<DocumentSummaryScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  DocumentSummary? _summary;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    try {
      setState(() => _isLoading = true);

      // Try to get summary from Firestore first
      final cachedSummary = await _firestoreService.getDocumentSummary(
        widget.uniqueFilename,
      );

      if (cachedSummary != null) {
        setState(() {
          _summary = cachedSummary;
          _isLoading = false;
        });
        return;
      }

      // If not in Firestore, fetch from API
      final response = await _apiService.generateSummary(widget.uniqueFilename);

      final summary = DocumentSummary(
        documentOverview: response['document_overview'],
        keyPoints: List<String>.from(response['key_points']),
        mainTopics: List<String>.from(response['main_topics']),
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      // Save to Firestore
      await _firestoreService.saveDocumentSummary(
        widget.uniqueFilename,
        summary,
      );

      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSummary,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_summary == null) {
      return const Center(child: Text('No summary available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Overview',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(_summary!.documentOverview),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Points',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ..._summary!.keyPoints.map((point) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(point)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Main Topics',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _summary!.mainTopics
                        .map((topic) => Chip(
                              label: Text(topic),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(" ")
        ],
      ),
    );
  }
}
