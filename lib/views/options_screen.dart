import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'about_screen.dart';
import 'privacy_screen.dart';
import 'terms_screen.dart';

class OptionsScreen extends StatelessWidget {
  final bool isGuest;
  const OptionsScreen({super.key, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'ACCOUNT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          buildTile(
            icon: Icons.person_outline,
            label: 'My Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          buildTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()),
              );
            },
          ),
          buildTile(
            icon: Icons.info_outline,
            label: 'About Us',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
          buildTile(
            icon: Icons.description_outlined,
            label: 'Terms & Conditions',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () async {
              if (isGuest) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              } else {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            leading: const Icon(Icons.logout, color: Color(0xFFF9A825)),
            title: Text(
              isGuest ? 'Login' : 'Logout',
              style: const TextStyle(
                color: Color(0xFFF9A825),
                fontWeight: FontWeight.bold,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ],
      ),
    );
  }

  Widget buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.white54,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
    );
  }
}
