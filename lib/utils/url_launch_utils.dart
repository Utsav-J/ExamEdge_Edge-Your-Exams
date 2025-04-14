import 'package:examedge/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLaunchUtils {
  static Future<void> launchUserUrl(String url) async {
    final uri = Uri.parse(url);
    bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
}
