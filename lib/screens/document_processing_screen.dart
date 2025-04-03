import 'package:chat_gpt_clone/screens/results_screen.dart';
import 'package:flutter/material.dart';

class DocumentProcessingScreen extends StatefulWidget {
  const DocumentProcessingScreen({super.key});

  @override
  State<DocumentProcessingScreen> createState() =>
      _DocumentProcessingScreenState();
}

class _DocumentProcessingScreenState extends State<DocumentProcessingScreen> {
  int _currentStep = 0;
  final List<String> _steps = [
    'Extracting text...',
    'Generating key points...',
    'Creating MCQs...',
    'Searching resources...',
  ];

  @override
  void initState() {
    super.initState();
    // Simulate processing steps
    _simulateProcessing();
  }

  Future<void> _simulateProcessing() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _currentStep = i + 1;
        });
      }
    }
    // Navigate to results screen when done
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ResultsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Processing Document'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Name.pdf',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PDF Document',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: (_currentStep / _steps.length),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              _steps.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Icon(
                      index < _currentStep
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: index < _currentStep
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _steps[index],
                      style: TextStyle(
                        color: index < _currentStep
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
