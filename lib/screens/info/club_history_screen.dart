import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/base_screen.dart';
import '../../providers/theme_provider.dart'; // Add this import

class ClubHistoryScreen extends StatelessWidget {
  final bool isVisitor;

  const ClubHistoryScreen({super.key, this.isVisitor = false});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colors = themeProvider.colors;

    return BaseScreen(
      title: 'Club History',
      showThemeToggle: true,
      showBackButton: !isVisitor,
      actions: isVisitor
          ? [
              IconButton(
                icon: const Icon(Icons.login),
                onPressed: () {
                  Provider.of<AuthService>(context, listen: false).logout();
                },
              )
            ]
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Historique du Running Club Tunis',
              'Fondé en 20XX, le Running Club Tunis est...',
              colors,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Nos Valeurs',
              '• Passion\n• Solidarité\n• Dépassement de soi',
              colors,
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Notre Charte',
              'Tout membre s\'engage à respecter les règles de sécurité...',
              colors,
            ),
            const SizedBox(height: 16),
            Card(
              color: colors.terracotta.withOpacity(0.1), // Use theme color
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Rejoignez-nous !',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text('Contactez le comité pour devenir membre.'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, AccessibleColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colors.terracotta, // Use theme color
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colors.coffee, // Use theme color
          ),
        ),
      ],
    );
  }
}