![image](https://github.com/user-attachments/assets/2aa7cc4b-788d-4261-91fd-a4555f1f19d5)

ExamEdge is an AI-powered study companion application that helps students analyze and learn from their study materials more effectively. The application uses advanced AI to generate summaries, key points, and interactive quizzes from uploaded documents.

## Features

### Document Management
- **PDF Upload**: Upload and process PDF study materials
- **Recent Documents**: Quick access to recently uploaded documents
- **Swipe to Delete**: Easily manage your document library with swipe-to-delete functionality
- **Undo Delete**: Recover accidentally deleted documents with undo functionality

### Document Analysis
- **Smart Summaries**: AI-generated comprehensive summaries of your study materials
- **Key Points Extraction**: Important points automatically identified and listed
- **Main Topics**: Core topics and themes extracted from your documents
- **Interactive Learning**: Multiple ways to interact with your study material

### User Interface
- **Modern Design**: Clean and intuitive user interface
- **Dark/Light Theme**: Support for both dark and light modes
- **Responsive Layout**: Optimized for various screen sizes
- **Pull to Refresh**: Smooth refresh functionality
- **Progress Indicators**: Clear feedback for processing operations

## Technical Architecture

### Frontend (Flutter)
- **State Management**: Provider pattern for efficient state management
- **Local Storage**: SharedPreferences for persistent data storage
- **File Handling**: Native file picking and processing
- **Caching**: Local caching of document summaries for offline access

### Backend Integration
- **RESTful API**: Integration with AI processing backend
- **File Upload**: Multipart file upload handling
- **Async Processing**: Non-blocking document processing
- **Error Handling**: Comprehensive error handling and user feedback

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- iOS development setup (for iOS builds)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/examedge.git
```

2. Navigate to the project directory:
```bash
cd examedge
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the application:
```bash
flutter run
```

### Configuration

The application uses environment variables for configuration. Create a `.env` file in the project root with the following:

```env
API_BASE_URL=your_backend_url
```

## Usage Guide

### Uploading Documents
1. Tap the "+" button in the home screen
2. Select a PDF file from your device
3. Wait for the processing to complete
4. Access your document from the recent documents list

### Viewing Document Analysis
1. Tap on any document in the recent documents list
2. Navigate through different sections:
   - Summary
   - Key Points
   - Main Topics
   - Quiz (Coming Soon)

### Managing Documents
- **Delete**: Swipe left on any document to delete
- **Undo**: Use the undo button in the snackbar to recover deleted documents
- **Refresh**: Pull down to refresh the documents list


### Key Components
- **ApiService**: Handles all backend API communications
- **StorageService**: Manages local data persistence
- **ThemeProvider**: Handles theme state management
- **DocumentScreen**: Main document viewing interface
- **FileUploadScreen**: Handles document upload process

## Future Enhancements

- [ ] Interactive quiz generation
- [ ] Document sharing functionality
- [ ] Cloud synchronization
- [ ] Study progress tracking
- [ ] Collaborative study features
- [ ] Advanced document analytics
- [ ] Support for more file formats


Made with ❤️ by [Utsav-J](https://github.com/Utsav-J)
