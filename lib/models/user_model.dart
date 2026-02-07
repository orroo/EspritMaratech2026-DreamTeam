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
}
