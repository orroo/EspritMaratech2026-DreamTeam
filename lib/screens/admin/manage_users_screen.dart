import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../widgets/assistant_fab.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final authService = Provider.of<AuthService>(context);
    final currentUser = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer les Utilisateurs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom ou CIN...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: userService.getAllUsers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text('Erreur: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Aucun utilisateur trouvé'),
                  );
                }

                // Filter users based on search query
                final users = snapshot.data!.where((user) {
                  if (_searchQuery.isEmpty) return true;
                  return user.name.toLowerCase().contains(_searchQuery) ||
                      user.cin.toLowerCase().contains(_searchQuery);
                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text('Aucun résultat trouvé'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final canEdit =
                        currentUser?.role == UserRole.adminPrincipal;
                    return _UserCard(
                      user: user,
                      canEdit: canEdit,
                      onRoleChanged: canEdit
                          ? () {
                              _showRoleChangeDialog(context, user, userService);
                            }
                          : null,
                      onDelete: canEdit
                          ? () {
                              _confirmDeleteUser(context, user, userService);
                            }
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const AssistantFAB(),
    );
  }

  void _confirmDeleteUser(
      BuildContext context, UserModel user, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'utilisateur'),
        content: Text(
            'Êtes-vous sûr de vouloir supprimer ${user.name} ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context);
              final success = await userService.deleteUser(user.id);
              if (!nav.mounted) return;
              nav.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Utilisateur supprimé'
                      : 'Erreur lors de la suppression'),
                  backgroundColor: success ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child:
                const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(
      BuildContext context, UserModel user, UserService userService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Changer le rôle de ${user.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rôle actuel: ${UserModel.getRoleDisplayName(user.role)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Sélectionner un nouveau rôle:'),
            const SizedBox(height: 8),
            ...UserModel.getAllRoles().map((role) {
              return RadioListTile<UserRole>(
                title: Text(UserModel.getRoleDisplayName(role)),
                subtitle: Text(
                  UserModel.getRoleDescription(role),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                value: role,
                groupValue: user.role,
                onChanged: (UserRole? newRole) {
                  if (newRole != null && newRole != user.role) {
                    Navigator.pop(context);
                    _confirmRoleChange(context, user, newRole, userService);
                  }
                },
                activeColor: Color(UserModel.getRoleColor(role)),
                controlAffinity: ListTileControlAffinity.trailing,
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _confirmRoleChange(BuildContext context, UserModel user,
      UserRole newRole, UserService userService) {
    showDialog(
      context: context,
      builder: (dialogContext) => _RoleChangeConfirmationDialog(
        user: user,
        newRole: newRole,
        userService: userService,
      ),
    );
  }
}

// Stateful dialog to manage loading state internally
class _RoleChangeConfirmationDialog extends StatefulWidget {
  final UserModel user;
  final UserRole newRole;
  final UserService userService;

  const _RoleChangeConfirmationDialog({
    required this.user,
    required this.newRole,
    required this.userService,
  });

  @override
  State<_RoleChangeConfirmationDialog> createState() =>
      _RoleChangeConfirmationDialogState();
}

class _RoleChangeConfirmationDialogState
    extends State<_RoleChangeConfirmationDialog> {
  bool _isLoading = false;

  Future<void> _handleConfirm() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await widget.userService
          .updateUserRole(widget.user.id, widget.newRole);

      if (mounted) {
        // Close dialog
        Navigator.of(context).pop();

        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Rôle mis à jour avec succès'
                  : 'Erreur lors de la mise à jour du rôle',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: AlertDialog(
        title: const Text('Confirmer le changement'),
        content: _isLoading
            ? const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Mise à jour en cours...'),
                ],
              )
            : Text(
                'Êtes-vous sûr de vouloir changer le rôle de ${widget.user.name} de "${UserModel.getRoleDisplayName(widget.user.role)}" à "${UserModel.getRoleDisplayName(widget.newRole)}"?',
              ),
        actions: _isLoading
            ? []
            : [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: _handleConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text('Confirmer'),
                ),
              ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onRoleChanged;
  final VoidCallback? onDelete;
  final bool canEdit;

  const _UserCard({
    required this.user,
    this.onRoleChanged,
    this.onDelete,
    required this.canEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: onRoleChanged,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // User avatar with role color
              CircleAvatar(
                radius: 28,
                backgroundColor: Color(UserModel.getRoleColor(user.role)),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CIN: ${_maskCIN(user.cin)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(UserModel.getRoleColor(user.role))
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(UserModel.getRoleColor(user.role)),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        UserModel.getRoleDisplayName(user.role),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(UserModel.getRoleColor(user.role)),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (user.group != null && user.group!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Groupe: ${user.group}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              if (canEdit)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onDelete != null)
                      IconButton(
                        icon:
                            const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: onDelete,
                      ),
                    const Icon(
                      Icons.edit,
                      color: Colors.grey,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskCIN(String cin) {
    if (cin.length <= 3) return cin;
    return '***${cin.substring(cin.length - 3)}';
  }
}
