import 'package:flutter/foundation.dart';

@immutable
class AddressData {
  final List<String> districts;
  final Map<String, List<String>> blocks;       // key: block name, value: list of panchayats
  final Map<String, List<String>> panchayats;   // key: panchayat name, value: list of villages

  const AddressData({
    required this.districts,
    required this.blocks,
    required this.panchayats,
  });

  factory AddressData.fromFirestore(Map<String, dynamic> data) {
    // Extract districts (simple array)
    final districts = List<String>.from(data['districts'] ?? [])..sort();

    // Extract blocks mapping (key: block name, value: list of panchayats)
    final blocksData = data['blocks'] as Map<String, dynamic>? ?? {};
    final blocks = blocksData.map((blockName, panchayatList) => 
      MapEntry(blockName, List<String>.from(panchayatList as List))
    );

    // Extract panchayats mapping (key: panchayat name, value: list of villages)
    final panchayatsData = data['panchayats'] as Map<String, dynamic>? ?? {};
    final panchayats = panchayatsData.map((panchayatName, villageList) => 
      MapEntry(panchayatName, List<String>.from(villageList as List))
    );

    return AddressData(
      districts: districts,
      blocks: blocks,
      panchayats: panchayats,
    );
  }

  // Get available blocks for a district
  List<String> getBlocksForDistrict(String district) {
    return blocks.keys.toList()..sort();
  }

  // Get available panchayats for a block
  List<String> getPanchayatsForBlock(String block) {
    return blocks[block]?.toList() ?? [];
  }

  // Get available villages for a panchayat
  List<String> getVillagesForPanchayat(String panchayat) {
    return panchayats[panchayat]?.toList() ?? [];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressData &&
          runtimeType == other.runtimeType &&
          listEquals(districts, other.districts) &&
          mapEquals(blocks, other.blocks) &&
          mapEquals(panchayats, other.panchayats);

  @override
  int get hashCode =>
      districts.hashCode ^
      blocks.hashCode ^
      panchayats.hashCode;
} 