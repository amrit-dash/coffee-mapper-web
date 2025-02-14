import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:coffee_mapper_web/providers/news_provider.dart';

class SidebarImageCard extends ConsumerStatefulWidget {
  static const List<String> carouselImages = [
    'assets/images/sidebar-carousel/sidebar-main.jpg',
    'assets/images/sidebar-carousel/sidebar-carousel-1.jpg',
    'assets/images/sidebar-carousel/sidebar-carousel-2.png',
    'assets/images/sidebar-carousel/sidebar-carousel-3.png',
    'assets/images/sidebar-carousel/sidebar-carousel-4.jpg',
    'assets/images/sidebar-carousel/sidebar-carousel-5.jpg',
  ];

  const SidebarImageCard({super.key});

  @override
  ConsumerState<SidebarImageCard> createState() => _SidebarImageCardState();
}

class _SidebarImageCardState extends ConsumerState<SidebarImageCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // If animation has already run, make it visible immediately
    if (ref.read(sidebarImageAnimatedProvider)) {
      _isVisible = true;
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_isVisible && !ref.read(sidebarImageAnimatedProvider) && mounted) {
      setState(() => _isVisible = true);
      _controller.forward();
      ref.read(sidebarImageAnimatedProvider.notifier).state = true;
    }
  }

  void _showCarouselDialog(BuildContext context) {
    // Get screen size
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Calculate responsive dimensions
    // Use 85% of screen width as base width, then calculate height using 16:9 ratio
    final dialogWidth = screenWidth * 0.85;
    final dialogHeight = dialogWidth * (9 / 16);

    // Calculate padding values clamped between 16 and 48
    final horizontalPadding =
        ((screenWidth - dialogWidth) / 2).clamp(16.0, 48.0);
    final verticalPadding =
        ((screenHeight - dialogHeight) / 2).clamp(16.0, 48.0);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: dialogWidth.clamp(400.0, 1200.0),
            maxHeight: dialogHeight.clamp(
                225.0, 675.0), // 16:9 ratio maintained in constraints
          ),
          child: const SidebarCarouselDialog(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch the news provider to trigger animation after news loads
    final news = ref.watch(dashboardNewsProvider);
    final hasAnimated = ref.watch(sidebarImageAnimatedProvider);

    // Start animation only if news is loaded and we haven't animated globally yet
    if (news.newsItems.isNotEmpty && !hasAnimated) {
      // Add a small delay to ensure news view is rendered
      Future.delayed(const Duration(milliseconds: 200), _startAnimation);
    }

    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 2),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _isVisible ? () => _showCarouselDialog(context) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.asset(
                  SidebarImageCard.carouselImages[0],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint('Error loading sidebar image: $error');
                    return Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 32),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SidebarCarouselDialog extends StatefulWidget {
  const SidebarCarouselDialog({super.key});

  @override
  State<SidebarCarouselDialog> createState() => _SidebarCarouselDialogState();
}

class _SidebarCarouselDialogState extends State<SidebarCarouselDialog> {
  late final PageController _pageController;
  late final FocusNode _focusNode;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  // ignore: deprecated_member_use
  void _handleKeyEvent(RawKeyEvent event) {
    // ignore: deprecated_member_use
    if (event is! RawKeyDownEvent) return;

    switch (event.logicalKey.keyLabel) {
      case 'Arrow Left':
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 'Arrow Right':
        if (_currentPage < SidebarImageCard.carouselImages.length - 1) {
          _pageController.nextPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
        break;
      case 'Escape':
        Navigator.of(context).pop();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldColor = Theme.of(context).cardColor;
    // ignore: deprecated_member_use
    return RawKeyboardListener(
      focusNode: _focusNode,
      onKey: _handleKeyEvent,
      child: Stack(
        children: [
          // Main content
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: SidebarImageCard.carouselImages.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Image.asset(
                          SidebarImageCard.carouselImages[index],
                          fit: BoxFit.cover,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
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
                  );
                },
              ),
            ),
          ),
          // Controls - Single Pill
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous button
                    if (_currentPage > 0)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                    // Page indicator
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${_currentPage + 1}/${SidebarImageCard.carouselImages.length}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Next button
                    if (_currentPage <
                        SidebarImageCard.carouselImages.length - 1)
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        onPressed: () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Close button
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              decoration: BoxDecoration(
                color: scaffoldColor.withValues(alpha: 78),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.error, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
