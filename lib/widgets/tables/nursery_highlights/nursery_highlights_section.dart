import 'package:coffee_mapper_web/models/nursery_data.dart';
import 'package:coffee_mapper_web/services/nursery_service.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/widgets/tables/nursery_highlights/nursery_header.dart';
import 'package:coffee_mapper_web/widgets/tables/nursery_highlights/nursery_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//Admin Provider - Deprecated For Now
//import 'package:coffee_mapper_web/providers/admin_provider.dart';

class NurseryHighlightsSection extends StatefulWidget {
  const NurseryHighlightsSection({super.key});

  @override
  State<NurseryHighlightsSection> createState() =>
      _NurseryHighlightsSectionState();
}

class _NurseryHighlightsSectionState extends State<NurseryHighlightsSection> {
  final NurseryService _nurseryService = NurseryService();
  List<NurseryData> filteredData = [];
  List<NurseryData> allData = [];
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;

  late Stream<List<NurseryData>> _dataStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _dataStream = _nurseryService.getNurseryDataStream();
  }

  // Get filtered data based on current selections
  List<NurseryData> _getCurrentFilteredData() {
    return allData.where((data) {
      bool matchesDistrict =
          selectedDistrict == null || data.district == selectedDistrict;
      bool matchesBlock = selectedBlock == null || data.block == selectedBlock;
      bool matchesPanchayat =
          selectedPanchayat == null || data.panchayat == selectedPanchayat;
      bool matchesVillage =
          selectedVillage == null || data.village == selectedVillage;

      return matchesDistrict &&
          matchesBlock &&
          matchesPanchayat &&
          matchesVillage;
    }).toList();
  }

  // Helper methods to get unique values from currently filtered data
  List<String> _getFilteredDistricts() {
    var currentData = _getCurrentFilteredData();
    return _getUniqueValues(currentData, (data) => data.district);
  }

  List<String> _getFilteredBlocks() {
    var currentData = _getCurrentFilteredData();
    return _getUniqueValues(currentData, (data) => data.block);
  }

  List<String> _getFilteredPanchayats() {
    var currentData = _getCurrentFilteredData();
    return _getUniqueValues(currentData, (data) => data.panchayat);
  }

  List<String> _getFilteredVillages() {
    var currentData = _getCurrentFilteredData();
    return _getUniqueValues(currentData, (data) => data.village);
  }

  void _filterData() {
    setState(() {
      bool hasActiveFilters = selectedDistrict != null ||
          selectedBlock != null ||
          selectedPanchayat != null ||
          selectedVillage != null;

      if (!hasActiveFilters) {
        filteredData = allData;
        return;
      }

      filteredData = _getCurrentFilteredData();
    });
  }

  // Helper methods to get unique values
  List<String> _getUniqueValues(
      List<NurseryData> data, String Function(NurseryData) selector) {
    return data.map(selector).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: ResponsiveUtils.getTableContainerHeight(screenWidth),
      child: StreamBuilder<List<NurseryData>>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Update allData and filteredData
          allData = snapshot.data!;
          if (!_hasActiveFilters()) {
            filteredData = allData;
          } else {
            // Reapply filters on data update
            filteredData = _getCurrentFilteredData();
          }

          return Column(
            children: [
              NurseryHeader(
                districts: _getFilteredDistricts(),
                blocks: _getFilteredBlocks(),
                panchayats: _getFilteredPanchayats(),
                villages: _getFilteredVillages(),
                onDistrictChanged: _onDistrictChanged,
                onBlockChanged: _onBlockChanged,
                onPanchayatChanged: _onPanchayatChanged,
                onVillageChanged: _onVillageChanged,
                tableData: filteredData
                    .map((data) => [
                          data.regionName,
                          data.perimeter,
                          data.area,
                          data.coffeeVariety ?? '-',
                          data.seedsQuantity?.toString() ?? '-',
                          data.seedlingsRaised?.toString() ?? '-',
                          data.sowingDate ?? '-',
                          data.transplantingDate ?? '-',
                          data.firstPairLeaves ?? '-',
                          data.secondPairLeaves ?? '-',
                          data.thirdPairLeaves ?? '-',
                          data.fourthPairLeaves ?? '-',
                          data.fifthPairLeaves ?? '-',
                          data.sixthPairLeaves ?? '-',
                          data.savedBy,
                          data.dateUpdated,
                          '-',
                          '-',
                        ])
                    .toList(),
                tableHeaders: TableColumns.nurseryColumns
                    .map((col) => col.label)
                    .toList(),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromARGB(35, 0, 0, 0), // ~0.1 opacity
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Color.fromARGB(35, 0, 0, 0), // ~0.1 opacity
                        blurRadius: 4,
                        spreadRadius: 0,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, authSnapshot) {
                      final isLoggedIn = authSnapshot.hasData;
                      return NurseryTable(
                        data: filteredData,
                        isLoggedIn: isLoggedIn,
                        onDelete: _handleDelete,
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _hasActiveFilters() {
    return selectedDistrict != null ||
        selectedBlock != null ||
        selectedPanchayat != null ||
        selectedVillage != null;
  }

  void _onDistrictChanged(String value) {
    setState(() {
      selectedDistrict = value.isEmpty ? null : value;
      _filterData();
    });
  }

  void _onBlockChanged(String value) {
    setState(() {
      selectedBlock = value.isEmpty ? null : value;
      _filterData();
    });
  }

  void _onPanchayatChanged(String value) {
    setState(() {
      selectedPanchayat = value.isEmpty ? null : value;
      _filterData();
    });
  }

  void _onVillageChanged(String value) {
    setState(() {
      selectedVillage = value.isEmpty ? null : value;
      _filterData();
    });
  }

  Future<void> _handleDelete(NurseryData data) async {
    if (_isDeleting) return; // Prevent multiple deletes

    setState(() {
      _isDeleting = true;
    });

    try {
      await _nurseryService.deleteNurseryData(data.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
}
