import 'package:flutter/material.dart';

class TableConstants {
  // Dimensions
  static const double kBorderWidth = 0.4;
  static const double kBorderWidthThick = 1.0;
  static const double kBorderWidthBottom = 1.1;
  static const double kHeaderHeight = 55;
  static const double kRowHeight = 45;
  static const double kMinTableWidth =
      2700; // Increased to accommodate new columns
  static const double kStatusBorderRadius = 12;
  static const double kDeleteIconSize = 18;
  static const double kDeleteButtonMaxHeight = 28;
  static const double kShadowHeight = 8;
  static const double kHeaderDividerWidth = 1.1; // Thicker divider for header

  // Padding and Margins
  static const double kHorizontalPadding = 8;
  static const double kVerticalPadding = 4;
  static const double kColumnSpacing = 0;
  static const double kHorizontalMargin = 0;

  // Column Widths
  static const double kDeleteColumnWidth = 90;
  static const double kRegionNameWidth = 220;
  static const double kBlockWidth = 150;
  static const double kPanchayatWidth = 150;
  static const double kVillageWidth = 180;
  static const double kRegionCategoryWidth = 150;
  static const double kDefaultColumnWidth = 100;
  static const double kBoundaryWidth = 100; // Renamed from kShadeBoundaryWidth
  static const double kAreaWidth = 120; // Renamed from kShadeAreaWidth
  static const double kPlantationYearWidth = 100;
  static const double kPlantVarietyWidth = 180;
  static const double kShadeTypeWidth = 180;
  static const double kAverageHeightWidth = 100;
  static const double kBeneficiariesCountWidth = 110;
  static const double kSurvivalPercentageWidth = 100;
  static const double kPlotNumberWidth = 100;
  static const double kKhataNumberWidth = 100;
  static const double kAgencyWidth = 150;
  static const double kSurveyStatusWidth = 100;
  static const double kSavedByWidth = 200;
  static const double kSavedOnWidth = 160;
  static const double kUpdatedOnWidth = 160;
  static const double kMediaWidth = 80; // Renamed from kShadeMediaWidth
  static const double kBoundaryImageWidth = 100;
  static const double kAverageYieldWidth = 100;

  // Colors
  static const Color kDividerColor = Color(0xFFFCDCBC);
  static const Color kHeaderDividerColor = Color(0xFFD5B799);

  // Gradient Stops
  static const List<double> kShadowGradientStops = [0.0, 0.8];
  static const double kShadowOpacity = 102.0; // 0.4 opacity

  // Formatting
  static const int kDecimalPrecision = 2;

  /// Formats a numeric value according to table rules:
  /// - Returns empty string if value is zero
  /// - Removes decimal places if they are all zeros
  /// - Maintains specified decimal precision for non-whole numbers
  static String formatNumber(double value, {String? suffix}) {
    if (value == 0) {
      return '';
    }

    // Check if the number is whole (no decimal places)
    if (value == value.roundToDouble()) {
      return '${value.toInt()}${suffix ?? ''}';
    }

    return '${value.toStringAsFixed(kDecimalPrecision)}${suffix ?? ''}';
  }

  // Legacy table constants
  static const double kNameWidth = 250.0;
  static const double kCareOfNameWidth = 250.0;
  static const double kLegacyBlockWidth = 200.0;
  static const double kLegacyPanchayatWidth = 200.0;
  static const double kLegacyVillageWidth = 200.0;
  static const double kYearWidth = 150.0;
  static const double kStatusWidth = 160.0;
}
