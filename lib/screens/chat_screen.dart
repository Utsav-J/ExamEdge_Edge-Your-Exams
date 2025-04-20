import 'package:examedge/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.uniqueFilename});
  final String uniqueFilename;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;
  final _apiService = ApiService();
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleVoiceInput() {
    setState(() {
      _isRecording = !_isRecording;
    });
    // Implement voice recording logic
  }

  void _sendMessage() async {
    print("got here");
    if (_messageController.text.trim().isEmpty) return;
    print("got here 2");

    final userInput = _messageController.text.trim();
    context.read<ChatProvider>().addMessage(userInput, true);
    _messageController.clear();

    try {
      final response =
          await _apiService.chatWithPdf(widget.uniqueFilename, userInput);

      final aiMessage = response['response'] as String;
      final pages = response['pages_used'] as List;
      List<String> stringPages = pages.map((page) => "Page $page").toList();

      if (mounted) {
        context.read<ChatProvider>().addMessage(
              aiMessage,
              false,
              citations: stringPages,
            );
      }
    } catch (e) {
      if (mounted) {
        context.read<ChatProvider>().addMessage(
              'Sorry, something went wrong while fetching the response.',
              false,
            );
      }
      debugPrint('Error during chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: () {
              // Show help dialog
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: chatProvider.messages.length,
                  itemBuilder: (context, index) {
                    final message = chatProvider.messages[index];
                    return Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: message.isUser
                                    ? Colors.white
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                            if (message.citations != null &&
                                message.citations!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Sources: ${message.citations!.join(", ")}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: message.isUser
                                      ? Colors.white70
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                  onPressed: _handleVoiceInput,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask about the topic...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                Material(
                  child: IconButton(
                    icon: const Icon(Icons.get_app),
                    onPressed: () {
                      print("working");
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
