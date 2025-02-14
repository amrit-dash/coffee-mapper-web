import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/widgets/layout/header.dart';
import 'package:coffee_mapper_web/widgets/layout/side_menu.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/layout/officials_row.dart';
import 'package:coffee_mapper_web/widgets/layout/metrics_overview.dart';
import 'package:coffee_mapper_web/widgets/tables/shade_highlights/shade_highlights_section.dart';
import 'package:coffee_mapper_web/widgets/tables/coffee_highlights/coffee_highlights_section.dart';
import 'package:coffee_mapper_web/widgets/tables/nursery_highlights/nursery_highlights_section.dart';
import 'package:coffee_mapper_web/widgets/map/map_overview_section.dart';
import 'package:coffee_mapper_web/widgets/layout/dashboard_metrics.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Only show SideMenu if not in mobile view
                  if (!isMobileView) const SideMenu(),
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).highlightColor,
                            ),
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.all(isMobileView ? 16 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDashboardContent(context),
                              ],
                            ),
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
            const SizedBox(height: 20),
            // New Dashboard Metrics Section
            const DashboardMetrics(),
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
          ],
        ),
      ),
    );
  }
}
