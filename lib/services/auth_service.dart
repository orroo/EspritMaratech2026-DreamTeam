import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  // Login with Name and CIN (check if CIN ends with provided digits or match full)
  Future<bool> login(String name, String cin) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Logic for "Visitor" bypass
      if (name.toLowerCase() == 'visitor') {
        _currentUser = UserModel(
            id: 'visitor', name: 'Visitor', cin: '', role: UserRole.visitor);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Mock Login
      // Mock Login (Disabled)

      // Real Firestore query

      // Assuming we query by Name and check CIN locally or query both
      // Collection 'user'
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('user')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (result.docs.isNotEmpty) {
        final userData = result.docs.first.data() as Map<String, dynamic>;
        // Check if CIN matches (full match or last 3 digits rule?)
        // If the database has full CIN "14510026", and user enters "026":
        final String dbCin = userData['cin'] ?? '';

        if (dbCin == cin || dbCin.endsWith(cin)) {
          _currentUser = UserModel.fromMap(result.docs.first.id, userData);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Login error: $e");
      }
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
