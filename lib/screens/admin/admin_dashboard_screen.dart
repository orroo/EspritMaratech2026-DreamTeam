import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../events/create_event_screen.dart';
import '../events/event_list_screen.dart';
// import 'manage_users_screen.dart'; // Future implementation

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: ${user.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
              onPressed: authService.logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _DashboardCard(
            icon: Icons.add_moderator,
            label: 'Gérer les Utilisateurs',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content:
                      Text('Fonctionnalité à venir: Gestion des membres')));
            },
            color: Colors.blue,
          ),
          _DashboardCard(
            icon: Icons.event,
            label: 'Liste Événements',
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EventListScreen()));
            },
            color: Colors.orange,
          ),
          if (user.role == UserRole.superAdmin ||
              user.role == UserRole.coach ||
              user.role == UserRole.groupAdmin)
            _DashboardCard(
              icon: Icons.add_circle,
              label: 'Créer Événement',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const CreateEventScreen()));
              },
              color: Colors.green,
            ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
