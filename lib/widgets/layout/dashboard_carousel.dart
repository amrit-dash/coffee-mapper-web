import 'dart:async';

import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Custom scroll behavior to prevent horizontal scrolling
class NoHorizontalScrollBehavior extends ScrollBehavior {
  final bool isMobile;

  const NoHorizontalScrollBehavior({this.isMobile = false});

  @override
  Set<PointerDeviceKind> get dragDevices =>
      isMobile ? {PointerDeviceKind.touch, PointerDeviceKind.stylus} : {};

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return isMobile
        ? const PageScrollPhysics()
        : const NeverScrollableScrollPhysics();
  }
}

class DashboardCarousel extends StatefulWidget {
  static const List<String> carouselImages = [
    'assets/images/dashboard-carousel/1.png',
    'assets/images/dashboard-carousel/2.png',
    'assets/images/dashboard-carousel/3.png',
    'assets/images/dashboard-carousel/4.png',
    'assets/images/dashboard-carousel/5.png',
    'assets/images/dashboard-carousel/6.png',
  ];

  const DashboardCarousel({super.key});

  @override
  State<DashboardCarousel> createState() => _DashboardCarouselState();
}

class _DashboardCarouselState extends State<DashboardCarousel> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;
  int _currentPage = 0;

  static const Duration _autoScrollDuration = Duration(seconds: 7);
  static const Duration _transitionDuration = Duration(milliseconds: 750);

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _stopAutoScroll();
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollDuration, (timer) {
      if (!_isUserInteracting && mounted) {
        if (_currentPage < DashboardCarousel.carouselImages.length - 1) {
          _pageController.nextPage(
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            0,
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  void _handleUserInteractionStart() {
    setState(() => _isUserInteracting = true);
    _stopAutoScroll();
  }

  void _handleUserInteractionEnd() {
    setState(() => _isUserInteracting = false);
    _startAutoScroll();
  }

  // ignore: deprecated_member_use
  void _handleKeyEvent(RawKeyEvent event) {
    // ignore: deprecated_member_use
    if (event is! RawKeyDownEvent) return;

    _handleUserInteractionStart();

    switch (event.logicalKey.keyLabel) {
      case 'Arrow Left':
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        }
        break;
      case 'Arrow Right':
        if (_currentPage < DashboardCarousel.carouselImages.length - 1) {
          _pageController.nextPage(
            duration: _transitionDuration,
            curve: Curves.easeInOut,
          );
        }
        break;
    }

    Future.delayed(const Duration(seconds: 2), _handleUserInteractionEnd);
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).cardColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    // Calculate height based on screen width while maintaining 16:9 aspect ratio
    // Use different height factors for mobile and desktop
    final heightFactor = isMobile ? 0.85 : 0.575;
    final calculatedHeight = (screenWidth * 9 / 16) * heightFactor;

    return Container(
      height: calculatedHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // ignore: deprecated_member_use
        child: RawKeyboardListener(
          focusNode: _focusNode,
          onKey: _handleKeyEvent,
          child: Stack(
            children: [
              // Main carousel content
              Listener(
                onPointerDown: (_) => _handleUserInteractionStart(),
                onPointerUp: (_) => _handleUserInteractionEnd(),
                child: ScrollConfiguration(
                  behavior: NoHorizontalScrollBehavior(isMobile: isMobile),
                  child: PageView.builder(
                    physics: isMobile
                        ? const PageScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: DashboardCarousel.carouselImages.length,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        DashboardCarousel.carouselImages[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Error loading carousel image: $error');
                          return Container(
                            color: Colors.black,
                            child: const Center(
                              child: Icon(Icons.image_not_supported,
                                  size: 48, color: Colors.white),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              // Controls overlay - Only show on desktop
              if (!isMobile)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 20,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: scaffoldColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Previous button
                          if (_currentPage > 0)
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back_ios,
                                color: Theme.of(context).colorScheme.error,
                                size: 17,
                              ),
                              onPressed: () {
                                _handleUserInteractionStart();
                                _pageController.previousPage(
                                  duration: _transitionDuration,
                                  curve: Curves.easeInOut,
                                );
                                Future.delayed(
                                  const Duration(seconds: 2),
                                  _handleUserInteractionEnd,
                                );
                              },
                            ),
                          // Page indicator
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '${_currentPage + 1}/${DashboardCarousel.carouselImages.length}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Next button
                          if (_currentPage <
                              DashboardCarousel.carouselImages.length - 1)
                            IconButton(
                              icon: Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(context).colorScheme.error,
                                size: 17,
                              ),
                              onPressed: () {
                                _handleUserInteractionStart();
                                _pageController.nextPage(
                                  duration: _transitionDuration,
                                  curve: Curves.easeInOut,
                                );
                                Future.delayed(
                                  const Duration(seconds: 2),
                                  _handleUserInteractionEnd,
                                );
                              },
                            ),
                        ],
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
