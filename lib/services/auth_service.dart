import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  Stream<UserModel?> authStateStream() async* {
    yield _currentUser;
    // This is a simple mock stream that yields when listeners might change
    // In a real app with Firebase Auth, you'd use FirebaseAuth.instance.authStateChanges()
  }

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

  // Register with Name and CIN
  Future<bool> register(String name, String cin) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if user already exists
      final existing = await FirebaseFirestore.instance
          .collection('user')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
        return false; // User already exists
      }

      final newUser = {
        'name': name,
        'cin': cin,
        'role': 'member', // Default role
        'group': null,
        'lastReadTimestamp': FieldValue.serverTimestamp(),
      };

      final docRef =
          await FirebaseFirestore.instance.collection('user').add(newUser);

      // Auto-login after registration
      _currentUser = UserModel(
        id: docRef.id,
        name: name,
        cin: cin,
        role: UserRole.member,
        lastReadTimestamp: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Registration error: $e");
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

  Future<void> updateLastReadTimestamp() async {
    if (_currentUser == null) return;

    final now = DateTime.now();
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(_currentUser!.id)
          .update({'lastReadTimestamp': Timestamp.fromDate(now)});

      _currentUser = UserModel(
        id: _currentUser!.id,
        name: _currentUser!.name,
        cin: _currentUser!.cin,
        role: _currentUser!.role,
        group: _currentUser!.group,
        lastReadTimestamp: now,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error updating lastReadTimestamp: $e");
      }
    }
  }

  Future<void> refreshUser() async {
    if (_currentUser == null || _currentUser!.id == 'visitor') return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(_currentUser!.id)
          .get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.id, doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error refreshing user: $e");
      }
    }
  }
}
