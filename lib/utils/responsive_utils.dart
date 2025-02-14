import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints
  static const double mobile = 768;
  static const double tablet = 1000;
  static const double desktop = 1200;

  // Device type checks
  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < desktop;
  static bool isDesktop(double width) => width >= desktop;

  // Layout dimensions
  static double getSideMenuWidth(double screenWidth) {
    if (screenWidth < tablet) return 250;
    if (screenWidth < desktop) return 250;
    return 250;
  }

  // Font sizes
  static double getFontSize(double screenWidth, double baseSize) {
    if (screenWidth < 360) return baseSize * 0.65;
    if (screenWidth < mobile) return baseSize * 0.75;
    if (screenWidth < desktop) return baseSize * 0.9;
    return baseSize;
  }

  // Dashboard header font size
  static double getDashboardHeaderSize(double screenWidth) {
    if (screenWidth < mobile) return 20;
    if (screenWidth < desktop) return 22;
    return 24;
  }

  // Logo dimensions
  static double getLogoHeight(double screenWidth, double screenHeight) {
    // Base height calculation from screen height
    double baseHeight = screenHeight * 0.12;
    
    // Adjust based on width constraints
    if (screenWidth < mobile) {
      baseHeight *= 0.8;  // Reduce more on mobile
    } else if (screenWidth < desktop) {
      baseHeight *= 0.85;  // Slightly reduce on tablet
    }
    
    // Additional height constraints
    if (screenHeight < 400) {
      baseHeight = screenHeight * 0.08;
    }
    
    // Ensure minimum and maximum bounds
    return baseHeight.clamp(40.0, 120.0);
  }

  // Padding and spacing
  static double getPadding(double screenWidth) {
    if (screenWidth < 360) return 8.0;
    if (screenWidth < mobile) return 15.0;
    return 25.0;
  }

  static double getTableContainerHeight(double screenWidth) {
    if (screenWidth < mobile) return 380;  // Mobile height
    if (screenWidth < desktop) return 420;  // Tablet height
    return 447;  // Desktop height
  }

  // Column width responsiveness
  static double getColumnWidth(double screenWidth, double baseWidth) {
    if (screenWidth < 360) return baseWidth * 0.6;  // Very small screens
    if (screenWidth < mobile) return baseWidth * 0.7;  // Mobile
    if (screenWidth < desktop) return baseWidth * 0.85;  // Tablet
    return baseWidth;  // Desktop
  }

  // Row heights
  static double getRowHeight(double screenWidth, double baseHeight) {
    if (screenWidth < 360) return baseHeight * 0.85;
    if (screenWidth < mobile) return baseHeight * 0.9;
    if (screenWidth < desktop) return baseHeight * 0.95;
    return baseHeight;
  }

  static double getResponsivePadding(Size screenSize) {
    if (screenSize.width < 600) {
      return 8.0;
    } else if (screenSize.width < 1200) {
      return 16.0;
    } else {
      return 24.0;
    }
  }
} 