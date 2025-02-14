import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/address_data.dart';

// Provider for fetching address data from Firestore
final addressDataProvider = FutureProvider<AddressData>((ref) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('appData')
      .doc('regionData')
      .get();

  if (!snapshot.exists) {
    throw Exception('Address data not found');
  }

  return AddressData.fromFirestore(snapshot.data()!);
});

// State providers for selected values
final selectedDistrictProvider = StateProvider<String?>((ref) => null);
final selectedBlockProvider = StateProvider<String?>((ref) => null);
final selectedPanchayatProvider = StateProvider<String?>((ref) => null);
final selectedVillageProvider = StateProvider<String?>((ref) => null);

// Derived providers for available options based on selections
final availableBlocksProvider = Provider<List<String>>((ref) {
  final addressDataAsync = ref.watch(addressDataProvider);
  final selectedDistrict = ref.watch(selectedDistrictProvider);

  return addressDataAsync.when(
    data: (data) {
      if (selectedDistrict == null) return [];
      return data.getBlocksForDistrict(selectedDistrict);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final availablePanchayatsProvider = Provider<List<String>>((ref) {
  final addressDataAsync = ref.watch(addressDataProvider);
  final selectedBlock = ref.watch(selectedBlockProvider);

  return addressDataAsync.when(
    data: (data) {
      if (selectedBlock == null) return [];
      return data.getPanchayatsForBlock(selectedBlock);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

final availableVillagesProvider = Provider<List<String>>((ref) {
  final addressDataAsync = ref.watch(addressDataProvider);
  final selectedPanchayat = ref.watch(selectedPanchayatProvider);

  return addressDataAsync.when(
    data: (data) {
      if (selectedPanchayat == null) return [];
      return data.getVillagesForPanchayat(selectedPanchayat);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});
