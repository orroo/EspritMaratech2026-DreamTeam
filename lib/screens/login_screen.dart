import 'package:flutter/material.dart';
import 'package:running_club_tunis/screens/app_shell.dart';
import '../widgets/auth_header.dart';
import '../widgets/rct_button.dart';
import '../widgets/rct_text_field.dart';
import '../theme/app_theme.dart';
import 'signup_screen.dart';
import 'admin/admin_shell.dart';


class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _name = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(
              children: [
                Text(
                  "RCT",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onToggleTheme,
                  icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const AuthHeader(
              title: "Ready to run?",
              subtitle: "Log in to see today’s sessions and your group events.",
            ),
            const SizedBox(height: 16),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Log in",
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
                      controller: _password,
                      label: "Password",
                      hint: "••••••••",
                      obscure: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    const SizedBox(height: 14),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot password?",
                          style: TextStyle(
                            color: isDark ? AppColors.silver : Colors.black87,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ✅ TEMP: bypass auth for UI testing
                    RctButton(
                      text: "Continue",
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AppShell(onToggleTheme: widget.onToggleTheme),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "New here? ",
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.75)
                                : Colors.black.withOpacity(0.65),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SignUpScreen(
                                  onToggleTheme: widget.onToggleTheme,
                                ),
                              ),
                            );
                          },
                          child: const Text("Create account"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
