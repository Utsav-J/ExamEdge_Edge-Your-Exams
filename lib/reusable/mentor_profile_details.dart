import 'package:flutter/material.dart';

class MentorProfileCard extends StatelessWidget {
  final String id;
  final String name;
  final String title;
  final String department;
  final List<String> expertise;
  final int experienceYears;
  final double rating;
  final String satisfactionRate;
  final double sessionPrice;
  final List<DateTime> freeSessionsAvailable;
  final String contactEmail;
  final String imageUrl;

  const MentorProfileCard({
    super.key,
    required this.id,
    required this.name,
    required this.title,
    required this.department,
    required this.expertise,
    required this.experienceYears,
    required this.rating,
    required this.satisfactionRate,
    required this.sessionPrice,
    required this.freeSessionsAvailable,
    required this.contactEmail,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with image and basic info
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(imageUrl),
                    backgroundColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onBackgroundImageError: (_, __) {
                      // Placeholder for error
                    },
                  ),
                  const SizedBox(width: 16),
                  // Basic Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          department,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 5, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat(
                    context,
                    Icons.star,
                    rating.toString(),
                    'Rating',
                    Colors.amber,
                  ),
                  _buildStat(
                    context,
                    Icons.work,
                    '$experienceYears yrs',
                    'Experience',
                    Colors.blue,
                  ),
                  _buildStat(
                    context,
                    Icons.thumb_up,
                    satisfactionRate,
                    'Satisfaction',
                    Colors.green,
                  ),
                ],
              ),
            ),

            // Expertise Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expertise',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: expertise
                        .map((skill) => Chip(
                              label: Text(skill),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                              labelStyle: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondaryContainer,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Available Sessions
            // if (freeSessionsAvailable.isNotEmpty) ...[
            //   const SizedBox(height: 16),
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 16),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Available Free Sessions',
            //           style: Theme.of(context).textTheme.titleMedium?.copyWith(
            //                 fontWeight: FontWeight.bold,
            //               ),
            //         ),
            //         const SizedBox(height: 8),
            //         ...freeSessionsAvailable
            //             .map((session) => Card(
            //                   color: Theme.of(context)
            //                       .colorScheme
            //                       .primaryContainer
            //                       .withOpacity(0.1),
            //                   child: ListTile(
            //                     leading: const Icon(Icons.calendar_today),
            //                     title: Text(
            //                       DateFormat('EEEE, MMM d, y').format(session),
            //                       style: Theme.of(context).textTheme.bodyLarge,
            //                     ),
            //                     subtitle: Text(
            //                       DateFormat('h:mm a').format(session),
            //                       style: Theme.of(context).textTheme.bodyMedium,
            //                     ),
            //                     trailing: OutlinedButton(
            //                       onPressed: () {
            //                         // Handle session booking
            //                       },
            //                       child: const Text('Book'),
            //                     ),
            //                   ),
            //                 ))
            //             .toList(),
            //       ],
            //     ),
            //   ),
            // ],

            // Contact and Price Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        Text(
                          contactEmail,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '₹${sessionPrice.toStringAsFixed(0)}/session',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
