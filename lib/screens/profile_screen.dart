import 'package:examedge/reusable/developer_card.dart';
import 'package:examedge/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            child: const Icon(Icons.login),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/user.jpg",
                          width: 100, // diameter (2 * radius)
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Utsav Jaiswal',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'uj8866@srmist.edu.in',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Settings Section
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return SwitchListTile(
                        title: const Text('Dark Mode'),
                        subtitle: const Text('Toggle dark/light theme'),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.setThemeMode(
                              value ? ThemeMode.dark : ThemeMode.light);
                        },
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show language selection dialog
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Notifications'),
                    subtitle: const Text('Manage notification preferences'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Show notification settings
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Meet the developers',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  DeveloperCard(
                    name: 'Utsav Jaiswal',
                    role: 'Full Stack App Developer',
                    linkedinUrl: 'https://www.linkedin.com/in/iamutsavjaiswal/',
                    githubUrl: 'https://github.com/Utsav-J',
                    imageUrl: 'assets/images/utsav.jpeg',
                    glowColor: const Color.fromARGB(255, 158, 255, 166)
                        .withOpacity(0.25),
                  ),
                  DeveloperCard(
                    name: 'Ujjwal Agrahari',
                    role: 'Full Stack Web Developer',
                    linkedinUrl:
                        'https://www.linkedin.com/in/ujjwal-agrahari-359105253/',
                    githubUrl: 'https://github.com/Ujjwalagrhri918',
                    imageUrl: 'assets/images/ujjwal.jpeg',
                    glowColor: const Color.fromARGB(255, 158, 232, 255)
                        .withOpacity(0.25),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
