// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;

class CustomInfoWindow extends StatefulWidget {
  final String imageUrl;
  final gmap.LatLng coordinates;
  final VoidCallback onClose;

  const CustomInfoWindow({
    super.key,
    required this.imageUrl,
    required this.coordinates,
    required this.onClose,
  });

  @override
  State<CustomInfoWindow> createState() => _CustomInfoWindowState();
}

class _CustomInfoWindowState extends State<CustomInfoWindow> {
  late final String viewId;
  bool isImageLoaded = false;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    viewId = 'image-${DateTime.now().millisecondsSinceEpoch}';
    _loadImage();
  }

  void _loadImage() {
    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final imageElement = html.ImageElement()
        ..src = widget.imageUrl
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      imageElement
        ..onLoad.listen((_) => _updateImageState(loaded: true))
        ..onError.listen((_) => _updateImageState(error: true));

      return imageElement;
    });
  }

  void _updateImageState({bool loaded = false, bool error = false}) {
    if (mounted) {
      setState(() {
        isImageLoaded = loaded;
        hasError = error;
      });
    }
  }

  TextStyle _getTextStyle(double fontSize, [Color? color]) {
    return TextStyle(
      fontFamily: 'Gilroy-SemiBold',
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    //final screenHeight = MediaQuery.of(context).size.height;
    final imageSize = ResponsiveUtils.isDesktop(screenWidth)
        ? screenWidth * 0.25
        : screenWidth * (ResponsiveUtils.isTablet(screenWidth) ? 0.30 : 0.45);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: imageSize),
      child: Card(
        color: Theme.of(context).cardColor,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(screenWidth),
              const SizedBox(height: 8),
              _buildImageContainer(imageSize),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final errorColor = Theme.of(context).colorScheme.error;
    final coordinates = '${widget.coordinates.latitude.toStringAsFixed(6)}, '
        '${widget.coordinates.longitude.toStringAsFixed(6)}';

    return ConstrainedBox(
      constraints: BoxConstraints(
          maxWidth: ResponsiveUtils.isDesktop(screenWidth)
              ? screenWidth * 0.25
              : screenWidth *
                  (ResponsiveUtils.isTablet(screenWidth) ? 0.30 : 0.45)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  'Coordinates:',
                  style: _getTextStyle(
                    ResponsiveUtils.getFontSize(screenWidth, 15),
                    errorColor,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    coordinates,
                    style: _getTextStyle(
                      ResponsiveUtils.getFontSize(screenWidth, 14),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: widget.onClose,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(double imageSize) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: Stack(
          fit: StackFit.expand,
          children: [
            HtmlElementView(viewType: viewId),
            if (!isImageLoaded && !hasError)
              const Center(child: CircularProgressIndicator()),
            if (hasError) _buildErrorDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorDisplay() {
    final errorColor = Theme.of(context).colorScheme.error;
    return Container(
      color: errorColor.withValues(alpha: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: errorColor),
          const SizedBox(height: 4),
          Text(
            'Failed to load image',
            style: TextStyle(
              color: errorColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
