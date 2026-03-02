import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminData {
  final bool isAdmin;
  final String? name;

  AdminData({required this.isAdmin, this.name});
}

class AdminNotifier extends StateNotifier<AdminData?> {
  AdminNotifier() : super(null);

  Future<void> checkAdminStatus(String? email) async {
    if (email == null) {
      state = AdminData(isAdmin: false, name: null);
      return;
    }

    final userDoc =
        await FirebaseFirestore.instance.collection('users').where('email', isEqualTo: email).get();

    if (userDoc.docs.isEmpty) {
      state = AdminData(isAdmin: false, name: null);
      return;
    }

    final userData = userDoc.docs.first.data();
    final role = userData['role'] as String?;
    final isAdmin = role == 'ADMIN' || role == 'DEV';

    state = AdminData(
      isAdmin: isAdmin,
      name: userData['name'] as String?,
    );
  }

  void clearAdminData() {
    state = null;
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminData?>((ref) {
  return AdminNotifier();
});
