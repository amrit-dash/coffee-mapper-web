import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coffee_mapper_web/screens/login_screen.dart';
import 'package:coffee_mapper_web/screens/dashboard_screen.dart';
import 'package:coffee_mapper_web/screens/registration_screen.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:coffee_mapper_web/providers/admin_provider.dart';
import 'package:coffee_mapper_web/providers/news_provider.dart';
import 'package:coffee_mapper_web/widgets/layout/news_scroll_view.dart';
import 'package:coffee_mapper_web/widgets/dialogs/sidebar_image_card.dart';
import 'package:coffee_mapper_web/config/firebase_config.dart';
import 'package:coffee_mapper_web/widgets/dialogs/grievance_form_dialog.dart';

class SideMenu extends ConsumerStatefulWidget {
  final bool isLoginScreen;
  final bool renderDashboard;

  const SideMenu({
    super.key,
    this.isLoginScreen = false,
    this.renderDashboard = false,
  });

  @override
  ConsumerState<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends ConsumerState<SideMenu> {
  @override
  void initState() {
    super.initState();
    // Fetch news from dashboardData collection
    Future.microtask(() {
      ref.read(dashboardNewsProvider.notifier).fetchNews();
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await url_launcher.launchUrl(uri,
        mode: url_launcher.LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final sideMenuWidth = ResponsiveUtils.getSideMenuWidth(screenWidth);

    // Only show sidebar image card if screen height is sufficient
    final bool showSidebarImageCard = screenHeight > 500;

    // Only show sidebar menu items if screen height is sufficient
    final bool showSidebarMenuItems = screenHeight > 600;

    // Adjust spacing based on available height
    final double topPadding = screenHeight < 700 ? 10 : 20;
    final double sectionSpacing = screenHeight < 700 ? 10 : 20;

    // Only render if not mobile
    if (ResponsiveUtils.isMobile(screenWidth)) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final adminData = ref.watch(adminProvider);

        // Check admin status if user changes or admin data is null
        if (user != null && adminData == null) {
          Future.microtask(() {
            ref.read(adminProvider.notifier).checkAdminStatus(user.email);
          });
        } else if (user == null && adminData != null) {
          Future.microtask(() {
            ref.read(adminProvider.notifier).clearAdminData();
          });
        }

        final bool isLoggedIn = user != null && (adminData?.isAdmin ?? false);
        final String? adminName = adminData?.name;

        return Container(
          width: sideMenuWidth,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: topPadding),
              // User Welcome Section
              Container(
                padding: const EdgeInsets.only(left: 20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(
                        fontFamily: 'Gilroy-SemiBold',
                        fontSize: screenHeight < 700 ? 20 : 24,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isLoggedIn ? (adminName ?? 'Admin') : 'Coffee Mapper',
                      style: TextStyle(
                        fontFamily: 'Gilroy-Medium',
                        fontSize: screenHeight < 700 ? 16 : 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: sectionSpacing),
              // News Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Events',
                        style: TextStyle(
                          fontFamily: 'Gilroy-SemiBold',
                          fontSize: screenHeight < 700 ? 17 : 19,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: screenHeight < 700 ? 5 : 10),
                      Flexible(
                        flex: 2,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: screenHeight * 0.3,
                            minHeight: screenHeight * 0.15,
                          ),
                          child: const NewsScrollView(),
                        ),
                      ),
                      if (showSidebarImageCard) ...[
                        SizedBox(height: screenHeight < 700 ? 15 : 20),
                        const SidebarImageCard(),
                      ],
                    ],
                  ),
                ),
              ),
              // Bottom Buttons
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenHeight < 700 ? 10 : 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showSidebarMenuItems) ...[
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          'Citizen Services',
                          style: TextStyle(
                            fontFamily: 'Gilroy-SemiBold',
                            fontSize: screenHeight < 700 ? 13 : 15,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight < 700 ? 1 : 2),
                      //Show menu buttons for Beneficiery Registration and Grievance Submission
                      _buildMenuButton(
                        context,
                        icon: Icons.group,
                        title: 'Beneficiary Application',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const RegistrationScreen()),
                          );
                        },
                      ),
                      SizedBox(height: screenHeight < 700 ? 2 : 5),
                      _buildMenuButton(
                        context,
                        icon: Icons.error_outline_rounded,
                        title: 'Grievance Submission',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const GrievanceFormDialog(),
                          );
                        },
                      ),
                      // Show Dashboard button if renderDashboard is true
                      if (widget.renderDashboard) ...[
                        SizedBox(height: screenHeight < 700 ? 2 : 5),
                        _buildMenuButton(
                          context,
                          icon: Icons.dashboard,
                          title: 'Back to Dashboard',
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DashboardScreen()),
                            );
                          },
                        ),
                      ],

                      // Only show management buttons when logged in
                      if (isLoggedIn) ...[
                        SizedBox(height: screenHeight < 700 ? 5 : 7),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Text(
                            'Admin Services',
                            style: TextStyle(
                              fontFamily: 'Gilroy-SemiBold',
                              fontSize: screenHeight < 700 ? 13 : 15,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight < 700 ? 1 : 2),
                        _buildMenuButton(
                          context,
                          icon: Icons.manage_accounts,
                          title: 'User Management',
                          onPressed: () {
                            final userManagementUrl = FirebaseConfig
                                        .currentEnvironment ==
                                    Environment.production
                                ? 'https://docs.google.com/spreadsheets/d/1t8_HWGn2GdFZaciL85cwkyiQq59v96KC9FJe5WehGY8/edit?gid=525463354'
                                : 'https://docs.google.com/spreadsheets/d/14L-OnlOCy4_S7bU6jnpwVD3QiHu5TsruZ-M-YYg0hbY/edit?gid=525463354';
                            _launchUrl(userManagementUrl);
                          },
                        ),
                        SizedBox(height: screenHeight < 700 ? 2 : 5),
                        _buildMenuButton(
                          context,
                          icon: Icons.settings,
                          title: 'System Configuration',
                          onPressed: () {
                            final configUrl = FirebaseConfig
                                        .currentEnvironment ==
                                    Environment.production
                                ? 'https://docs.google.com/spreadsheets/d/1t8_HWGn2GdFZaciL85cwkyiQq59v96KC9FJe5WehGY8/edit'
                                : 'https://docs.google.com/spreadsheets/d/14L-OnlOCy4_S7bU6jnpwVD3QiHu5TsruZ-M-YYg0hbY/edit';
                            _launchUrl(configUrl);
                          },
                        ),
                      ],
                      SizedBox(height: screenHeight < 700 ? 5 : 10),
                    ],
                  ],
                ),
              ),
              // Show appropriate navigation button based on current screen
              if (widget.isLoginScreen)
                _buildDashboardButton(context)
              else
                isLoggedIn
                    ? _buildLogoutButton(context)
                    : _buildLoginButton(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDashboardButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(),
          alignment: Alignment.center,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        },
        icon: Icon(
          Icons.dashboard,
          color: Theme.of(context).colorScheme.error,
        ),
        label: Text(
          'Back to Dashboard',
          style: TextStyle(
            fontFamily: 'Gilroy-SemiBold',
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Gilroy-Medium',
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(),
          alignment: Alignment.center,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => LoginScreen(
                returnScreen: widget.isLoginScreen
                    ? const DashboardScreen()
                    : (widget.renderDashboard
                        ? const RegistrationScreen()
                        : const DashboardScreen()),
              ),
            ),
          );
        },
        icon: Icon(
          Icons.login,
          color: Theme.of(context).colorScheme.error,
        ),
        label: Text(
          'Admin Log In',
          style: TextStyle(
            fontFamily: 'Gilroy-SemiBold',
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(),
          alignment: Alignment.center,
        ),
        onPressed: () async {
          try {
            await FirebaseAuth.instance.signOut();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Error logging out')),
              );
            }
          }
        },
        icon: Icon(
          Icons.logout,
          color: Theme.of(context).cardColor,
        ),
        label: Text(
          'Log Out',
          style: TextStyle(
            fontFamily: 'Gilroy-SemiBold',
            color: Theme.of(context).cardColor,
          ),
        ),
      ),
    );
  }
}
