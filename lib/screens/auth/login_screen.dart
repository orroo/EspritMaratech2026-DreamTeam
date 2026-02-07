import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/base_screen.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameController = TextEditingController();
  final _cinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _cinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _errorMessage = '');
      
      final success = await Provider.of<AuthService>(context, listen: false)
          .login(_nameController.text.trim(), _cinController.text.trim());

      if (!success) {
        setState(() => _errorMessage = 'Identifiants incorrects');
      }
    }
  }

  void _handleVisitorAccess() {
    Provider.of<AuthService>(context, listen: false).login('visitor', '');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthService>(context).isLoading;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return BaseScreen(
      title: '',
      showThemeToggle: true,
      showBackButton: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo or Title
                  Icon(Icons.directions_run, size: 80, color: colors.terracotta),
                  const SizedBox(height: 16),
                  Text(
                    'Running Club Tunis',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.coffee,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colors.stone,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      labelStyle: TextStyle(color: colors.coffee),
                      prefixIcon: Icon(Icons.person_outline, color: colors.terracotta),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.stone),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.terracotta, width: 2),
                      ),
                    ),
                    validator: (value) => value!.isEmpty ? 'Veuillez entrer votre nom' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _cinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: 3,
                    decoration: InputDecoration(
                      labelText: '3 derniers chiffres CIN',
                      labelStyle: TextStyle(color: colors.coffee),
                      prefixIcon: Icon(Icons.lock_outline, color: colors.terracotta),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.stone),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.terracotta, width: 2),
                      ),
                      counterText: "",
                    ),
                    validator: (value) => 
                        (value!.isEmpty || value.length != 3) 
                        ? '3 chiffres requis' 
                        : null,
                  ),
                  
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.terracotta,
                      foregroundColor: colors.ivory,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 16),

                  // Visitor Button
                  TextButton(
                    onPressed: isLoading ? null : _handleVisitorAccess,
                    style: TextButton.styleFrom(
                      foregroundColor: colors.terracotta,
                    ),
                    child: const Text('Continuer en tant que visiteur'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}