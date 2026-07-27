import 'dart:async';

import 'package:coffee_mapper_web/providers/maintenance_provider.dart';
import 'package:coffee_mapper_web/screens/maintenance_wall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// The choke point for the maintenance wall.
///
/// Mounted above the root navigator via `MaterialApp.builder`, so it covers
/// every route and does not rebuild on route changes.
///
/// Critical invariant: the app subtree is ALWAYS kept mounted. The wall and the
/// holding screen render as overlays stacked on top of it, never as
/// replacements — the app subtree contains the bootstrap chain that resolves
/// the flag, so unmounting it would deadlock resolution.
class MaintenanceGate extends ConsumerStatefulWidget {
  final Widget child;

  const MaintenanceGate({super.key, required this.child});

  @override
  ConsumerState<MaintenanceGate> createState() => _MaintenanceGateState();
}

class _MaintenanceGateState extends ConsumerState<MaintenanceGate> {
  /// Stable key so switching between the pass-through and overlay branches
  /// reparents the app subtree instead of rebuilding it — preserving app state
  /// and never killing an in-flight bootstrap.
  final GlobalKey _appKey = GlobalKey();

  /// Safety valve: the hold normally clears in milliseconds (right after the
  /// local storage read flips `initialized`). This timer only fires if the
  /// resolution chain breaks, so a user is never trapped on the logo forever.
  /// It does NOT suppress the wall — that is a separate branch gated on real,
  /// resolved data.
  bool _holdTimedOut = false;
  Timer? _holdTimer;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget; idempotent so extra calls are harmless.
    ref.read(maintenanceProvider.notifier).start();
    _holdTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _holdTimedOut = true);
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maintenance = ref.watch(maintenanceProvider);

    Widget? overlay;
    if (!maintenance.initialized && !_holdTimedOut) {
      overlay = const _HoldingScreen();
    } else if (maintenance.initialized && maintenance.enabled) {
      overlay = MaintenanceWallScreen(
        title: maintenance.title,
        message: maintenance.message,
      );
    }

    return Stack(
      children: [
        KeyedSubtree(key: _appKey, child: widget.child),
        if (overlay != null)
          // Opaque hit-testing so taps in empty regions are absorbed rather
          // than falling through to the live app underneath. Child widgets
          // (e.g. the wall's scroll view) still receive their own gestures.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: overlay,
            ),
          ),
      ],
    );
  }
}

/// Neutral placeholder shown while the flag resolves. Plain scaffold with the
/// logo centered at ~85% of screen width.
class _HoldingScreen extends StatelessWidget {
  const _HoldingScreen();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SvgPicture.asset(
          'assets/logo/logo.svg',
          width: width * 0.85,
        ),
      ),
    );
  }
}
