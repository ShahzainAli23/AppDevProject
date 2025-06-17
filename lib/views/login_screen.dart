import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'signup_screen.dart';
import 'MainNavigationController.dart';

class LoginScreen extends StatefulWidget {
  final bool returnToCheckout;

  const LoginScreen({super.key, this.returnToCheckout = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  String error = '';
  bool obscure = true;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      setState(() => loading = false);

      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainNavigationController(isGuest: false),
          ),
        );
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password') {
          error = 'Invalid email or password.';
        } else {
          error = 'Something went wrong.';
        }
        loading = false;
      });
    }
  }

  void guestLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainNavigationController(isGuest: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Image.asset('assets/darbs_logo.png', height: 140),
            const SizedBox(height: 24),
            RichText(
              text: const TextSpan(
                text: 'LOGIN TO ',
                style: TextStyle(fontSize: 22, color: Colors.white),
                children: [
                  TextSpan(
                    text: 'DARB\'S',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9A825),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Enter Email*", style: labelStyle),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              style: inputTextStyle,
              decoration: inputDecoration("Enter Your Email"),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text("Enter Password*", style: labelStyle),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: obscure,
              style: inputTextStyle,
              decoration: inputDecoration("Enter Your Password").copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),

            const SizedBox(height: 10),

            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.redAccent)),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A825),
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                        "SIGN IN",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: guestLogin,
              child: const Text(
                "Continue as Guest",
                style: TextStyle(color: Colors.white70),
              ),
            ),

            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account? ",
                  style: TextStyle(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    );
                  },
                  child: const Text(
                    "SIGN UP",
                    style: TextStyle(
                      color: Color(0xFFF9A825),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: Colors.black,
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF9A825), width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFF9A825), width: 1.8),
    ),
  );

  TextStyle get labelStyle => const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );

  TextStyle get inputTextStyle => const TextStyle(color: Colors.white);

  TextStyle get linkStyle =>
      const TextStyle(color: Color(0xFFF9A825), fontWeight: FontWeight.w500);
}
