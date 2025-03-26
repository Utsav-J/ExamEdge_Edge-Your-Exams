# ChatGPT Clone

A Flutter application that mimics the ChatGPT interface and functionality. This is a demonstration project that shows how to create a modern chat interface similar to ChatGPT.

## Features

- Modern Material Design 3 UI
- Dark and light theme support
- Markdown support for messages
- Responsive layout
- Message history management
- Loading states and animations

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/chat-gpt-clone.git
```

2. Navigate to the project directory:
```bash
cd chat-gpt-clone
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart              # Application entry point
├── models/               # Data models
│   └── chat_message.dart
├── providers/            # State management
│   └── chat_provider.dart
└── screens/             # UI screens
    └── chat_screen.dart
```

## Dependencies

- flutter_markdown: For rendering markdown in messages
- provider: For state management
- google_fonts: For custom typography
- http: For API communication (when implementing real API)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details. 