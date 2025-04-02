import 'package:coffee_mapper_web/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class NewsScrollView extends ConsumerStatefulWidget {
  const NewsScrollView({super.key});

  @override
  ConsumerState<NewsScrollView> createState() => _NewsScrollViewState();
}

class _NewsScrollViewState extends ConsumerState<NewsScrollView> {
  late ScrollController _scrollController;
  bool _isScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
          // Pause at the bottom before going back to top
          await Future.delayed(const Duration(milliseconds: 1000));
          if (!mounted || !_isScrolling) break;

          // Smooth scroll to top with a slower animation
          await _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
          );

          // Pause at the top before starting to scroll down again
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
  Widget build(BuildContext context) {
    final news = ref.watch(dashboardNewsProvider);

    return MouseRegion(
      onEnter: (_) => setState(() => _isScrolling = false),
      onExit: (_) {
        setState(() => _isScrolling = true);
        _startScrolling();
      },
      child: SizedBox(
        height: 200,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.zero,
            itemCount: news.newsItems.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  news.newsItems[index],
                  style: TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
