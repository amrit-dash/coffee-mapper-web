// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

class InteractiveChartDialog extends StatefulWidget {
  final String chartUrl;
  final String title;

  // Standard dimensions from the iframe
  static const double _defaultWidth = 593.0;
  static const double _defaultHeight = 403.0;

  const InteractiveChartDialog({
    super.key,
    required this.chartUrl,
    required this.title,
  });

  @override
  State<InteractiveChartDialog> createState() => _InteractiveChartDialogState();
}

class _InteractiveChartDialogState extends State<InteractiveChartDialog> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    // Calculate scaling factor to fit screen if needed
    final scale = isMobile
        ? (screenWidth * 0.8) / InteractiveChartDialog._defaultWidth
        : 1.0;
    final width = InteractiveChartDialog._defaultWidth * scale;
    final height = InteractiveChartDialog._defaultHeight * scale;

    // Generate a unique ID for the iframe
    final String viewId =
        'interactive-chart-${DateTime.now().millisecondsSinceEpoch}';

    // Register the view factory
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final iframeElement = html.IFrameElement()
        ..src = widget.chartUrl
        ..style.border = 'none'
        ..style.backgroundColor = 'transparent';

      if (isMobile) {
        // For mobile, use CSS transform to scale the content
        iframeElement.style
          ..width = '${InteractiveChartDialog._defaultWidth}px'
          ..height = '${InteractiveChartDialog._defaultHeight}px'
          ..transform = 'scale($scale)'
          ..transformOrigin = '0 0'
          ..position = 'absolute';
      } else {
        // For desktop, use normal dimensions
        iframeElement.style
          ..width = '${width.round()}px'
          ..height = '${height.round()}px';
      }

      return iframeElement;
    });

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Loading indicator in the background
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).highlightColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Interactive Chart...',
                        style: TextStyle(
                          color: Theme.of(context).highlightColor,
                          fontFamily: 'Gilroy-SemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Iframe on top with transparent background
              HtmlElementView(viewType: viewId),
            ],
          ),
        ),
      ),
    );
  }
}
