import 'package:coffee_mapper_web/models/legacy_data.dart';
import 'package:coffee_mapper_web/services/legacy_service.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/tables/legacy_highlights/legacy_header.dart';
import 'package:coffee_mapper_web/widgets/tables/legacy_highlights/legacy_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LegacyHighlightsSection extends StatefulWidget {
  const LegacyHighlightsSection({super.key});

  @override
  State<LegacyHighlightsSection> createState() =>
      _LegacyHighlightsSectionState();
}

class _LegacyHighlightsSectionState extends State<LegacyHighlightsSection> {
  final LegacyService _legacyService = LegacyService();
  List<LegacyData> filteredData = [];
  List<LegacyData> allData = [];
  String _selectedBlock = '';
  int _selectedYear = 0;
  String _selectedPanchayat = '';
  String _selectedVillage = '';
  List<String> _blocks = [];
  List<int> _years = [];
  List<String> _panchayats = [];
  List<String> _villages = [];
  bool _isDeleting = false;
  late Stream<List<LegacyData>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = _legacyService.getLegacyDataStream();
  }

  List<LegacyData> _getFilteredData() {
    return allData.where((item) {
      final matchesBlock =
          _selectedBlock.isEmpty || item.block == _selectedBlock;
      final matchesYear = _selectedYear == 0 || item.year == _selectedYear;
      final matchesPanchayat =
          _selectedPanchayat.isEmpty || item.panchayat == _selectedPanchayat;
      final matchesVillage =
          _selectedVillage.isEmpty || item.village == _selectedVillage;
      return matchesBlock && matchesYear && matchesPanchayat && matchesVillage;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: ResponsiveUtils.getTableContainerHeight(screenWidth),
      child: StreamBuilder<List<LegacyData>>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          allData = snapshot.data!;
          filteredData = _getFilteredData();
          _blocks = allData.map((item) => item.block).toSet().toList()..sort();
          _years = allData.map((item) => item.year).toSet().toList()..sort();
          _panchayats = allData.map((item) => item.panchayat).toSet().toList()
            ..sort();
          _villages = allData.map((item) => item.village).toSet().toList()
            ..sort();

          return Column(
            children: [
              LegacyHeader(
                blocks: _blocks,
                years: _years,
                panchayats: _panchayats,
                villages: _villages,
                onBlockChanged: (value) {
                  setState(() {
                    _selectedBlock = value;
                  });
                },
                onYearChanged: (value) {
                  setState(() {
                    _selectedYear = value;
                  });
                },
                onPanchayatChanged: (value) {
                  setState(() {
                    _selectedPanchayat = value;
                  });
                },
                onVillageChanged: (value) {
                  setState(() {
                    _selectedVillage = value;
                  });
                },
              ),
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
                  child: StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, authSnapshot) {
                      final isLoggedIn = authSnapshot.hasData;
                      return LegacyTable(
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

  Future<void> _handleDelete(LegacyData data) async {
    if (_isDeleting) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _legacyService.deleteLegacyData(data.id);
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
