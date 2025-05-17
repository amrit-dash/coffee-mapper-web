// ignore: deprecated_member_use
import 'dart:html' as html;

import 'package:coffee_mapper_web/providers/admin_provider.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/layout/dashboard_carousel.dart';
import 'package:coffee_mapper_web/widgets/layout/dashboard_metrics.dart';
import 'package:coffee_mapper_web/widgets/layout/footer.dart';
import 'package:coffee_mapper_web/widgets/layout/header.dart';
import 'package:coffee_mapper_web/widgets/layout/metrics_overview.dart';
import 'package:coffee_mapper_web/widgets/layout/officials_row.dart';
import 'package:coffee_mapper_web/widgets/layout/side_menu.dart';
import 'package:coffee_mapper_web/widgets/map/map_overview_section.dart';
import 'package:coffee_mapper_web/widgets/tables/coffee_highlights/coffee_highlights_section.dart';
//import 'package:coffee_mapper_web/widgets/tables/legacy_highlights/legacy_highlights_section.dart';
import 'package:coffee_mapper_web/widgets/tables/nursery_highlights/nursery_highlights_section.dart';
import 'package:coffee_mapper_web/widgets/tables/shade_highlights/shade_highlights_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  static bool _isFirstLoad = true; // Static variable to track initial load

  @override
  void initState() {
    super.initState();
    if (_isFirstLoad) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isFirstLoad = false; // Set to false after first load
          });
        }
      });
    } else {
      _isLoading = false; // No loading if not first load
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobileView = ResponsiveUtils.isMobile(screenWidth);

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobileView) const SideMenu(),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).highlightColor,
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding:
                                      EdgeInsets.all(isMobileView ? 16 : 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildDashboardContent(context),
                                    ],
                                  ),
                                ),
                        ),
                        const Footer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < ResponsiveUtils.tablet;
    final adminData = ref.watch(adminProvider);
    final user = FirebaseAuth.instance.currentUser;
    final bool isDebugMode = kDebugMode;
    final bool isLoggedIn =
        user != null && (adminData?.isAdmin ?? false) || isDebugMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and officials
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Align(
                        alignment:
                            !isMobile ? Alignment.centerLeft : Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              !isMobile
                                  ? 'Koraput Coffee Plantation'
                                  : 'Koraput Coffee Plantation At A Glance',
                              style: TextStyle(
                                fontFamily: 'Gilroy-SemiBold',
                                fontSize:
                                    ResponsiveUtils.getDashboardHeaderSize(
                                        screenWidth),
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            if (!isMobile)
                              Text(
                                'At A Glance',
                                style: TextStyle(
                                  fontFamily: 'Gilroy-SemiBold',
                                  fontSize:
                                      ResponsiveUtils.getDashboardHeaderSize(
                                              screenWidth) *
                                          0.8,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (!isMobile) const OfficialsRow(),
                  ],
                ),
              ),
            ),
            if (isMobile)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: OfficialsRow(),
                ),
              ),
            SizedBox(height: isMobile ? 10 : 30),
            // Add Dashboard Carousel
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
              child: const DashboardCarousel(),
            ),
            //const SizedBox(height: 10),
            // New Dashboard Metrics Section
            const DashboardMetrics(),
            if (isDebugMode) ...[
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: isMobile
                    ? Center(
                        child: Column(
                          children: [
                            _buildDebugButton(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.visibility,
                              label: 'View Login Credentials | App',
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text(
                                      'Login Credentials | Test User',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontFamily: 'Gilroy-SemiBold',
                                        fontSize: ResponsiveUtils.getFontSize(
                                            screenWidth, 30),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              'Username:',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-SemiBold',
                                                fontSize:
                                                    ResponsiveUtils.getFontSize(
                                                        screenWidth, 18),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'test@coffee.mapper',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize: 17,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Text(
                                              'Password:',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-SemiBold',
                                                fontSize:
                                                    ResponsiveUtils.getFontSize(
                                                        screenWidth, 18),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              'testMapper',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                            fontFamily: 'Gilroy-SemiBold',
                                            fontSize:
                                                ResponsiveUtils.getFontSize(
                                                    screenWidth, 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildDebugButton(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.android,
                              label: 'Download Development APK',
                              onPressed: () async {
                                try {
                                  // Open the APK download URL in a new tab
                                  html.window.open(
                                      'https://storage.googleapis.com/coffee-mapper-agent.firebasestorage.app/coffee_mapper_dev.apk',
                                      '_blank');
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error downloading APK: ${e.toString()}',
                                          style: TextStyle(
                                            fontFamily: 'Gilroy-Medium',
                                            color: Theme.of(context).cardColor,
                                          ),
                                        ),
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            _buildDebugButton(
                              context: context,
                              screenWidth: screenWidth,
                              icon: Icons.language,
                              label: 'View Production Website - Live',
                              onPressed: () {
                                html.window.open(
                                    'https://cdtkoraput.web.app', '_blank');
                              },
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildDebugButton(
                            context: context,
                            screenWidth: screenWidth,
                            icon: Icons.visibility,
                            label: 'App Credentials',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(
                                    'Login Credentials | Test User',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontFamily: 'Gilroy-SemiBold',
                                      fontSize: ResponsiveUtils.getFontSize(
                                          screenWidth, 30),
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Text(
                                            'Username:',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy-SemiBold',
                                              fontSize:
                                                  ResponsiveUtils.getFontSize(
                                                      screenWidth, 18),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'test@coffee.mapper',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 17,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            'Password:',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy-SemiBold',
                                              fontSize:
                                                  ResponsiveUtils.getFontSize(
                                                      screenWidth, 18),
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'testMapper',
                                            style: TextStyle(
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          fontFamily: 'Gilroy-SemiBold',
                                          fontSize: ResponsiveUtils.getFontSize(
                                              screenWidth, 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 30),
                          _buildDebugButton(
                            context: context,
                            screenWidth: screenWidth,
                            icon: Icons.android,
                            label: 'Download Development APK',
                            onPressed: () async {
                              try {
                                // Open the APK download URL in a new tab
                                html.window.open(
                                    'https://storage.googleapis.com/coffee-mapper-assets/coffee_mapper_dev.apk',
                                    '_blank');
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error downloading APK: ${e.toString()}',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy-Medium',
                                          color: Theme.of(context).cardColor,
                                        ),
                                      ),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 30),
                          _buildDebugButton(
                            context: context,
                            screenWidth: screenWidth,
                            icon: Icons.language,
                            label: 'Production Website',
                            onPressed: () {
                              html.window
                                  .open('https://cdtkoraput.web.app', '_blank');
                            },
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 30),
            ],
            // Show sensitive components only when logged in
            if (isLoggedIn) ...[
              const MetricsOverview(),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: const ShadeHighlightsSection(),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: const CoffeeHighlightsSection(),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: const MapOverviewSection(),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
                child: const NurseryHighlightsSection(),
              ),
              const SizedBox(height: 30),
            ],
            // Padding(
            //   padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20),
            //   child: const LegacyHighlightsSection(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugButton({
    required BuildContext context,
    required double screenWidth,
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final bool isMobile = screenWidth < ResponsiveUtils.tablet;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: isMobile ? 15 : 18,
        ),
      ),
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: Theme.of(context).cardColor,
        size: 28,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Gilroy-Medium',
          fontSize: ResponsiveUtils.getFontSize(screenWidth, 16),
          color: Theme.of(context).cardColor,
        ),
      ),
    );
  }
}
