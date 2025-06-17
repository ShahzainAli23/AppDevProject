import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;
  String error = '';

  Future<void> signup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final pass = passController.text.trim();
    final confirm = confirmController.text.trim();

    setState(() {
      error = '';
      loading = true;
    });

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() {
        error = 'Please fill all fields.';
        loading = false;
      });
      return;
    }

    if (pass != confirm) {
      setState(() {
        error = 'Passwords do not match.';
        loading = false;
      });
      return;
    }

    try {
      final UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      await cred.user!.updateDisplayName(name);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        error =
            e.code == 'email-already-in-use'
                ? 'Email already exists.'
                : e.message ?? 'Something went wrong.';
        loading = false;
      });
      return;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset('assets/darbs_logo.png', height: 120),
            const SizedBox(height: 20),
            RichText(
              text: const TextSpan(
                text: 'CREATE YOUR ',
                style: TextStyle(fontSize: 22, color: Colors.white),
                children: [
                  TextSpan(
                    text: 'DARB\'S ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF9A825),
                    ),
                  ),
                  TextSpan(text: 'ACCOUNT'),
                ],
              ),
            ),
            const SizedBox(height: 30),

            fieldLabel("Name"),
            textField(nameController, "Enter Your Name"),

            fieldLabel("Email"),
            textField(emailController, "Enter Your Email"),

            fieldLabel("Password"),
            passwordField(passController, obscure1, () {
              setState(() => obscure1 = !obscure1);
            }),

            fieldLabel("Confirm Password"),
            passwordField(confirmController, obscure2, () {
              setState(() => obscure2 = !obscure2);
            }),

            const SizedBox(height: 14),
            if (error.isNotEmpty)
              Text(error, style: const TextStyle(color: Colors.redAccent)),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loading ? null : signup,
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
                        "SIGN UP",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              child: const Text(
                "Already have an account? Login",
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget fieldLabel(String text) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 6),
      child: Text(
        "$text*",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  InputDecoration fieldStyle(String hint) => InputDecoration(
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

  Widget textField(TextEditingController controller, String hint) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white),
    decoration: fieldStyle(hint),
  );

  Widget passwordField(
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle,
  ) => TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(color: Colors.white),
    decoration: fieldStyle("Enter Password").copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscure ? Icons.visibility_off : Icons.visibility,
          color: Colors.white54,
        ),
        onPressed: toggle,
      ),
    ),
  );
}
