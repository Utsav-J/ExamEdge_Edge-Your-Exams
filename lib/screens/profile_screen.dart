import 'package:examedge/reusable/developer_card.dart';
import 'package:examedge/reusable/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;
  File? _newProfileImage;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image != null) {
      setState(() {
        _newProfileImage = File(image.path);
      });
    }
  }

  Future<void> _updateProfile(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        displayName: _displayNameController.text,
        profileImage: _newProfileImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        setState(() {
          _isEditing = false;
          _newProfileImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => setState(() {
                _isEditing = false;
                _newProfileImage = null;
                final user =
                    Provider.of<AuthProvider>(context, listen: false).user;
                _displayNameController.text = user?.displayName ?? '';
              }),
            ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final user = authProvider.user;
          if (user == null) return const Center(child: Text('Not signed in'));

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _newProfileImage != null
                          ? FileImage(_newProfileImage!)
                          : (user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null) as ImageProvider?,
                      child: user.photoURL == null && _newProfileImage == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                  ],
                ),
              ),
              if (_isEditing)
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed:
                            _isLoading ? null : () => _updateProfile(context),
                        child: _isLoading
                            ? const SizedBox(
                                height: 10,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Save Changes'),
                      ),
                    ],
                  ),
                )
              else ...[
                ListTile(
                  title: const Text('Display Name'),
                  subtitle: Text(user.displayName ?? 'Not set'),
                ),
                ListTile(
                  title: const Text('Email'),
                  subtitle: Text(user.email ?? 'Not set'),
                ),
              ],
              // Settings Section
              const SizedBox(height: 12),
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
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Toggle notifications preferences'),
                      value: false,
                      onChanged: (value) {
                        value = !value;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              LogoutButton(onTap: () => authProvider.signOut()),
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
                      linkedinUrl:
                          'https://www.linkedin.com/in/iamutsavjaiswal/',
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
          );
        },
      ),
    );
  }
}
