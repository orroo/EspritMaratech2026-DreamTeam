import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../admin/admin_dashboard_screen.dart';
import '../events/event_list_screen.dart';
import '../info/club_history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      return const Center(child: Text("Erreur: Utilisateur non connecté"));
    }

    if (user.role == UserRole.visitor) {
      return const ClubHistoryScreen(isVisitor: true);
    }

    // For Principal Admin (User Management), Group Admin (Event Management), and ADMIN_COACH
    if (user.role == UserRole.adminPrincipal ||
        user.role == UserRole.groupAdmin ||
        user.role == UserRole.adminCoach) {
      return const AdminDashboardScreen();
    }

    // For Members and Coaches
    return const EventListScreen(); // land on Event List
  }
}
