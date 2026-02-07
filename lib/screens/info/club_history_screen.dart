import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ClubHistoryScreen extends StatelessWidget {
  final bool isVisitor;

  const ClubHistoryScreen({super.key, this.isVisitor = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Club History'),
        actions: [
          if (isVisitor)
            IconButton(
              icon: const Icon(Icons.login),
              onPressed: () {
                Provider.of<AuthService>(context, listen: false).logout();
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Historique du Running Club Tunis',
              'Fondé en 20XX, le Running Club Tunis est...',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Nos Valeurs',
              '• Passion\n• Solidarité\n• Dépassement de soi',
            ),
            const SizedBox(height: 16),
            _buildSection(
              context,
              'Notre Charte',
              'Tout membre s\'engage à respecter les règles de sécurité...',
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.secondary.withValues(alpha: 0.1),
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

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}
