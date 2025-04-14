import 'package:examedge/main.dart';
import 'package:examedge/reusable/social_button.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String linkedinUrl;
  final String githubUrl;
  final String? role;
  final Color glowColor;

  const DeveloperCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.linkedinUrl,
    required this.githubUrl,
    required this.glowColor,
    this.role,
  });

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    print("Launching URL: $url");
    // First try to launch in external app (if available)
    bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    print("Launched: $launched");
    // If it fails, fallback to browser
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    }

    // If both fail, show an error
    if (!launched) {
      debugPrint('Could not launch URL: $url');
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        const SnackBar(content: Text('Unable to open the link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Profile Image with Glow Effect
            Stack(
              alignment: Alignment.center,
              children: [
                // Glow Effect
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor,
                        blurRadius: 60,
                        spreadRadius: 15,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            if (role != null) ...[
              const SizedBox(height: 4),
              Text(
                role!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),

            // Social Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LinkedIn Button
                SocialButton(
                  icon: Icons.inbox,
                  label: 'LinkedIn',
                  onPressed: () => _launchUrl(linkedinUrl),
                  color: const Color(0xFF0077B5),
                ),
                const SizedBox(width: 16),
                // GitHub Button
                SocialButton(
                  icon: Icons.code,
                  label: 'GitHub',
                  onPressed: () => _launchUrl(githubUrl),
                  color: const Color(0xFF333333),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
