import 'package:coffee_mapper_web/models/shade_data.dart';
import 'package:coffee_mapper_web/services/shade_service.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/table_column_definitions.dart';
import 'package:coffee_mapper_web/widgets/tables/shade_highlights/shade_header.dart';
import 'package:coffee_mapper_web/widgets/tables/shade_highlights/shade_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ShadeHighlightsSection extends StatefulWidget {
  const ShadeHighlightsSection({super.key});

  @override
  State<ShadeHighlightsSection> createState() => _ShadeHighlightsSectionState();
}

class _ShadeHighlightsSectionState extends State<ShadeHighlightsSection> {
  final ShadeService _shadeService = ShadeService();
  List<ShadeData> filteredData = [];
  List<ShadeData> allData = [];
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;
  String? selectedRegionCategory;
  // String? selectedStatus;      // Comment out
  // String? selectedSavedBy;     // Comment out

  late Stream<List<ShadeData>> _dataStream;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _dataStream = _shadeService.getShadeDataStream();
  }

  // Get filtered data based on current selections
  List<ShadeData> _getCurrentFilteredData() {
    return allData.where((data) {
      bool matchesDistrict =
          selectedDistrict == null || data.district == selectedDistrict;
      bool matchesBlock = selectedBlock == null || data.block == selectedBlock;
      bool matchesPanchayat =
          selectedPanchayat == null || data.panchayat == selectedPanchayat;
      bool matchesVillage =
          selectedVillage == null || data.village == selectedVillage;
      bool matchesRegionCategory = selectedRegionCategory == null ||
          data.regionCategory == selectedRegionCategory;

      return matchesDistrict &&
          matchesBlock &&
          matchesPanchayat &&
          matchesVillage &&
          matchesRegionCategory;
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

  List<String> _getFilteredRegionCategories() {
    var currentData = _getCurrentFilteredData();
    return _getUniqueValues(currentData, (data) => data.regionCategory);
  }

  void _filterData() {
    setState(() {
      bool hasActiveFilters = selectedDistrict != null ||
          selectedBlock != null ||
          selectedPanchayat != null ||
          selectedVillage != null ||
          selectedRegionCategory != null;

      if (!hasActiveFilters) {
        filteredData = allData;
        return;
      }

      filteredData = _getCurrentFilteredData();
    });
  }

  // Helper methods to get unique values
  List<String> _getUniqueValues(
      List<ShadeData> data, String Function(ShadeData) selector) {
    return data.map(selector).toSet().toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: ResponsiveUtils.getTableContainerHeight(screenWidth),
      child: StreamBuilder<List<ShadeData>>(
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
              ShadeHeader(
                districts: _getFilteredDistricts(),
                blocks: _getFilteredBlocks(),
                panchayats: _getFilteredPanchayats(),
                villages: _getFilteredVillages(),
                regionCategories: _getFilteredRegionCategories(),
                onDistrictChanged: _onDistrictChanged,
                onBlockChanged: _onBlockChanged,
                onPanchayatChanged: _onPanchayatChanged,
                onVillageChanged: _onVillageChanged,
                onRegionCategoryChanged: _onRegionCategoryChanged,
                tableData: filteredData
                    .map((data) => [
                          data.region,
                          data.block,
                          data.panchayat,
                          data.village,
                          data.regionCategory,
                          data.perimeter > 0 ? '${data.perimeter} m' : '',
                          data.area > 0 ? '${data.area} m²' : '',
                          data.plantationYear,
                          data.shadeType,
                          data.averageHeight > 0
                              ? '${data.averageHeight} ft'
                              : '',
                          data.beneficiaries,
                          data.survivalPercentage > 0
                              ? '${data.survivalPercentage} %'
                              : '',
                          data.plotNumber,
                          data.khataNumber,
                          data.agencyName,
                          data.elevation,
                          data.slope,
                          data.maxTemp,
                          data.ph,
                          data.aspect,
                          data.savedBy,
                          data.dateUpdated,
                          data.mediaURLs.isEmpty
                              ? '-'
                              : data.mediaURLs.join('\n\n'),
                          data.boundaryImageURLs.isEmpty
                              ? '-'
                              : data.boundaryImageURLs.join('\n\n'),
                          data.status,
                        ])
                    .toList(),
                tableHeaders:
                    TableColumns.shadeColumns.map((col) => col.label).toList(),
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
                      return ShadeTable(
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
        selectedVillage != null ||
        selectedRegionCategory != null;
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

  void _onRegionCategoryChanged(String value) {
    setState(() {
      selectedRegionCategory = value.isEmpty ? null : value;
      _filterData();
    });
  }

  Future<void> _handleDelete(ShadeData data) async {
    if (_isDeleting) return; // Prevent multiple deletes

    setState(() {
      _isDeleting = true;
    });

    try {
      await _shadeService.deleteShadeData(data.id);
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
