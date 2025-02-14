import 'package:flutter/material.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    return Container(
      width: screenWidth,
      color: Theme.of(context).colorScheme.primary,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : ResponsiveUtils.getPadding(screenWidth),
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left section with logo and department name
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo/logo-white.png',
                  height:
                      ResponsiveUtils.getLogoHeight(screenWidth, screenHeight) *
                          0.8,
                ),
                SizedBox(width: isMobile ? 8 : screenWidth * 0.02),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Coffee Developement Trust, Koraput',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          fontSize: isMobile
                              ? 16
                              : ResponsiveUtils.getFontSize(screenWidth, 20),
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Government of Odisha',
                        style: TextStyle(
                          fontFamily: 'Gilroy-Medium',
                          fontSize: isMobile
                              ? 14
                              : ResponsiveUtils.getFontSize(screenWidth, 16),
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).cardColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right section with CM details
          if (!isMobile)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Shri Mohan Charan Majhi',
                      style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        fontSize: ResponsiveUtils.getFontSize(screenWidth, 17),
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    Text(
                      'Hon\'ble Chief Minister',
                      style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        fontSize: ResponsiveUtils.getFontSize(screenWidth, 14),
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: screenWidth * 0.02),
                Image.asset(
                  'assets/images/CM.png',
                  height:
                      ResponsiveUtils.getLogoHeight(screenWidth, screenHeight) *
                          0.8,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
