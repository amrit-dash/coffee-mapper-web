import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:coffee_mapper_web/widgets/dialogs/media_carousel_dialog/media_item.dart';
import 'package:coffee_mapper_web/widgets/dialogs/media_carousel_dialog/carousel_controls.dart';

class MediaCarouselDialog extends StatefulWidget {
  final List<String> mediaUrls;

  const MediaCarouselDialog({
    super.key,
    required this.mediaUrls,
  });

  static Future<void> show(BuildContext context, List<String> mediaUrls) async {
    if (mediaUrls.isEmpty) return;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) => MediaCarouselDialog(mediaUrls: mediaUrls),
    );
  }

  @override
  State<MediaCarouselDialog> createState() => _MediaCarouselDialogState();
}

class _MediaCarouselDialogState extends State<MediaCarouselDialog> {
  late PageController _pageController;
  int _currentIndex = 0;
  static const double dialogSizePercent = 0.85;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _preloadMedia();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadMedia() async {
    // Implement browser caching hint
    for (final url in widget.mediaUrls) {
      final link = html.LinkElement()
        ..rel = 'preload'
        ..as = _isVideoUrl(url) ? 'video' : 'image'
        ..href = url;
      html.document.head!.append(link);
    }
  }

  bool _isVideoUrl(String url) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.wmv', '.flv', '.mkv'];
    return videoExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // ignore: deprecated_member_use
  void _handleKeyEvent(RawKeyEvent event) {
    // ignore: deprecated_member_use
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        Navigator.of(context).pop();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _previousPage();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _nextPage();
      }
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentIndex < widget.mediaUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * dialogSizePercent;
    final dialogHeight = screenSize.height * dialogSizePercent;

    // ignore: deprecated_member_use
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Container(
          width: dialogWidth,
          height: dialogHeight,
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // Main content
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemCount: widget.mediaUrls.length,
                itemBuilder: (context, index) => MediaItem(
                  url: widget.mediaUrls[index],
                  onError: (_) {},
                  isVisible: index == _currentIndex,
                ),
              ),
              
              // Navigation arrows
              Positioned(
                left: 16,
                top: 0,
                bottom: 0,
                child: CarouselControls(
                  direction: CarouselDirection.previous,
                  onTap: _previousPage,
                  enabled: _currentIndex > 0,
                ),
              ),
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: CarouselControls(
                  direction: CarouselDirection.next,
                  onTap: _nextPage,
                  enabled: _currentIndex < widget.mediaUrls.length - 1,
                ),
              ),

              // Close button
              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withAlpha(204),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                      iconSize: 24,
                      splashRadius: 20,
                      tooltip: 'Close',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 