import 'package:flutter/material.dart';
// ignore: depracated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

/// A widget that displays either an image or video media item with loading and error states
class MediaItem extends StatefulWidget {
  final String url;
  final Function(String) onError;
  final bool isVisible;

  const MediaItem({
    super.key,
    required this.url,
    required this.onError,
    required this.isVisible,
  });

  @override
  State<MediaItem> createState() => _MediaItemState();
}

class _MediaItemState extends State<MediaItem> {
  // Duration for fade transitions
  static const Duration _transitionDuration = Duration(milliseconds: 400);

  // Supported video file extensions
  static const List<String> _videoExtensions = ['.mp4', '.mov', '.avi', '.wmv'];

  // Cache for preloaded media to improve performance
  static final Map<String, bool> _preloadedMedia = {};

  // State variables
  bool _isLoading = true;
  bool _hasError = false;
  String? _viewId;
  bool _isDisposed = false;
  html.Element? _mediaElement;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
    _preloadNextMedia();
  }

  @override
  void dispose() {
    _isDisposed = true;
    // Clean up media elements
    _mediaElement?.remove();
    if (_viewId != null) {
      final element = html.document.getElementById(_viewId!);
      element?.remove();
    }
    super.dispose();
  }

  /// Preloads the next media item to improve loading performance
  void _preloadNextMedia() {
    if (_preloadedMedia.containsKey(widget.url)) return;

    final isVideo = _isVideoUrl(widget.url);
    _preloadedMedia[widget.url] = true;

    // Add preload hint using link element
    final link = html.LinkElement()
      ..rel = 'preload'
      ..href = widget.url;

    if (isVideo) {
      link.as = 'video';
    } else {
      link.as = 'image';
    }

    html.document.head!.append(link);
  }

  /// Initializes the media element based on the URL type
  void _initializeMedia() {
    if (_isDisposed) return;

    try {
      _viewId = 'media-${DateTime.now().millisecondsSinceEpoch}';
      final isVideo = _isVideoUrl(widget.url);

      // Register the view factory for the platform view
      ui_web.platformViewRegistry.registerViewFactory(_viewId!, (int viewId) {
        // Create container for media element
        final container = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.display = 'flex'
          ..style.alignItems = 'center'
          ..style.justifyContent = 'center'
          ..style.overflow = 'hidden'
          ..style.backgroundColor = 'transparent';

        if (isVideo) {
          // Create video wrapper for proper sizing
          final wrapper = html.DivElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.display = 'flex'
            ..style.alignItems = 'center'
            ..style.justifyContent = 'center'
            ..style.position = 'relative';

          // Configure video element
          final videoElement = html.VideoElement()
            ..style.maxWidth = '100%'
            ..style.maxHeight = '100%'
            ..style.objectFit = 'contain'
            ..controls = true
            ..muted = true
            ..autoplay = false
            ..preload = 'auto';

          // Handle video load event
          videoElement.onLoadedData.listen((_) {
            if (!_isDisposed && mounted) {
              setState(() => _isLoading = false);
            }
          });

          // Handle video error event
          videoElement.onError.listen((event) {
            if (!_isDisposed && mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
              widget.onError('Failed to load video');
              // Debug error logging commented out
              // print('Video error: $event');
            }
          });

          videoElement.src = widget.url;
          wrapper.children.add(videoElement);
          _mediaElement = wrapper;
        } else {
          // Configure image element
          final img = html.ImageElement()
            ..style.maxWidth = '100%'
            ..style.maxHeight = '100%'
            ..style.objectFit = 'contain';

          // Handle image load event
          img.onLoad.listen((_) {
            if (!_isDisposed && mounted) {
              setState(() => _isLoading = false);
            }
          });

          // Handle image error event
          img.onError.listen((event) {
            if (!_isDisposed && mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
              widget.onError('Failed to load image');
              // Debug error logging commented out
              // print('Image error: $event');
            }
          });

          img.src = widget.url;
          _mediaElement = img;
        }

        container.children.add(_mediaElement!);
        return container;
      });
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        widget.onError(e.toString());
        // Debug error logging commented out
        // print('Media initialization error: $e');
      }
    }
  }

  /// Checks if the given URL points to a video file
  bool _isVideoUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    return _videoExtensions.any((ext) => path.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: _transitionDuration,
      opacity: widget.isVisible ? 1.0 : 0.0,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_viewId != null && !_hasError)
              Center(
                child: HtmlElementView(viewType: _viewId!),
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load media',
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _hasError = false;
                          _isLoading = true;
                        });
                        _initializeMedia();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
