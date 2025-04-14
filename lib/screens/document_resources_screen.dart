import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/book.dart';
import '../reusable/book_details_dialog.dart';

class DocumentResourcesScreen extends StatelessWidget {
  const DocumentResourcesScreen({super.key});

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

  // Example book data - in a real app, this would come from an API or service
  List<Book> _getExampleBooks() {
    return [
      Book.fromJson({
        "title":
            "AWS certification guide - AWS Certified Solutions Architect - Professional",
        "authors": "Cybellium Ltd",
        "description":
            "AWS Certification Guide - AWS Certified Solutions Architect – Professional Elevate Your Architectural Expertise to the Professional Level Embark on a transformative journey to the pinnacle of AWS architecture with this in-depth guide, designed specifically for those aspiring to become AWS Certified Solutions Architects at the Professional level.",
        "preview":
            "http://books.google.com/books?id=rfboEAAAQBAJ&pg=PA54&dq=IAM+Users&hl=&cd=1&source=gbs_api",
        "thumbnail":
            "http://books.google.com/books/content?id=rfboEAAAQBAJ&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
      }),
      Book.fromJson({
        "title": "Flutter Development for Beginners",
        "authors": "John Doe",
        "description":
            "A comprehensive guide to Flutter development for beginners. Learn how to build beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.",
        "preview":
            "http://books.google.com/books?id=example2&pg=PA1&dq=Flutter&hl=&cd=1&source=gbs_api",
        "thumbnail":
            "http://books.google.com/books/content?id=example2&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
      }),
      Book.fromJson({
        "title": "Advanced Machine Learning Techniques",
        "authors": "Jane Smith",
        "description":
            "Explore advanced machine learning techniques including deep learning, reinforcement learning, and natural language processing with practical examples and real-world applications.",
        "preview":
            "http://books.google.com/books?id=example3&pg=PA1&dq=Machine+Learning&hl=&cd=1&source=gbs_api",
        "thumbnail":
            "http://books.google.com/books/content?id=example3&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api"
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final books = _getExampleBooks();

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Videos Section
        Card(
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
                    Text(
                      'Videos to clear your doubts',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3, // Example videos
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () => _launchUrl(
                            'https://www.youtube.com/watch?v=example$index'),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // Thumbnail
                              Container(
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
                              ),
                              const SizedBox(width: 12),
                              // Video Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Related Video ${index + 1}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Duration: 10:${index * 5} • Views: ${(index + 1) * 1000}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
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
        ),
        const SizedBox(height: 24),

        // Reference Books Section
        Card(
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
                    Text(
                      'Reference Books',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
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
                                              .bodySmall,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          book.description,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber[700],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '4.5',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                            const Spacer(),
                                            const Icon(Icons.arrow_forward_ios,
                                                size: 16),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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
        ),
      ],
    );
  }
}
