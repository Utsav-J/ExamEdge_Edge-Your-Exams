import 'package:flutter/material.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // ignore: unused_field
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Results'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Key Points'),
            Tab(text: 'MCQs'),
            Tab(text: 'Resources'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Download as PDF
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Key Points Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.circle),
                  title: Text('Key Point ${index + 1}'),
                  subtitle:
                      Text('Detailed explanation of key point ${index + 1}'),
                ),
              );
            },
          ),

          // MCQs Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(4, (optionIndex) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: RadioListTile<int>(
                            title: Text('Option ${optionIndex + 1}'),
                            value: optionIndex,
                            groupValue: null,
                            onChanged: (value) {
                              // Handle option selection
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),

          // Resources Tab
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: Icon(
                    index == 0
                        ? Icons.book
                        : index == 1
                            ? Icons.article
                            : Icons.play_circle,
                  ),
                  title: Text('Resource ${index + 1}'),
                  subtitle: Text(
                    index == 0
                        ? 'Book'
                        : index == 1
                            ? 'Research Paper'
                            : 'Video',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () {
                      // Open resource
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle AI Assistant
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}
