import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double width;

  const MarqueeText({
    super.key,
    required this.text,
    this.style,
    required this.width,
  });

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText> {
  late ScrollController _scrollController;
  bool _isScrolling = true;
  bool _shouldScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfShouldScroll();
    });
  }

  void _checkIfShouldScroll() {
    final textSpan = TextSpan(
      text: widget.text,
      style: widget.style,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout(maxWidth: double.infinity);

    setState(() {
      _shouldScroll = textPainter.width > widget.width;
    });

    if (_shouldScroll) {
      _startScrolling();
    }
  }

  void _startScrolling() async {
    await Future.delayed(const Duration(seconds: 1));

    while (_isScrolling && mounted) {
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted || !_isScrolling) break;

      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;

        if (currentScroll >= maxScroll) {
          // Pause at the end before going back to start
          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted || !_isScrolling) break;

          // Smooth scroll back to start
          await _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
          );

          // Pause at the start before scrolling again
          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted || !_isScrolling) break;
        } else {
          await _scrollController.animateTo(
            currentScroll + 0.5,
            duration: const Duration(milliseconds: 50),
            curve: Curves.linear,
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.width != widget.width) {
      _checkIfShouldScroll();
    }
  }

  @override
  void dispose() {
    _isScrolling = false;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldScroll) {
      return SizedBox(
        width: widget.width,
        child: Text(
          widget.text,
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isScrolling = false),
      onExit: (_) {
        setState(() => _isScrolling = true);
        _startScrolling();
      },
      child: SizedBox(
        width: widget.width,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                widget.text,
                style: widget.style,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OfficialsRow extends StatelessWidget {
  const OfficialsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveUtils.isTablet(screenWidth);
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    // Don't render if mobile view
    if (isMobile) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 10 : 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOfficialAvatar(
              context,
              'assets/images/1.png',
              'Shri Kumar Vardhan Singh Deo',
              'Hon\'ble Deputy Chief Minister',
            ),
            _buildOfficialAvatar(
              context,
              'assets/images/2.png',
              'Dr. Arabinda Kumar Padhee',
              'IAS, Principal Secretary',
            ),
            _buildOfficialAvatar(
              context,
              'assets/images/3.png',
              'Sri Nikhil Pavan Kalyan',
              'IAS, Director',
            ),
            _buildOfficialAvatar(
              context,
              'assets/images/4.png',
              'Shri V Keerthi Vasan',
              'IAS, Collector & DM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialAvatar(
      BuildContext context, String imagePath, String name, String designation) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    // Adjust width based on screen size
    double containerWidth;
    if (isTablet) {
      containerWidth = screenWidth * 0.12; // Wider in tablet
    } else {
      containerWidth = screenWidth * 0.09; // Desktop view
    }

    return Container(
      width: containerWidth,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: isTablet ? 24 : 22,
            backgroundImage: AssetImage(imagePath),
          ),
          const SizedBox(height: 4),
          Container(
            width: containerWidth - 8,
            alignment: Alignment.center,
            child: Tooltip(
              message: name,
              child: MarqueeText(
                text: name,
                width: containerWidth - 8,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: isTablet ? 11 : 10,
                ),
              ),
            ),
          ),
          Container(
            width: containerWidth - 8,
            alignment: Alignment.center,
            child: Tooltip(
              message: designation,
              child: Text(
                designation,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: isTablet ? 9 : 8,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
