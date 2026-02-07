// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('📁 Loading environment variables...');
  try {
    await dotenv.load(fileName: ".env");
    print('✅ Environment variables loaded successfully');
    
    // Debug: Check if web keys are loaded
    print('\n🔍 Checking Firebase configuration:');
    print('Web API Key: ${dotenv.env['web_api_key']?.isNotEmpty ?? false ? "✓ Loaded" : "✗ Missing"}');
    print('Web App ID: ${dotenv.env['web_app_id']?.isNotEmpty ?? false ? "✓ Loaded" : "✗ Missing"}');
    print('Project ID: ${dotenv.env['web_project_id']}');
  } catch (e) {
    print('❌ Failed to load .env file: $e');
    print('Make sure .env file exists in the project root');
    return;
  }
  
  print('\n🔄 Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    print('\n⚠️  Troubleshooting tips:');
    print('1. Check if .env file is in the project root');
    print('2. Make sure .env is listed in pubspec.yaml assets');
    print('3. Verify Firebase API keys are correct');
    print('4. Check Firebase Console if project is active');
    return;
  }
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// ... rest of your MyApp class
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context).theme;
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventService()),
      ],
      child: MaterialApp(
        title: 'Running Club Tunis',
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          textTheme: GoogleFonts.interTextTheme(theme.textTheme),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    if (authService.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}