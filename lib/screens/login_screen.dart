import 'package:examedge/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  GoogleSignInAccount? _previousUser;
  AuthService authService = AuthService();
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

  // Future<void> _signInWithGoogleAccountPicker(BuildContext context) async {
  //   try {
  //     final googleSignIn = GoogleSignIn();
  //     await googleSignIn.signOut(); // Force picker
  //     final googleUser = await googleSignIn.signIn();

  //     if (googleUser == null) return;

  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LoggedInUserInfo(),
  //       ),
  //     );
  //   } catch (e) {
  //     _showError(context, e.toString());
  //   }
  // }

  // Future<void> _signInSilentlyWithLastUsedAccount(BuildContext context) async {
  //   try {
  //     final googleUser = _previousUser ?? await GoogleSignIn().signInSilently();

  //     if (googleUser == null) {
  //       _showError(context, 'No previously signed-in account found.');
  //       return;
  //     }

  //     final googleAuth = await googleUser.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     await FirebaseAuth.instance.signInWithCredential(credential);
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const LoggedInUserInfo(),
  //       ),
  //     );
  //   } catch (e) {
  //     _showError(context, e.toString());
  //   }
  // }

  // void _showError(BuildContext context, String msg) {
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  // }

  @override
  @override
  Widget build(BuildContext context) {
    final hasPrevUser = _previousUser != null;
    // final colorScheme = Theme.of(context).colorScheme;
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
                    stops: [
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
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    "Exam Edge",
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontSize: 32),
                  ),
                  const SizedBox(
                    height: 180,
                  ),
                  ElevatedButton.icon(
                    onPressed: () =>
                        authService.signInWithGoogleAccountPicker(context),
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
                        ? () => authService.signInSilentlyWithLastUsedAccount(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
