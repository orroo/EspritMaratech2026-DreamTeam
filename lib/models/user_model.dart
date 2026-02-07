enum UserRole {
  superAdmin, // Comité directrice
  coach, // Admin Coach
  groupAdmin, // Responsable de groupe
  member, // Adhérent
  visitor // Visiteurn
}

class UserModel {
  final String id;
  final String name;
  final String cin; // Full CIN
  final UserRole role;
  final String? group; // Changed from groupName

  UserModel({
    required this.id,
    required this.name,
    required this.cin,
    required this.role,
    this.group,
  });

  // Factory to create from Firestore document
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      cin: data['cin'] ?? '',
      role: _stringToRole(data['role']),
      group: data['group'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cin': cin,
      'role': _roleToString(role),
      'group': group,
    };
  }

  static UserRole _stringToRole(String? roleStr) {
    switch (roleStr) {
      case 'ADMIN_PRINCIPAL':
        return UserRole.superAdmin;
      case 'ADMIN_COACH':
        return UserRole.coach;
      case 'ADMIN_GROUPE':
        return UserRole.groupAdmin;
      case 'ADHERENT':
        return UserRole.member;
      default:
        return UserRole.visitor;
    }
  }

  static String _roleToString(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'ADMIN_PRINCIPAL';
      case UserRole.coach:
        return 'ADMIN_COACH';
      case UserRole.groupAdmin:
        return 'ADMIN_GROUPE';
      case UserRole.member:
        return 'ADHERENT';
      case UserRole.visitor:
        return 'VISITEUR';
    }
  }

  // Public version for external use
  static String roleToString(UserRole role) => _roleToString(role);

  // Get display name for role (French labels)
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Comité Directrice';
      case UserRole.coach:
        return 'Admin Coach';
      case UserRole.groupAdmin:
        return 'Responsable de Groupe';
      case UserRole.member:
        return 'Adhérent';
      case UserRole.visitor:
        return 'Visiteur';
    }
  }

  // Get role description
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 'Accès complet à toutes les fonctionnalités';
      case UserRole.coach:
        return 'Peut gérer les événements et les membres';
      case UserRole.groupAdmin:
        return 'Peut gérer son groupe';
      case UserRole.member:
        return 'Membre actif du club';
      case UserRole.visitor:
        return 'Accès limité en tant que visiteur';
    }
  }

  // Get color for role
  static int getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.superAdmin:
        return 0xFFD32F2F; // Red
      case UserRole.coach:
        return 0xFFF57C00; // Orange
      case UserRole.groupAdmin:
        return 0xFF1976D2; // Blue
      case UserRole.member:
        return 0xFF388E3C; // Green
      case UserRole.visitor:
        return 0xFF757575; // Grey
    }
  }

  // Get all available roles for selection
  static List<UserRole> getAllRoles() {
    return [
      UserRole.superAdmin,
      UserRole.coach,
      UserRole.groupAdmin,
      UserRole.member,
      UserRole.visitor,
    ];
  }
}
