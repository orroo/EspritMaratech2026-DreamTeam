import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/user_model.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'services/user_service.dart';
import 'services/program_service.dart';
import 'services/group_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/notification_service.dart';
import 'services/assistant_service.dart';
import 'utils/constants.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize Notification Service (non-blocking)
    final notificationService = NotificationService();
    notificationService.initialize().catchError((e) {
      if (kDebugMode) print("Notification init error: $e");
    });

    runApp(MyApp(notificationService: notificationService));
  } catch (e) {
    if (kDebugMode) {
      print("CRITICAL INITIALIZATION ERROR: $e");
    }
    // Fallback run to at least show something or allow debug
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Erreur d'initialisation: $e")),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  const MyApp({super.key, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => ProgramService()),
        ChangeNotifierProvider(create: (_) => GroupService()),
        ChangeNotifierProvider(
            create: (context) => AssistantService(navigatorKey)),
        ChangeNotifierProvider.value(value: notificationService),
      ],
      child: MaterialApp(
        title: 'Running Club Tunis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.interTextTheme(),
        ),
        navigatorKey: navigatorKey,
        home: const LoginAuthWrapper(),
      ),
    );
  }
}

class LoginAuthWrapper extends StatelessWidget {
  const LoginAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<UserModel?>(
      stream: authService.authStateStream(),
      builder: (context, snapshot) {
        // If the stream hasn't yielded yet, show the current state
        final user = snapshot.data ?? authService.currentUser;

        if (user != null) {
          return const HomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
