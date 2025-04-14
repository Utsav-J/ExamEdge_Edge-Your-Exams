import 'package:flutter/material.dart';
import '../models/mcq.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class DocumentQuizScreen extends StatefulWidget {
  final String uniqueFilename;

  const DocumentQuizScreen({
    super.key,
    required this.uniqueFilename,
  });

  @override
  State<DocumentQuizScreen> createState() => _DocumentQuizScreenState();
}

class _DocumentQuizScreenState extends State<DocumentQuizScreen> {
  final _apiService = ApiService();
  late final StorageService _storageService;
  List<MCQ>? _mcqs;
  bool _isLoading = true;
  String? _error;
  int _currentQuestionIndex = 0;
  Map<int, String?> _userAnswers = {};
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.init();
    _loadMCQs();
  }

  Future<void> _loadMCQs() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Try to get cached MCQs first
      final cachedMCQs =
          await _storageService.getCachedMCQsForDocument(widget.uniqueFilename);

      if (cachedMCQs != null) {
        setState(() {
          _mcqs = cachedMCQs;
          _isLoading = false;
        });
        return;
      }

      // If no cached MCQs, fetch from API
      final mcqs = await _apiService.generateMCQs(widget.uniqueFilename);

      // Cache the MCQs
      await _storageService.cacheMCQs(widget.uniqueFilename, mcqs);

      setState(() {
        _mcqs = mcqs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading MCQs: $e';
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < (_mcqs?.length ?? 0) - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      setState(() {
        _showResults = true;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _showResults = false;
    });
  }

  int _calculateScore() {
    if (_mcqs == null) return 0;
    int correct = 0;
    for (int i = 0; i < _mcqs!.length; i++) {
      if (_userAnswers[i] == _mcqs![i].answer) {
        correct++;
      }
    }
    return correct;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMCQs,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_mcqs == null || _mcqs!.isEmpty) {
      return const Center(
        child: Text('No MCQs available for this document.'),
      );
    }

    if (_showResults) {
      return _buildResultsScreen();
    }

    return _buildQuizScreen();
  }

  Widget _buildQuizScreen() {
    final currentQuestion = _mcqs![_currentQuestionIndex];
    final selectedAnswer = _userAnswers[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _mcqs!.length,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Question ${_currentQuestionIndex + 1} of ${_mcqs!.length}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Question
          Text(
            currentQuestion.question,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),

          // Options
          ...currentQuestion.options.map((option) {
            final isSelected = selectedAnswer == option;
            final isCorrect = _showResults && option == currentQuestion.answer;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () => _selectAnswer(option),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),

          const Spacer(),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
              ElevatedButton.icon(
                onPressed: selectedAnswer != null ? _nextQuestion : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(_currentQuestionIndex == _mcqs!.length - 1
                    ? 'Finish'
                    : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final score = _calculateScore();
    final percentage = (score / _mcqs!.length * 100).round();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.quiz,
              size: 64,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Quiz Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Your Score: $score/${_mcqs!.length} ($percentage%)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
