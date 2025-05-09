import 'package:coffee_mapper_web/utils/excel_export_utils.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class LegacyHeader extends StatefulWidget {
  final List<String> blocks;
  final List<String> years;
  final List<String> panchayats;
  final List<String> villages;
  final Function(String) onBlockChanged;
  final Function(String) onYearChanged;
  final Function(String) onPanchayatChanged;
  final Function(String) onVillageChanged;
  final List<List<dynamic>> tableData;
  final List<String> tableHeaders;

  const LegacyHeader({
    super.key,
    required this.blocks,
    required this.years,
    required this.panchayats,
    required this.villages,
    required this.onBlockChanged,
    required this.onYearChanged,
    required this.onPanchayatChanged,
    required this.onVillageChanged,
    required this.tableData,
    required this.tableHeaders,
  });

  @override
  State<LegacyHeader> createState() => _LegacyHeaderState();
}

class _LegacyHeaderState extends State<LegacyHeader> {
  String? selectedBlock;
  String? selectedYear;
  String? selectedPanchayat;
  String? selectedVillage;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isDesktop = ResponsiveUtils.isDesktop(screenWidth);

    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 15),
      child: Column(
        children: [
          // Header row with title and filters
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Beneficiery Allocation Data',
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              if (isDesktop) const SizedBox(width: 30),
              if (isDesktop) Expanded(child: _buildFiltersRow(context)),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(child: _buildFiltersRow(context)),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final hasActiveFilters = selectedBlock != null ||
        selectedYear != null ||
        selectedPanchayat != null ||
        selectedVillage != null;

    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterDropdown(
                  context,
                  'Block',
                  widget.blocks.map((e) => e.toString()).toList(),
                  selectedBlock,
                  (value) {
                    setState(() {
                      selectedBlock = value.isEmpty ? null : value;
                    });
                    widget.onBlockChanged(value);
                  },
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Panchayat',
                  widget.panchayats.map((e) => e.toString()).toList(),
                  selectedPanchayat,
                  (value) {
                    setState(() {
                      selectedPanchayat = value.isEmpty ? null : value;
                    });
                    widget.onPanchayatChanged(value);
                  },
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Village',
                  widget.villages.map((e) => e.toString()).toList(),
                  selectedVillage,
                  (value) {
                    setState(() {
                      selectedVillage = value.isEmpty ? null : value;
                    });
                    widget.onVillageChanged(value);
                  },
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Year',
                  widget.years.map((e) => e.toString()).toList(),
                  selectedYear,
                  (value) {
                    setState(() {
                      selectedYear = value.isEmpty ? null : value;
                    });
                    widget.onYearChanged(value);
                  },
                ),
                if (hasActiveFilters) ...[
                  SizedBox(width: isMobile ? 8 : 12),
                  Tooltip(
                    message: 'Clear All',
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.error,
                        size: isMobile ? 18 : 20,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedBlock = null;
                          selectedYear = null;
                          selectedPanchayat = null;
                          selectedVillage = null;
                        });
                        widget.onBlockChanged('');
                        widget.onYearChanged('');
                        widget.onPanchayatChanged('');
                        widget.onVillageChanged('');
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SizedBox(width: 15),
        // Export button
        Tooltip(
          message: 'Download Table Data',
          child: IconButton(
            icon: Icon(
              Icons.downloading_outlined,
              color: Theme.of(context).colorScheme.secondary,
              size: isMobile ? 22 : 25,
            ),
            onPressed: () {
              ExcelExportUtils.downloadExcel(
                context: context,
                headers: widget.tableHeaders,
                data: widget.tableData,
                fileName: 'Legacy_Data',
                sheetName: 'Legacy',
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    BuildContext context,
    String label,
    List<String> items,
    String? selectedValue,
    Function(String) onChanged,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    final horizontalPadding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final verticalPadding = isMobile ? 4.0 : (isTablet ? 5.0 : 6.0);
    final fontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final containerHeight = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);

    // Get the primary color and create a darker variant for selected state
    final primaryColor = Theme.of(context).colorScheme.primary;
    final selectedColor = HSLColor.fromColor(primaryColor)
        .withLightness(
            (HSLColor.fromColor(primaryColor).lightness * 0.8).clamp(0.0, 1.0))
        .toColor();

    return Container(
      height: containerHeight,
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: selectedValue != null ? selectedColor : primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DropdownButton<String>(
            isDense: false,
            value: selectedValue,
            hint: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: fontSize,
              ),
            ),
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Gilroy-Medium',
              fontSize: fontSize,
            ),
            dropdownColor: Theme.of(context).colorScheme.primary,
            underline: const SizedBox(),
            icon: Padding(
              padding: EdgeInsets.only(left: horizontalPadding),
              child: selectedValue == null
                  ? Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                      size: fontSize * 1.5,
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          if (label == 'Block') {
                            selectedBlock = null;
                          }
                          if (label == 'Panchayat') {
                            selectedPanchayat = null;
                          }
                          if (label == 'Village') {
                            selectedVillage = null;
                          }
                          if (label == 'Year') {
                            selectedYear = null;
                          }
                        });
                        onChanged('');
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.white,
                        size: fontSize * 1.2,
                      ),
                    ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('All'),
              ),
              ...items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }),
            ],
            onChanged: (String? value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
