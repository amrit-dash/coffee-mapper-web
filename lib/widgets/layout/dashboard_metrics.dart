import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/models/dashboard_metrics_data.dart';
import 'package:coffee_mapper_web/services/dashboard_service.dart';
import 'package:coffee_mapper_web/widgets/dialogs/interactive_chart_dialog.dart';

class DashboardMetrics extends StatefulWidget {
  const DashboardMetrics({super.key});

  @override
  State<DashboardMetrics> createState() => _DashboardMetricsState();
}

class _DashboardMetricsState extends State<DashboardMetrics> {
  final DashboardService _dashboardService = DashboardService();
  bool _isLoading = true;
  final Map<String, bool> _imageLoadStates = {};
  DashboardMetricsData? _metricsData;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final data = await _dashboardService.getDashboardMetrics();
      if (!mounted) return;
      setState(() {
        _metricsData = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _metricsData = DashboardMetricsData.fallbackData;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);
    final shouldStack = isMobile || (isTablet && screenWidth < 1100);

    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 10 : 20),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = _metricsData ?? DashboardMetricsData.fallbackData;

    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 20),
      child: shouldStack
          ? Column(
              children: [
                SizedBox(
                  height: 200,
                  child: _buildMetricsGrid(context, data),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 2.5,
                  child: _buildGraph(
                    context,
                    data.chart1URL,
                    'Farmer Metrics',
                  ),
                ),
                const SizedBox(height: 20),
                AspectRatio(
                  aspectRatio: 2.5,
                  child: _buildGraph(
                    context,
                    data.chart2URL,
                    'Plantation Land Metrics',
                  ),
                ),
              ],
            )
          : SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildMetricsGrid(context, data),
                  ),
                  const SizedBox(width: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.170,
                        child: AspectRatio(
                          aspectRatio: 2.5,
                          child: _buildGraph(
                            context,
                            data.chart1URL,
                            'Farmer Metrics',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.195,
                        child: AspectRatio(
                          aspectRatio: 2.5,
                          child: _buildGraph(
                            context,
                            data.chart2URL,
                            'Plantation Land Metrics',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGraph(BuildContext context, String imageUrl, String title) {
    // Convert image URL to interactive URL by replacing 'format=image' with 'format=interactive'
    final interactiveUrl =
        imageUrl.replaceAll('format=image', 'format=interactive');

    return InkWell(
      highlightColor: Colors.transparent,
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) => InteractiveChartDialog(
            chartUrl: interactiveUrl,
            title: title,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Theme.of(context).highlightColor,
            width: 0.4,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  _imageLoadStates[imageUrl] = false;
                  return Center(
                    child: Text(
                      'Failed to load chart',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() {
                          _imageLoadStates[imageUrl] = true;
                        });
                      }
                    });
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).highlightColor,
                    ),
                  );
                },
              ),
            ),
            if (_imageLoadStates[imageUrl] == true)
              Positioned(
                right: 10,
                top: 10,
                child: Tooltip(
                  message: 'Open Interactive View',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withAlpha(255),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.ads_click,
                      size: 15,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, DashboardMetricsData data) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isMobile ? 4 : 6,
                    bottom: isMobile ? 4 : 6,
                  ),
                  child: _buildMetricCard(
                    context,
                    'Coffee Plantation\n(Bearing Area)',
                    data.bearingArea.toString(),
                    'ha',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isMobile ? 4 : 6,
                    bottom: isMobile ? 4 : 6,
                  ),
                  child: _buildMetricCard(
                    context,
                    'Coffee Plantation\n(Non-Bearing Area)',
                    data.nonBearingArea.toString(),
                    'ha',
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: isMobile ? 4 : 6,
                    top: isMobile ? 4 : 6,
                  ),
                  child: _buildMetricCard(
                    context,
                    'Total Coffee Plantation Area',
                    data.totalArea.toString(),
                    'ha',
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: isMobile ? 4 : 6,
                    top: isMobile ? 4 : 6,
                  ),
                  child: _buildMetricCard(
                    context,
                    'Number of Farmers',
                    data.totalFarmers.toString(),
                    '',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      BuildContext context, String title, String value, String unit) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    // Adjusted font sizes
    final titleSize = isMobile ? 13.0 : (isTablet ? 13.0 : 13.0);
    final valueSize = isMobile ? 22.0 : (isTablet ? 23.0 : 24.0);
    final unitSize = isMobile ? 20.0 : (isTablet ? 20.0 : 22.0);

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).highlightColor,
          width: 0.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                fontSize: titleSize,
                color: Theme.of(context).highlightColor,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontFamily: 'Gilroy-SemiBold',
                      fontSize: valueSize,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontFamily: 'Gilroy-SemiBold',
                      fontSize: unitSize,
                      color: Theme.of(context).colorScheme.secondary,
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
}
