import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/group_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/group_service.dart';
import '../../utils/constants.dart';

class ManageGroupScreen extends StatefulWidget {
  const ManageGroupScreen({super.key});

  @override
  State<ManageGroupScreen> createState() => _ManageGroupScreenState();
}

class _ManageGroupScreenState extends State<ManageGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  GroupModel? _selectedGroup;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final groupService = Provider.of<GroupService>(context);
    final currentUser = authService.currentUser;

    if (currentUser?.role != UserRole.groupAdmin &&
        currentUser?.role != UserRole.adminPrincipal) {
      return const Scaffold(body: Center(child: Text('Accès non autorisé')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(currentUser?.role == UserRole.adminPrincipal
            ? 'Gérer les Groupes'
            : 'Gérer mon Groupe'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (currentUser?.role == UserRole.adminPrincipal)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateGroupDialog(context, groupService),
            ),
        ],
      ),
      body: currentUser?.role == UserRole.adminPrincipal
          ? _buildSuperAdminView(groupService)
          : FutureBuilder<GroupModel?>(
              future: _findUserGroup(groupService, currentUser!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final group = snapshot.data;

                if (group == null) {
                  return _buildCreateGroupView(groupService, currentUser.id);
                }

                return _buildManageGroupView(groupService, group);
              },
            ),
    );
  }

  Future<GroupModel?> _findUserGroup(
      GroupService service, UserModel user) async {
    // 1. Check if user has a group assigned in their profile
    if (user.group != null && user.group!.isNotEmpty) {
      final group = await service.getGroupById(user.group!);
      if (group != null) return group;
    }

    // 2. Fallback: Search for a group where they are the adminId
    return await service.getGroupByAdmin(user.id);
  }

  void _showCreateGroupDialog(BuildContext context, GroupService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un nouveau groupe'),
        content: TextField(
          controller: _groupNameController,
          decoration: const InputDecoration(labelText: 'Nom du Groupe'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              if (_groupNameController.text.isNotEmpty) {
                final nav = Navigator.of(context);
                await service.createGroup(_groupNameController.text, 'system');
                _groupNameController.clear();
                nav.pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Groupe créé avec succès')),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuperAdminView(GroupService groupService) {
    return StreamBuilder<List<GroupModel>>(
      stream: groupService.getAllGroups(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final groups = snapshot.data ?? [];

        if (groups.isEmpty) {
          return const Center(child: Text('Aucun groupe existant.'));
        }

        if (_selectedGroup == null) {
          return _buildGroupPicker(groups);
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _selectedGroup = null),
                  ),
                  Text('Gestion : ${_selectedGroup!.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
                child: _buildManageGroupView(groupService, _selectedGroup!)),
          ],
        );
      },
    );
  }

  Widget _buildGroupPicker(List<GroupModel> groups) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.group, color: AppColors.primary),
            title: Text(group.name),
            subtitle: Text('ID Admin: ${group.adminId}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedGroup = group),
          ),
        );
      },
    );
  }

  Widget _buildCreateGroupView(GroupService service, String adminId) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.group_add, size: 80, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            'Vous n\'avez pas encore de groupe.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Créez-en un pour commencer à ajouter des membres.'),
          const SizedBox(height: 24),
          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Nom du Groupe',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                if (_groupNameController.text.isNotEmpty) {
                  final groupService =
                      Provider.of<GroupService>(context, listen: false);
                  final authService =
                      Provider.of<AuthService>(context, listen: false);

                  await groupService.createGroup(
                      _groupNameController.text, adminId);
                  await authService.refreshUser();

                  if (mounted) {
                    setState(() {}); // Refresh to show manage view
                  }
                }
              },
              child: const Text('Créer le Groupe'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageGroupView(GroupService service, GroupModel group) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary.withValues(alpha: 0.1),
          child: Row(
            children: [
              const Icon(Icons.group, color: AppColors.primary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Responsable de Groupe',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        _buildSearchBar(service, group.id),
        if (_searchResults.isNotEmpty || _isSearching)
          Expanded(
            child: _buildSearchResults(service, group.id),
          )
        else
          Expanded(
            child: _buildMembersList(service, group.id),
          ),
      ],
    );
  }

  Widget _buildSearchBar(GroupService service, String groupId) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Inviter un membre (Nom ou CIN)...',
          prefixIcon: const Icon(Icons.person_add),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchResults = [];
                      _isSearching = false;
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onChanged: (value) async {
          if (value.length > 2) {
            setState(() => _isSearching = true);
            final results = await service.searchUsers(value);
            setState(() {
              _searchResults = results;
              _isSearching = false;
            });
          } else {
            setState(() {
              _searchResults = [];
              _isSearching = false;
            });
          }
        },
      ),
    );
  }

  Widget _buildSearchResults(GroupService service, String groupId) {
    if (_isSearching) return const Center(child: CircularProgressIndicator());
    if (_searchResults.isEmpty) {
      return const Center(child: Text('Aucun utilisateur trouvé.'));
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final isInGroup = user.group == groupId;

        return ListTile(
          title: Text(user.name),
          subtitle: Text('CIN: ${user.cin}'),
          trailing: isInGroup
              ? const Chip(
                  label: Text('Déjà membre'),
                  backgroundColor: Colors.greenAccent)
              : ElevatedButton(
                  onPressed: () async {
                    final scaffoldContext = context;
                    await service.addUserToGroup(user.id, groupId);
                    if (!scaffoldContext.mounted) return;
                    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
                      SnackBar(content: Text('${user.name} ajouté au groupe')),
                    );
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                  child: const Text('Inviter'),
                ),
        );
      },
    );
  }

  Widget _buildMembersList(GroupService service, String groupId) {
    return StreamBuilder<List<UserModel>>(
      stream: service.getGroupMembers(groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final members = snapshot.data ?? [];
        if (members.isEmpty) {
          return const Center(child: Text('Aucun membre dans ce groupe.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Membres (${members.length})',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(member.name),
                    subtitle: Text('CIN: ${member.cin}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.red),
                      onPressed: () => _confirmRemove(context, service, member),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmRemove(
      BuildContext context, GroupService service, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer du groupe?'),
        content:
            Text('Voulez-vous vraiment retirer ${user.name} de ce groupe?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Non')),
          TextButton(
            onPressed: () async {
              final navigatorContext = context;
              await service.removeUserFromGroup(user.id);
              if (navigatorContext.mounted) Navigator.pop(navigatorContext);
            },
            child: const Text('Oui', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
