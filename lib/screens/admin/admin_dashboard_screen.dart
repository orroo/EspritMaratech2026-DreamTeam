import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/constants.dart';
import '../events/create_event_screen.dart';
import '../events/event_list_screen.dart';
import 'manage_users_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../services/notification_service.dart';
import 'manage_group_screen.dart';
import '../info/programs_list_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final notificationService = Provider.of<NotificationService>(context);

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Erreur')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord Admin'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<int>(
            stream: notificationService.getUnreadCount(
                user.group ?? 'All', user.lastReadTimestamp),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          if (user.role == UserRole.adminPrincipal)
            _DashboardCard(
              icon: Icons.add_moderator,
              label: 'Gérer les Utilisateurs',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageUsersScreen()));
              },
              color: Colors.blue,
            ),
          if (user.role == UserRole.groupAdmin ||
              user.role == UserRole.adminPrincipal)
            _DashboardCard(
              icon: Icons.group_work,
              label: user.role == UserRole.adminPrincipal
                  ? 'Gérer les Groupes'
                  : 'Gérer mon Groupe',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ManageGroupScreen()));
              },
              color: Colors.deepPurple,
            ),
          if (user.role == UserRole.groupAdmin ||
              user.role == UserRole.adminPrincipal ||
              user.role == UserRole.adminCoach) ...[
            _DashboardCard(
              icon: Icons.event,
              label: 'Liste Événements',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EventListScreen()));
              },
              color: Colors.orange,
            ),
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
          if (user.role == UserRole.adminCoach ||
              user.role == UserRole.adminPrincipal) ...[
            _DashboardCard(
              icon: Icons.assignment,
              label: 'Liste Programmes',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgramsListScreen()));
              },
              color: Colors.teal,
            ),
            _DashboardCard(
              icon: Icons.add_task,
              label: 'Nouveau Programme',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const ProgramsListScreen(showAddDialog: true)));
              },
              color: Colors.blue,
            ),
          ] else
            _DashboardCard(
              icon: Icons.assignment,
              label: 'Programmes',
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProgramsListScreen()));
              },
              color: Colors.teal,
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
