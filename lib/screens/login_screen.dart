import 'package:examedge/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  GoogleSignInAccount? _previousUser;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _loadPreviousGoogleUser();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPreviousGoogleUser() async {
    final user = await GoogleSignIn().signInSilently();
    if (mounted) {
      setState(() {
        _previousUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPrevUser = _previousUser != null;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [
                      Color.fromARGB(255, 57, 20, 95), // Deep Purple
                      Colors.black,
                      Color.fromARGB(255, 58, 37, 108), // Rich Purple
                    ],
                    stops: const [
                      0,
                      0.5,
                      1.0,
                    ],
                    transform: GradientRotation(_animation.value * 2 * 3.14159),
                  ),
                ),
              );
            },
          ),
          // Existing Content
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome to",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    "Exam Edge",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 180),
                  if (authProvider.isLoading)
                    const CircularProgressIndicator(color: Colors.white)
                  else ...[
                    ElevatedButton.icon(
                      onPressed: () =>
                          authProvider.signInWithGoogleAccountPicker(context),
                      icon: const Icon(Icons.account_circle),
                      label: const Text('Sign in with Google'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: Colors.white.withOpacity(0.9),
                        foregroundColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: hasPrevUser
                          ? () =>
                              authProvider.signInSilentlyWithLastUsedAccount(
                                  context, _previousUser)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasPrevUser
                            ? Colors.white.withOpacity(0.8)
                            : Colors.grey.shade300.withOpacity(0.5),
                        foregroundColor: Colors.black87,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_previousUser?.photoUrl != null)
                            CircleAvatar(
                              radius: 12,
                              backgroundImage:
                                  NetworkImage(_previousUser!.photoUrl!),
                            )
                          else
                            const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text(
                            hasPrevUser
                                ? 'Sign in with ${_previousUser!.email}'
                                : 'No recent account found',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (authProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      authProvider.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
