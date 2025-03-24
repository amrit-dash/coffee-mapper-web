import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle gilroyMedium(
    BuildContext context, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: 'Gilroy-Medium',
      fontSize: fontSize != null
          ? ResponsiveUtils.getFontSize(
              MediaQuery.of(context).size.width, fontSize)
          : null,
      color: color,
      fontWeight: fontWeight,
      height: 1.2,
    );
  }

  static TextStyle gilroySemiBold(
    BuildContext context, {
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return TextStyle(
      fontFamily: 'Gilroy-SemiBold',
      fontSize: fontSize != null
          ? ResponsiveUtils.getFontSize(
              MediaQuery.of(context).size.width, fontSize)
          : null,
      color: color,
      fontWeight: fontWeight ?? FontWeight.w600,
      height: 1.2,
    );
  }

  // Predefined styles for common use cases
  static TextStyle tableData(BuildContext context) {
    return gilroyMedium(
      context,
      fontSize: 12.5,
      color: Theme.of(context).colorScheme.error,
    );
  }

  static TextStyle tableHeader(BuildContext context) {
    return gilroySemiBold(
      context,
      fontSize: 13,
      color: Theme.of(context).colorScheme.secondaryContainer,
      //fontWeight: FontWeight.w900,
    );
  }

  static TextStyle statusText(BuildContext context) {
    return gilroySemiBold(
      context,
      fontSize:
          ResponsiveUtils.getFontSize(MediaQuery.of(context).size.width, 12),
    );
  }

  static TextStyle viewButtonText(BuildContext context) {
    return gilroySemiBold(
      context,
      fontSize: 12,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  static TextStyle dialogTitle(BuildContext context) {
    return gilroySemiBold(
      context,
      color: Theme.of(context).colorScheme.error,
    );
  }

  static TextStyle dialogContent(BuildContext context) {
    return gilroyMedium(
      context,
      fontSize: 14.5,
      color: Theme.of(context).colorScheme.secondary,
    );
  }

  static TextStyle dialogButton(BuildContext context) {
    return gilroyMedium(
      context,
      color: Theme.of(context).highlightColor,
    );
  }
}
