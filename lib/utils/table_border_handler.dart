import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';

class TableBorderHandler {
  static TableBorder getTableBorder() {
    return TableBorder(
      verticalInside: _buildBorder(
        width: TableConstants.kBorderWidthThick,
        color: TableConstants.kHeaderDividerColor,
      ),
      horizontalInside: _buildBorder(
        width: TableConstants.kBorderWidth,
        color: TableConstants.kHeaderDividerColor,
      ),
      bottom: _buildBorder(
        width: TableConstants.kBorderWidthBottom,
        color: TableConstants.kHeaderDividerColor,
      ),
    );
  }

  static BorderSide _buildBorder({
    required double width,
    required Color color,
  }) {
    return BorderSide(
      color: color,
      width: width,
    );
  }

  static Widget buildHeaderBorder(double screenWidth) {
    return Positioned(
      top: screenWidth,
      left: 0,
      right: 0,
      height: TableConstants.kBorderWidth,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: _buildBorder(
              width: TableConstants.kBorderWidth,
              color: TableConstants.kDividerColor,
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildHeaderShadow(BuildContext context, double screenWidth) {
    return Positioned(
      top: screenWidth,
      left: 0,
      right: 0,
      height: TableConstants.kShadowHeight,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withValues(
                    alpha: TableConstants.kShadowOpacity,
                  ),
              Theme.of(context).colorScheme.tertiary.withValues(
                    alpha: 0.0,
                  ),
            ],
            stops: TableConstants.kShadowGradientStops,
          ),
        ),
      ),
    );
  }

  static Widget buildHeaderVerticalDivider(BuildContext context) {
    return Container(
      width: TableConstants.kHeaderDividerWidth,
      decoration: BoxDecoration(
        border: Border(
          right: _buildBorder(
            width: TableConstants.kHeaderDividerWidth,
            color: TableConstants.kHeaderDividerColor,
          ),
        ),
      ),
    );
  }
}
