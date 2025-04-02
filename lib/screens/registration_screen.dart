import 'package:coffee_mapper_web/providers/admin_provider.dart';
import 'package:coffee_mapper_web/screens/dashboard_screen.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/forms/farmer_application/farmer_form_dialog.dart';
import 'package:coffee_mapper_web/widgets/layout/footer.dart';
import 'package:coffee_mapper_web/widgets/layout/header.dart';
import 'package:coffee_mapper_web/widgets/layout/officials_row.dart';
import 'package:coffee_mapper_web/widgets/layout/side_menu.dart';
import 'package:coffee_mapper_web/widgets/tables/beneficiary_highlights/beneficiary_highlight_section.dart';
import 'package:coffee_mapper_web/widgets/tables/legacy_highlights/legacy_highlights_section.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:web/web.dart' as web;

class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  Future<void> _downloadPDF(BuildContext context) async {
    try {
      if (kIsWeb) {
        // For web, create an anchor element and trigger download
        final anchor = web.HTMLAnchorElement()
          ..href = 'assets/assets/docs/farmerApplication.pdf'
          ..setAttribute('download', 'Application Form.pdf')
          ..style.display = 'none';

        web.document.body!.appendChild(anchor);
        anchor.click();
        web.document.body!.removeChild(anchor);
      } else {
        // For non-web platforms, use url_launcher
        final Uri uri = Uri.parse('/assets/docs/farmerApplication.pdf');
        if (!await url_launcher.launchUrl(
          uri,
          mode: url_launcher.LaunchMode.externalApplication,
        )) {
          throw Exception('Could not open PDF');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Theme.of(context).cardColor),
                const SizedBox(width: 8),
                const Text('Error downloading PDF. Please try again later.'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showFormDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FarmerFormDialog(),
    );
  }

  Widget _buildHelpText(BuildContext context, double screenWidth) {
    return Text(
      'If you face trouble submitting through the online form, please download the form by clicking the above button and fill it up, scan and send to lorem.ipsum@gmail.com.',
      style: TextStyle(
        fontFamily: 'Gilroy-Medium',
        fontSize: ResponsiveUtils.getFontSize(screenWidth, 14),
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }

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
                                // Title section with back button and officials
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
                                                'Beneficiary Application Section',
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
                                const SizedBox(height: 40),
                                // Farmer Application Section
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isMobile ? 10 : 20,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Beneficiary Application',
                                        style: TextStyle(
                                          fontFamily: 'Gilroy-SemiBold',
                                          fontSize: ResponsiveUtils.getFontSize(
                                              screenWidth, 23),
                                          color:
                                              Theme.of(context).highlightColor,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        crossAxisAlignment:
                                            (!isTablet && !isMobile)
                                                ? CrossAxisAlignment.center
                                                : CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            (!isTablet && !isMobile)
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                        children: [
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _showFormDialog(context),
                                            icon: Icon(
                                              Icons.edit_document,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                            label: Text(
                                              'Fill Form Now',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize:
                                                    ResponsiveUtils.getFontSize(
                                                  screenWidth,
                                                  16,
                                                ),
                                                color:
                                                    Theme.of(context).cardColor,
                                              ),
                                            ),
                                          ),
                                          if (!isMobile) ...[
                                            const SizedBox(width: 20),
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .error,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 15,
                                                ),
                                              ),
                                              onPressed: () =>
                                                  _downloadPDF(context),
                                              icon: Icon(
                                                Icons.download,
                                                color:
                                                    Theme.of(context).cardColor,
                                              ),
                                              label: Text(
                                                'Download Form in PDF Format',
                                                style: TextStyle(
                                                  fontFamily: 'Gilroy-Medium',
                                                  fontSize: ResponsiveUtils
                                                      .getFontSize(
                                                    screenWidth,
                                                    16,
                                                  ),
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (!isTablet && !isMobile) ...[
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: _buildHelpText(
                                                context,
                                                screenWidth,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (isTablet || isMobile) ...[
                                        if (isMobile) ...[
                                          const SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 20,
                                                vertical: 15,
                                              ),
                                            ),
                                            onPressed: () =>
                                                _downloadPDF(context),
                                            icon: Icon(
                                              Icons.download,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                            label: Text(
                                              'Download Form in PDF Format',
                                              style: TextStyle(
                                                fontFamily: 'Gilroy-Medium',
                                                fontSize:
                                                    ResponsiveUtils.getFontSize(
                                                  screenWidth,
                                                  16,
                                                ),
                                                color:
                                                    Theme.of(context).cardColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        _buildHelpText(context, screenWidth),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 30),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: const LegacyHighlightsSection(),
                                ),
                                // Beneficiary table section with login check
                                if (isLoggedIn) ...[
                                  SizedBox(
                                    height: 450,
                                    child: BeneficiaryHighlightSection(
                                      isLoggedIn: isLoggedIn,
                                    ),
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
