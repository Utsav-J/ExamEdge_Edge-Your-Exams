import 'package:examedge/utils/url_launch_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../reusable/book_details_dialog.dart';
import '../services/api_service.dart';
import 'package:html_unescape/html_unescape.dart';
import '../models/video.dart';
import '../services/storage_service.dart';

class DocumentResourcesScreen extends StatefulWidget {
  final String uniqueFilename;

  const DocumentResourcesScreen({
    super.key,
    required this.uniqueFilename,
  });

  @override
  State<DocumentResourcesScreen> createState() =>
      _DocumentResourcesScreenState();
}

class _DocumentResourcesScreenState extends State<DocumentResourcesScreen> {
  final unescape = HtmlUnescape();
  final _apiService = ApiService();
  late final StorageService _storageService;
  bool _isLoadingVideos = true;
  bool _isLoadingBooks = true;
  String? _videoError;
  String? _bookError;
  List<Video> _videos = [];
  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _initStorage();
  }

  Future<void> _initStorage() async {
    _storageService = await StorageService.init();
    _loadResources();
  }

  Future<void> _loadResources() async {
    _loadVideos();
    _loadBooks();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        _isLoadingVideos = true;
        _videoError = null;
      });

      // Try to get cached videos first
      final cachedVideos =
          _storageService.getCachedVideos(widget.uniqueFilename);

      if (cachedVideos != null) {
        final videosData = cachedVideos['videos'] as Map<String, dynamic>;
        final videos = videosData.entries.map((entry) {
          return Video.fromJson(entry.key, entry.value as Map<String, dynamic>);
        }).toList();

        setState(() {
          _videos = videos;
          _isLoadingVideos = false;
        });
        return;
      }

      // If no cached videos, fetch from API
      final response = await _apiService.fetchVideos(widget.uniqueFilename);

      // Cache the videos
      await _storageService.cacheVideos(widget.uniqueFilename, response);

      final videosData = response['videos'] as Map<String, dynamic>;
      final videos = videosData.entries.map((entry) {
        return Video.fromJson(entry.key, entry.value as Map<String, dynamic>);
      }).toList();

      setState(() {
        _videos = videos;
        _isLoadingVideos = false;
      });
    } catch (e) {
      setState(() {
        _videoError = 'Error loading videos: $e';
        _isLoadingVideos = false;
      });
    }
  }

  Future<void> _loadBooks() async {
    try {
      setState(() {
        _isLoadingBooks = true;
        _bookError = null;
      });

      // Try to get cached books first
      final cachedBooks = _storageService.getCachedBooks(widget.uniqueFilename);

      if (cachedBooks != null) {
        final booksData = cachedBooks['books'][0] as Map<String, dynamic>;
        final books = booksData.entries.map((entry) {
          return Book.fromJson(entry.key, entry.value as Map<String, dynamic>);
        }).toList();

        setState(() {
          _books = books;
          _isLoadingBooks = false;
        });
        return;
      }

      // If no cached books, fetch from API
      final response = await _apiService.fetchBooks(widget.uniqueFilename);

      // Cache the books
      await _storageService.cacheBooks(widget.uniqueFilename, response);

      final booksData = response['books'][0] as Map<String, dynamic>;
      final books = booksData.entries.map((entry) {
        return Book.fromJson(entry.key, entry.value as Map<String, dynamic>);
      }).toList();

      setState(() {
        _books = books;
        _isLoadingBooks = false;
      });
    } catch (e) {
      setState(() {
        _bookError = 'Error loading books: $e';
        _isLoadingBooks = false;
      });
    }
  }

  // Add refresh functionality
  Future<void> _refreshResources() async {
    // Clear the cache
    await _storageService.clearDocumentCache(widget.uniqueFilename);
    // Reload resources
    _loadResources();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showBookDetails(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (context) => BookDetailsDialog(book: book),
    );
  }

  Widget _buildVideoSection() {
    if (_isLoadingVideos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videoError != null) {
      return _buildErrorWidget(_videoError!, _loadVideos);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CupertinoIcons.play_circle_fill,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Videos to clear your doubts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Based on topics in your document',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_videos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No relevant videos found'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _videos.length,
                itemBuilder: (context, index) {
                  final video = _videos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => UrlLaunchUtils.launchUserUrl(video.url),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                video.thumbnail,
                                width: 120,
                                height: 68,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 120,
                                    height: 68,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.play_circle_outline,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Video Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    video.title,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    video.channel,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                            color: const Color.fromARGB(
                                                255, 235, 114, 114)),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
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
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshResources,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildVideoSection(),
          const SizedBox(height: 24),
          _buildBookSection(),
        ],
      ),
    );
  }

  Widget _buildBookSection() {
    if (_isLoadingBooks) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookError != null) {
      return _buildErrorWidget(_bookError!, _loadBooks);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reference Books',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Based on topics in your document',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_books.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No relevant books found'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: InkWell(
                      onTap: () => _showBookDetails(context, book),
                      child: Hero(
                        tag: 'book-${book.title}',
                        child: Material(
                          type: MaterialType.transparency,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Book Cover
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    book.thumbnail,
                                    width: 60,
                                    height: 90,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.book,
                                            size: 24,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Book Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.authors,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                                color: const Color.fromARGB(
                                                    255, 231, 192, 78)),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        unescape.convert(book.description),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                    ],
                                  ),
                                ),
                                // Add topic chip
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
