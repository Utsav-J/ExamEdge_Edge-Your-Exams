import 'package:flutter/material.dart';
import '../models/faculty.dart';
import '../reusable/mentor_profile_details.dart';

class FacultyListDialog extends StatelessWidget {
  final List<Faculty> faculties;

  const FacultyListDialog({
    super.key,
    required this.faculties,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Available Mentors',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Faculty List
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: faculties.length,
                itemBuilder: (context, index) {
                  final faculty = faculties[index];
                  return SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: MentorProfileCard(
                        id: faculty.id,
                        name: faculty.name,
                        title: faculty.title,
                        department: faculty.department,
                        expertise: faculty.expertise,
                        experienceYears: faculty.experienceYears,
                        rating: faculty.rating,
                        satisfactionRate: faculty.satisfactionRate,
                        sessionPrice: faculty.sessionPrice,
                        freeSessionsAvailable: faculty.freeSessionsAvailable,
                        contactEmail: faculty.contactEmail,
                        imageUrl: faculty.image,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
