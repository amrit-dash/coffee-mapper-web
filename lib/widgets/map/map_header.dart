import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class MapHeader extends StatefulWidget {
  final List<String> districts;
  final List<String> blocks;
  final List<String> panchayats;
  final List<String> villages;
  final List<String> regionCategories;
  final Set<String> selectedRegionCategories;
  final Function(String)? onDistrictChanged;
  final Function(String)? onBlockChanged;
  final Function(String)? onPanchayatChanged;
  final Function(String)? onVillageChanged;
  final Function(Set<String>)? onRegionCategoriesChanged;

  const MapHeader({
    super.key,
    required this.districts,
    required this.blocks,
    required this.panchayats,
    required this.villages,
    required this.regionCategories,
    required this.selectedRegionCategories,
    this.onDistrictChanged,
    this.onBlockChanged,
    this.onPanchayatChanged,
    this.onVillageChanged,
    this.onRegionCategoriesChanged,
  });

  @override
  State<MapHeader> createState() => _MapHeaderState();
}

class _MapHeaderState extends State<MapHeader> {
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
                'Map Overview',
                style: TextStyle(
                  fontFamily: 'Gilroy-SemiBold',
                  fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              if (isDesktop) const SizedBox(width: 40),
              if (isDesktop) Expanded(child: _buildFiltersRow()),
            ],
          ),
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(child: _buildFiltersRow()),
            ),
        ],
      ),
    );
  }

  Widget _buildFiltersRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final hasActiveFilters = selectedDistrict != null ||
        selectedBlock != null ||
        selectedPanchayat != null ||
        selectedVillage != null ||
        widget.selectedRegionCategories.isNotEmpty;

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
            (value) {
              setState(() {
                selectedDistrict = value.isEmpty ? null : value;
                selectedBlock = null;
                selectedPanchayat = null;
                selectedVillage = null;
              });
              widget.onDistrictChanged?.call(value);
            },
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Block',
            widget.blocks,
            selectedBlock,
            (value) {
              setState(() {
                selectedBlock = value.isEmpty ? null : value;
                selectedPanchayat = null;
                selectedVillage = null;
              });
              widget.onBlockChanged?.call(value);
            },
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Panchayat',
            widget.panchayats,
            selectedPanchayat,
            (value) {
              setState(() {
                selectedPanchayat = value.isEmpty ? null : value;
                selectedVillage = null;
              });
              widget.onPanchayatChanged?.call(value);
            },
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildFilterDropdown(
            context,
            'Village',
            widget.villages,
            selectedVillage,
            (value) {
              setState(() {
                selectedVillage = value.isEmpty ? null : value;
              });
              widget.onVillageChanged?.call(value);
            },
          ),
          SizedBox(width: isMobile ? 8 : 12),
          _buildRegionCategoryMultiSelect(context),
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
                  widget.onDistrictChanged?.call('');
                  widget.onBlockChanged?.call('');
                  widget.onPanchayatChanged?.call('');
                  widget.onVillageChanged?.call('');
                  widget.onRegionCategoriesChanged?.call({});
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionCategoryMultiSelect(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    final horizontalPadding = isMobile ? 8.0 : (isTablet ? 10.0 : 12.0);
    final verticalPadding = isMobile ? 4.0 : (isTablet ? 5.0 : 6.0);
    final fontSize = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final containerHeight = isMobile ? 28.0 : (isTablet ? 32.0 : 36.0);

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
        color: widget.selectedRegionCategories.isNotEmpty
            ? selectedColor
            : primaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Select Region Categories',
        offset: const Offset(0, 40),
        onSelected: (String category) {
          final newCategories =
              Set<String>.from(widget.selectedRegionCategories);
          if (newCategories.contains(category)) {
            newCategories.remove(category);
          } else {
            newCategories.add(category);
          }
          widget.onRegionCategoriesChanged?.call(newCategories);
        },
        itemBuilder: (BuildContext context) =>
            widget.regionCategories.map((String category) {
          final isSelected = widget.selectedRegionCategories.contains(category);
          return CheckedPopupMenuItem<String>(
            value: category,
            checked: isSelected,
            child: Text(category),
          );
        }).toList(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.selectedRegionCategories.isEmpty
                  ? 'Category'
                  : '${widget.selectedRegionCategories.length} Selected',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy-Medium',
                fontSize: fontSize,
              ),
            ),
            SizedBox(width: horizontalPadding),
            if (widget.selectedRegionCategories.isEmpty)
              Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
                size: fontSize * 1.5,
              )
            else
              GestureDetector(
                onTap: () {
                  widget.onRegionCategoriesChanged?.call({});
                },
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: fontSize * 1.2,
                ),
              ),
          ],
        ),
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
