import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/models/farmer_form_data.dart';
import 'package:coffee_mapper_web/services/beneficiary_service.dart';
import 'package:coffee_mapper_web/widgets/tables/beneficiary_highlights/beneficiary_table.dart';
import 'package:coffee_mapper_web/widgets/tables/beneficiary_highlights/beneficiary_header.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';

class BeneficiaryHighlightSection extends StatefulWidget {
  final bool isLoggedIn;

  const BeneficiaryHighlightSection({
    super.key,
    required this.isLoggedIn,
  });

  @override
  State<BeneficiaryHighlightSection> createState() =>
      _BeneficiaryHighlightSectionState();
}

class _BeneficiaryHighlightSectionState
    extends State<BeneficiaryHighlightSection> {
  final BeneficiaryService _beneficiaryService = BeneficiaryService();
  List<FarmerFormData> filteredData = [];
  List<FarmerFormData> allData = [];
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;
  bool _isDeleting = false;

  late Stream<List<FarmerFormData>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = _beneficiaryService.getBeneficiaryDataStream();
  }

  // Get filtered data based on current selections
  List<FarmerFormData> _getCurrentFilteredData() {
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
      List<FarmerFormData> data, String? Function(FarmerFormData) selector) {
    return data
        .map(selector)
        .where((value) => value != null)
        .map((e) => e!)
        .toSet()
        .toList()
      ..sort();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.isMobile(screenWidth) ? 12 : 18),
      child: SizedBox(
        height: ResponsiveUtils.getTableContainerHeight(screenWidth),
        child: StreamBuilder<List<FarmerFormData>>(
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BeneficiaryHeader(
                  districts: _getFilteredDistricts(),
                  blocks: _getFilteredBlocks(),
                  panchayats: _getFilteredPanchayats(),
                  villages: _getFilteredVillages(),
                  onDistrictChanged: _onDistrictChanged,
                  onBlockChanged: _onBlockChanged,
                  onPanchayatChanged: _onPanchayatChanged,
                  onVillageChanged: _onVillageChanged,
                  isAdmin: widget.isLoggedIn,
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
                          color: Color.fromARGB(35, 0, 0, 0),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                        BoxShadow(
                          color: Color.fromARGB(35, 0, 0, 0),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: BeneficiaryTable(
                      beneficiaryData: filteredData,
                      isLoggedIn: widget.isLoggedIn,
                      onDelete: _handleDelete,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

  Future<void> _handleDelete(FarmerFormData data) async {
    if (_isDeleting) return; // Prevent multiple deletes

    setState(() {
      _isDeleting = true;
    });

    try {
      await _beneficiaryService.deleteBeneficiary(data);
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
