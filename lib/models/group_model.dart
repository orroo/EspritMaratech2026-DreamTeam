class GroupModel {
  final String id;
  final String name;
  final String adminId; // Responsable du groupe

  GroupModel({
    required this.id,
    required this.name,
    required this.adminId,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> data) {
    return GroupModel(
      id: id,
      name: data['name'] ?? '',
      adminId: data['adminId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'adminId': adminId,
    };
  }
}
