import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class BeneficiaryHeader extends StatefulWidget {
  final List<String> districts;
  final List<String> blocks;
  final List<String> panchayats;
  final List<String> villages;
  final Function(String) onDistrictChanged;
  final Function(String) onBlockChanged;
  final Function(String) onPanchayatChanged;
  final Function(String) onVillageChanged;
  final bool isAdmin;
  final List<List<dynamic>> tableData;
  final List<String> tableHeaders;

  const BeneficiaryHeader({
    super.key,
    required this.districts,
    required this.blocks,
    required this.panchayats,
    required this.villages,
    required this.onDistrictChanged,
    required this.onBlockChanged,
    required this.onPanchayatChanged,
    required this.onVillageChanged,
    required this.isAdmin,
    required this.tableData,
    required this.tableHeaders,
  });

  @override
  State<BeneficiaryHeader> createState() => _BeneficiaryHeaderState();
}

class _BeneficiaryHeaderState extends State<BeneficiaryHeader> {
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isDesktop = ResponsiveUtils.isDesktop(screenWidth);

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      child: Column(
        children: [
          // Header row with title and filters
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Beneficiary Applicant Details',
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                  color: Theme.of(context).highlightColor,
                ),
              ),
              if (isDesktop) const SizedBox(width: 40),
              if (isDesktop) Expanded(child: _buildFiltersRow(context)),
            ],
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
    final hasActiveFilters = selectedDistrict != null ||
        selectedBlock != null ||
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
                  'District',
                  widget.districts,
                  selectedDistrict,
                  widget.onDistrictChanged,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Block',
                  widget.blocks,
                  selectedBlock,
                  widget.onBlockChanged,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Panchayat',
                  widget.panchayats,
                  selectedPanchayat,
                  widget.onPanchayatChanged,
                ),
                SizedBox(width: isMobile ? 8 : 12),
                _buildFilterDropdown(
                  context,
                  'Village',
                  widget.villages,
                  selectedVillage,
                  widget.onVillageChanged,
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
                          selectedDistrict = null;
                          selectedBlock = null;
                          selectedPanchayat = null;
                          selectedVillage = null;
                        });
                        widget.onDistrictChanged('');
                        widget.onBlockChanged('');
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
        /*
        SizedBox(width: 15),
        // Export button - Hidden
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
                fileName: 'Beneficiary_Data',
                sheetName: 'Beneficiary',
              );
            },
          ),
        ),
        */
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
                          if (label == 'District') {
                            selectedDistrict = null;
                            selectedBlock = null;
                            selectedPanchayat = null;
                            selectedVillage = null;
                          }
                          if (label == 'Block') {
                            selectedBlock = null;
                            selectedPanchayat = null;
                            selectedVillage = null;
                          }
                          if (label == 'Panchayat') {
                            selectedPanchayat = null;
                            selectedVillage = null;
                          }
                          if (label == 'Village') selectedVillage = null;
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
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Gilroy-Medium',
                    fontSize: fontSize,
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  if (label == 'District') selectedDistrict = value;
                  if (label == 'Block') selectedBlock = value;
                  if (label == 'Panchayat') selectedPanchayat = value;
                  if (label == 'Village') selectedVillage = value;
                });
                onChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }
}
