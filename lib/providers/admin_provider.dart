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

    final adminDoc = await FirebaseFirestore.instance
        .collection('admins')
        .doc(email)
        .get();

    state = AdminData(
      isAdmin: adminDoc.exists,
      name: adminDoc.data()?['name'] as String?,
    );
  }

  void clearAdminData() {
    state = null;
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminData?>((ref) {
  return AdminNotifier();
}); 