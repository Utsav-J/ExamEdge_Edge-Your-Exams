import 'package:examedge/services/api_service.dart';
import 'package:examedge/reusable/faculty_list_dialog.dart';
import 'package:flutter/material.dart';

class DocumentFAB extends StatefulWidget {
  final String uniqueFilename;

  const DocumentFAB({
    super.key,
    required this.uniqueFilename,
  });

  @override
  State<DocumentFAB> createState() => _DocumentFABState();
}

class _DocumentFABState extends State<DocumentFAB> {
  final _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _showFacultyList() async {
    setState(() => _isLoading = true);

    try {
      final faculties = await _apiService.fetchFaculties(widget.uniqueFilename);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => FacultyListDialog(faculties: faculties),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: _isLoading ? null : _showFacultyList,
      icon: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(),
            )
          : const Icon(Icons.person_search),
      label: Text(_isLoading ? 'Loading...' : 'Find Mentors'),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
    );
  }
}
