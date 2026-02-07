import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/auth_header.dart';
import '../widgets/rct_button.dart';
import '../widgets/rct_text_field.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SignUpScreen({super.key, required this.onToggleTheme});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _cinLast3 = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _cinLast3.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/auth_bg.jpg',
            fit: BoxFit.cover,
          ),

          // Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(color: Colors.black.withOpacity(0.10)),
          ),

          // Page content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: widget.onToggleTheme,
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                const AuthHeader(
                  title: "Join the club.",
                  subtitle:
                      "Create your RCT account to access your group schedule.",
                ),
                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign up",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 14),

                        RctTextField(
                          controller: _name,
                          label: "Name",
                          hint: "Your full name",
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        const SizedBox(height: 12),

                        RctTextField(
                          controller: _cinLast3,
                          label: "CIN (last 3 digits)",
                          hint: "e.g. 438",
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                        const SizedBox(height: 12),

                        RctTextField(
                          controller: _password,
                          label: "Password",
                          hint: "Create a password",
                          obscure: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                        ),

                        const SizedBox(height: 16),

                        RctButton(
                          text: "Create account",
                          onPressed: () {
                            // UI-only for now. Firebase later.
                          },
                        ),

                        const SizedBox(height: 10),

                        Center(
                          child: Text(
                            "By creating an account, you agree to the club guidelines.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark
                                  ? Colors.white.withOpacity(0.65)
                                  : Colors.black.withOpacity(0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
