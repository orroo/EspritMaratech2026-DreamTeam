import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
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
                  Icon(Icons.directions_run, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Running Club Tunis',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bienvenue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Inputs
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Se connecter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),

                  const SizedBox(height: 16),

                  // Visitor Button
                  TextButton(
                    onPressed: isLoading ? null : _handleVisitorAccess,
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
