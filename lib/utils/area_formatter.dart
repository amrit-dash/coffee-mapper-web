import 'package:flutter/material.dart';

class AreaFormatter {
  static const double hectareConversion = 10000.0; // 1 hectare = 10000 m²
  static const double threshold = 10.0; // Threshold for switching to hectares
  
  // Format area for display with appropriate unit
  static String formatArea(double areaInSquareMeters, [bool useThreshold = true]) {
    if (!useThreshold || areaInSquareMeters >= threshold) {
      double hectares = areaInSquareMeters / hectareConversion;
      return '${hectares.toStringAsFixed(3)} ha';
    } else {
      return '${areaInSquareMeters.toStringAsFixed(2)} m²';
    }
  }
  
  // Get tooltip showing only the relevant unit
  static String getAreaTooltip(double areaInSquareMeters) {
    if (areaInSquareMeters >= threshold) {
      return '${areaInSquareMeters.toStringAsFixed(2)} m²';
    } else {
      double hectares = areaInSquareMeters / hectareConversion;
      return (hectares.toStringAsFixed(3) == "0.000") ? '' : '${hectares.toStringAsFixed(3)} ha';
    }
  }
  
  // Get area widget with tooltip
  static Widget getAreaWidget(BuildContext context, double areaInSquareMeters, {double fontSize = 24}) {
    return Tooltip(
      message: getAreaTooltip(areaInSquareMeters),
      child: Text(
        formatArea(areaInSquareMeters),
        style: TextStyle(
          fontFamily: 'Gilroy-Medium',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).highlightColor,
        ),
      ),
    );
  }
} 