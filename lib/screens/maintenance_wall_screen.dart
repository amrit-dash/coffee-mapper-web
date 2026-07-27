import 'package:flutter/material.dart';

/// Full-screen, non-dismissable suspension notice.
///
/// Purely informational: no app bar, no back affordance, no navigation. It sits
/// above the root navigator (see [MaintenanceGate]) so it has no navigator
/// context of its own.
class MaintenanceWallScreen extends StatelessWidget {
  final String title;
  final String message;

  const MaintenanceWallScreen({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF402200);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 96,
                  color: Theme.of(context).highlightColor,
                ),
                const SizedBox(height: 32),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-SemiBold',
                    fontSize: 30,
                    height: 1.15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: 16,
                    height: 1.45,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
