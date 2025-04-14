import 'package:examedge/screens/document_chat_screen.dart';
import 'package:examedge/screens/document_quiz_screen.dart';
import 'package:examedge/screens/document_resources_screen.dart';
import 'package:examedge/screens/document_summary_screen.dart';
import 'package:flutter/material.dart';

class DocumentScreen extends StatefulWidget {
  final String uniqueFilename;
  final String fileName;
  const DocumentScreen({
    super.key,
    required this.fileName,
    required this.uniqueFilename,
  });

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DocumentSummaryScreen(uniqueFilename: widget.uniqueFilename),
      DocumentQuizScreen(uniqueFilename: widget.uniqueFilename),
      const DocumentResourcesScreen(),
      const DocumentChatScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.fileName,
          overflow: TextOverflow.fade,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'Resources',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'AI Chat',
          ),
        ],
      ),
    );
  }
}
