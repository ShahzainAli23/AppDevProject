import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isUpdatingName = false;
  bool _isUpdatingPassword = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
  }

  void _updateDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == user?.displayName) return;

    setState(() => _isUpdatingName = true);
    await user?.updateDisplayName(newName);
    await user?.reload();
    setState(() {
      _isUpdatingName = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Username updated!')));
  }

  void _updatePassword() async {
    final newPassword = _passwordController.text.trim();
    if (newPassword.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be 6+ characters')),
      );
      return;
    }

    setState(() => _isUpdatingPassword = true);
    try {
      await user?.updatePassword(newPassword);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password updated!')));
      _passwordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error updating password. Reauthenticate.'),
        ),
      );
    } finally {
      setState(() => _isUpdatingPassword = false);
    }
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text("Not logged in", style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'PROFILE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Info',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Email: ${user!.email}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildInputCard(
            label: 'Change Username',
            controller: _nameController,
            hint: 'Enter new name',
            buttonLabel: 'Update',
            isLoading: _isUpdatingName,
            onPressed: _updateDisplayName,
          ),
          const SizedBox(height: 20),
          _buildInputCard(
            label: 'Change Password',
            controller: _passwordController,
            hint: 'Enter new password',
            isObscure: true,
            buttonLabel: 'Update',
            isLoading: _isUpdatingPassword,
            onPressed: _updatePassword,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _signOut,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool isObscure = false,
    bool isLoading = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isObscure,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: Colors.white10,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A825),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size.fromHeight(45),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
