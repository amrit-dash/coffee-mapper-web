import 'package:coffee_mapper_web/providers/admin_provider.dart';
import 'package:coffee_mapper_web/screens/dashboard_screen.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/layout/footer.dart';
import 'package:coffee_mapper_web/widgets/layout/header.dart';
import 'package:coffee_mapper_web/widgets/layout/officials_row.dart';
import 'package:coffee_mapper_web/widgets/layout/side_menu.dart';
import 'package:coffee_mapper_web/widgets/tables/attendance_highlights/attendance_highlight_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);
    final isTablet = ResponsiveUtils.isTablet(screenWidth);
    final adminData = ref.watch(adminProvider);
    final user = FirebaseAuth.instance.currentUser;
    final bool isLoggedIn = user != null && (adminData?.isAdmin ?? false);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            const Header(),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isMobile) const SideMenu(renderDashboard: true),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(isMobile ? 16 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons
                                                    .arrow_circle_left_outlined,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                                size: isTablet ? 24 : 32,
                                              ),
                                              tooltip: 'Back to Dashboard',
                                              onPressed: () {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const DashboardScreen(),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Attendance Dashboard',
                                                style: TextStyle(
                                                  fontFamily: 'Gilroy-SemiBold',
                                                  fontSize: ResponsiveUtils
                                                      .getDashboardHeaderSize(
                                                          screenWidth),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isTablet && !isMobile)
                                        const OfficialsRow(),
                                    ],
                                  ),
                                ),
                                if (isMobile)
                                  const Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10),
                                      child: OfficialsRow(),
                                    ),
                                  ),
                                SizedBox(height: (isMobile) ? 5 : 10 ),
                                if (adminData == null) ...[
                                  SizedBox(
                                    height: ResponsiveUtils.getTableContainerHeight(screenWidth),
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                ] else if (isLoggedIn) ...[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.7,
                                    child: const AttendanceHighlightSection(),
                                  ),
                                ] else ...[
                                  const Center(
                                    child: Text('Access Denied. Admins only.'),
                                  ),
                                ],
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
}