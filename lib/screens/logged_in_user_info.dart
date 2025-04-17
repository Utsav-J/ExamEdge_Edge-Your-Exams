import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoggedInUserInfo extends StatelessWidget {
  const LoggedInUserInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text("No user is currently signed in."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Logged In User Info'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (user.photoURL != null)
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(user.photoURL!),
            ),
          const SizedBox(height: 20),
          _infoTile("Display Name", user.displayName),
          _infoTile("Email", user.email),
          _infoTile("Phone Number", user.phoneNumber),
          _infoTile("UID", user.uid),
          _infoTile("Provider ID", user.providerData.first.providerId),
          _infoTile("Email Verified", user.emailVerified.toString()),
          _infoTile("Creation Time", user.metadata.creationTime.toString()),
          _infoTile(
              "Last Sign-In Time", user.metadata.lastSignInTime.toString()),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String? value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value ?? 'N/A'),
    );
  }
}
