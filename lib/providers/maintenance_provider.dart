import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side default copy, used until the maintenance document supplies its own.
const String _defaultTitle = 'Service Temporarily Unavailable';
const String _defaultMessage =
    'This service is currently undergoing maintenance. Please check back later.';

const String _docPath = 'appControl/maintenance';

const String _prefEnabled = 'maintenance_enabled';
const String _prefTitle = 'maintenance_title';
const String _prefMessage = 'maintenance_message';

/// Immutable snapshot of the remote maintenance flag.
class MaintenanceState {
  final bool enabled;
  final String title;
  final String message;

  /// Whether the flag has been resolved at least once (from local storage or
  /// Firestore). The gate shows a neutral holding screen until this is true so
  /// a cold online launch never flashes the app before the flag lands.
  final bool initialized;

  const MaintenanceState({
    required this.enabled,
    required this.title,
    required this.message,
    required this.initialized,
  });

  const MaintenanceState.initial()
      : enabled = false,
        title = _defaultTitle,
        message = _defaultMessage,
        initialized = false;

  MaintenanceState copyWith({
    bool? enabled,
    String? title,
    String? message,
    bool? initialized,
  }) {
    return MaintenanceState(
      enabled: enabled ?? this.enabled,
      title: title ?? this.title,
      message: message ?? this.message,
      initialized: initialized ?? this.initialized,
    );
  }
}

/// Resolves a remotely-controlled maintenance wall for the web dashboard.
///
/// Read-only: the wall is toggled from the Firebase console (the shared
/// `appControl/maintenance` document is publicly readable, admin-writable), so
/// this client never needs an allowlist or in-app toggle.
///
/// Fail-closed persistence: a device that has ever seen `enabled == true` stays
/// walled across reloads and offline. The wall lifts only on an authoritative
/// read delivering `enabled == false` (or a missing document). A failed or
/// timed-out read never lifts it.
class MaintenanceNotifier extends StateNotifier<MaintenanceState> {
  MaintenanceNotifier() : super(const MaintenanceState.initial());

  final _log = Logger('MaintenanceNotifier');

  bool _started = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _subscription;

  /// Idempotent — safe to call on every rebuild. Loads persisted state first
  /// (so a previously-walled device is walled instantly, offline), then does one
  /// authoritative read, then subscribes to live updates.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    await _loadPersisted();

    final docRef = FirebaseFirestore.instance.doc(_docPath);

    try {
      final snapshot = await docRef.get().timeout(const Duration(seconds: 8));
      await _applySnapshot(snapshot);
    } catch (e) {
      // Never fail open: keep the sticky state on failure or timeout.
      _log.warning('Authoritative maintenance read failed; keeping sticky state: $e');
    }

    _subscription = docRef.snapshots().listen(
      _applySnapshot,
      onError: (Object e) => _log.warning('Maintenance listener error: $e'),
    );
  }

  Future<void> _loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = state.copyWith(
        enabled: prefs.getBool(_prefEnabled) ?? false,
        title: prefs.getString(_prefTitle) ?? state.title,
        message: prefs.getString(_prefMessage) ?? state.message,
        initialized: true,
      );
    } catch (e) {
      _log.warning('Failed to load persisted maintenance state: $e');
      // Nothing to be sticky about yet; default to not-walled but resolved so
      // the holding screen does not trap the user.
      state = state.copyWith(initialized: true);
    }
  }

  Future<void> _applySnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final data = snapshot.data();

    // Missing document is an authoritative "no maintenance".
    if (!snapshot.exists || data == null) {
      state = state.copyWith(enabled: false, initialized: true);
      await _persist();
      return;
    }

    final rawEnabled = data['enabled'];
    final enabled = rawEnabled is bool ? rawEnabled : false;

    final rawTitle = data['title'];
    final title = (rawTitle is String && rawTitle.trim().isNotEmpty)
        ? rawTitle
        : state.title;

    final rawMessage = data['message'];
    final message = (rawMessage is String && rawMessage.trim().isNotEmpty)
        ? rawMessage
        : state.message;

    state = state.copyWith(
      enabled: enabled,
      title: title,
      message: message,
      initialized: true,
    );
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabled, state.enabled);
      await prefs.setString(_prefTitle, state.title);
      await prefs.setString(_prefMessage, state.message);
    } catch (e) {
      _log.warning('Failed to persist maintenance state: $e');
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final maintenanceProvider =
    StateNotifierProvider<MaintenanceNotifier, MaintenanceState>((ref) {
  return MaintenanceNotifier();
});
