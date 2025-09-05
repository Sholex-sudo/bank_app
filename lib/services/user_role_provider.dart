import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleProvider extends ChangeNotifier {
  final users = FirebaseFirestore.instance.collection('users');
  String? role;
  bool loading = false;

  Future<void> loadRole(String uid) async {
    if (loading) return;
    loading = true;
    notifyListeners();
    try {
      final doc = await users.doc(uid).get();
      role = doc.data()?['role'] ?? 'user';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}