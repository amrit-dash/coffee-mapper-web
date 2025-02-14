import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/utils/area_formatter.dart';
import 'package:coffee_mapper_web/services/coffee_service.dart';
import 'package:coffee_mapper_web/services/shade_service.dart';
import 'package:coffee_mapper_web/models/coffee_data.dart';
import 'package:coffee_mapper_web/models/shade_data.dart';
import 'package:rxdart/rxdart.dart';

class MetricsOverview extends StatefulWidget {
  const MetricsOverview({super.key});

  @override
  State<MetricsOverview> createState() => _MetricsOverviewState();
}

class _MetricsOverviewState extends State<MetricsOverview> {
  final CoffeeService _coffeeService = CoffeeService();
  final ShadeService _shadeService = ShadeService();
  
  late Stream<List<ShadeData>> _shadeStream;
  late Stream<List<CoffeeData>> _coffeeStream;

  @override
  void initState() {
    super.initState();
    _shadeStream = _shadeService.getShadeDataStream();
    _coffeeStream = _coffeeService.getCoffeeDataStream();
  }

  String _getLatestActivityDate(List<dynamic> data) {
    if (data.isEmpty) return 'No activity yet';
    // Sort by dateUpdated in descending order
    data.sort((a, b) => b.dateUpdated.compareTo(a.dateUpdated));
    return data.first.dateUpdated;
  }

  double _calculateTotalArea(List<dynamic> data) {
    return data.fold(0.0, (sum, item) => sum + item.area);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);

    // Calculate dynamic card width
    double cardWidth;
    if (isMobile) {
      cardWidth = (screenWidth * 0.8) / 2;  // 2 cards per row
    } else if (isTablet) {
      cardWidth = (screenWidth * 0.6) / 2;  // 2 cards per row
    } else {
      cardWidth = (screenWidth * 0.7) / 4;  // 4 cards per row
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 20),
          child: Align(
            alignment: (isMobile || isTablet) ? Alignment.center : Alignment.centerLeft,
            child: Text(
              'Ongoing Coffee Mapper Progress',
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                fontSize: ResponsiveUtils.getFontSize(screenWidth, isMobile ? 22 : 21),
                color: Theme.of(context).highlightColor,
              ),
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.all(isMobile ? 10 : 20),
          child: StreamBuilder<List<List<dynamic>>>(
            stream: Rx.combineLatest2(
              _shadeStream,
              _coffeeStream,
              (List<ShadeData> shadeData, List<CoffeeData> coffeeData) => [shadeData, coffeeData]
            ),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final shadeData = snapshot.data![0] as List<ShadeData>;
              final coffeeData = snapshot.data![1] as List<CoffeeData>;

              return Center(
                child: Wrap(
                  spacing: isMobile ? 10 : 20,
                  runSpacing: isMobile ? 10 : 20,
                  alignment: WrapAlignment.start,
                  children: [
                    _buildMetricCard(
                      context, 
                      'Total Shade Plantations', 
                      shadeData.length.toString(), 
                      'Last Activity: ${_getLatestActivityDate(shadeData)}', 
                      cardWidth
                    ),
                    _buildMetricCard(
                      context, 
                      'Total Coffee Plantations', 
                      coffeeData.length.toString(), 
                      'Last Activity: ${_getLatestActivityDate(coffeeData)}', 
                      cardWidth
                    ),
                    _buildMetricCard(
                      context, 
                      'Area of Shade Plantations', 
                      AreaFormatter.formatArea(_calculateTotalArea(shadeData)), 
                      'Over ${shadeData.length} Shade Plantations', 
                      cardWidth,
                      tooltip: AreaFormatter.getAreaTooltip(_calculateTotalArea(shadeData))
                    ),
                    _buildMetricCard(
                      context, 
                      'Area of Coffee Plantations', 
                      AreaFormatter.formatArea(_calculateTotalArea(coffeeData)), 
                      'Over ${coffeeData.length} Coffee Plantations', 
                      cardWidth,
                      tooltip: AreaFormatter.getAreaTooltip(_calculateTotalArea(coffeeData))
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, String subtitle, double width, {String? tooltip}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    Widget valueWidget = Text(
      value,
      style: TextStyle(
        fontFamily: 'Gilroy-SemiBold',
        fontSize: ResponsiveUtils.getFontSize(screenWidth, isMobile ? 26 : 24),
        color: Theme.of(context).colorScheme.error,
      ),
    );

    if (tooltip != null) {
      valueWidget = Tooltip(
        message: tooltip,
        child: valueWidget,
      );
    }

    return Container(
      width: width,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withAlpha(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Gilroy-SemiBold',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, isMobile ? 16 : 14),
              color: Theme.of(context).highlightColor,
            ),
          ),
          const SizedBox(height: 8),
          valueWidget,
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: isMobile ? 'Gilroy-SemiBold' : 'Gilroy-Medium',
              fontSize: ResponsiveUtils.getFontSize(screenWidth, isMobile ? 12 : 12),
              color: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
} 