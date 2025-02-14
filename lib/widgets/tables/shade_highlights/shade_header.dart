import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';

class ShadeHeader extends StatefulWidget {
  final List<String> districts;
  final List<String> blocks;
  final List<String> panchayats;
  final List<String> villages;
  final List<String> regionCategories;
  final Function(String)? onDistrictChanged;
  final Function(String)? onBlockChanged;
  final Function(String)? onPanchayatChanged;
  final Function(String)? onVillageChanged;
  final Function(String)? onRegionCategoryChanged;

  const ShadeHeader({
    super.key,
    required this.districts,
    required this.blocks,
    required this.panchayats,
    required this.villages,
    required this.regionCategories,
    this.onDistrictChanged,
    this.onBlockChanged,
    this.onPanchayatChanged,
    this.onVillageChanged,
    this.onRegionCategoryChanged,
  });

  @override
  State<ShadeHeader> createState() => _ShadeHeaderState();
}

class _ShadeHeaderState extends State<ShadeHeader> {
  String? selectedDistrict;
  String? selectedBlock;
  String? selectedVillage;
  String? selectedPanchayat;
  String? selectedRegionCategory;
  // String? selectedStatus;       // Comment out
  // String? selectedSavedBy;      // Comment out

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    //final isTablet = ResponsiveUtils.isTablet(screenWidth);
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
                'Shade Plantation Details',
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                  color: Theme.of(context).colorScheme.error,
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
                            selectedVillage != null ||
                            selectedRegionCategory != null;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFilterDropdown(
            context,
            'District',
            widget.districts,
            selectedDistrict,
            widget.onDistrictChanged ?? (_) {},
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Block',
            widget.blocks,
            selectedBlock,
            widget.onBlockChanged ?? (_) {},
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Panchayat',
            widget.panchayats,
            selectedPanchayat,
            widget.onPanchayatChanged ?? (_) {},
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Village',
            widget.villages,
            selectedVillage,
            widget.onVillageChanged ?? (_) {},
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Region Category',
            widget.regionCategories,
            selectedRegionCategory,
            widget.onRegionCategoryChanged ?? (_) {},
          ),
          /* Comment out Status and Saved By
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Survey Status',
            widget.statuses,
            selectedStatus,
            widget.onStatusChanged ?? (_) {},
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Saved By',
            widget.savedByUsers,
            selectedSavedBy,
            widget.onSavedByChanged ?? (_) {},
          ),
          */
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
                    selectedRegionCategory = null;
                    // selectedStatus = null;        // Comment out
                    // selectedSavedBy = null;       // Comment out
                  });
                  widget.onDistrictChanged?.call('');
                  widget.onBlockChanged?.call('');
                  widget.onPanchayatChanged?.call('');
                  widget.onVillageChanged?.call('');
                  widget.onRegionCategoryChanged?.call('');
                  // widget.onStatusChanged?.call('');       // Comment out
                  // widget.onSavedByChanged?.call('');      // Comment out
                },
              ),
            ),
          ],
        ],
      ),
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
        .withLightness((HSLColor.fromColor(primaryColor).lightness * 0.8).clamp(0.0, 1.0))
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
                          if (label == 'District') selectedDistrict = null;
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
                          if (label == 'Region Category') selectedRegionCategory = null;
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
                  if (label == 'Region Category') selectedRegionCategory = value;
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