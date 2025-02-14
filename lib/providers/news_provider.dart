import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardNews {
  final List<String> newsItems;

  DashboardNews({required this.newsItems});

  factory DashboardNews.empty() {
    return DashboardNews(newsItems: []);
  }

  factory DashboardNews.fromFirestore(Map<String, dynamic> data) {
    final List<String> items = [];

    // Check if currentEventsNews exists and is a list
    if (data.containsKey('currentEventsNews') &&
        data['currentEventsNews'] is List) {
      final List<dynamic> newsData = data['currentEventsNews'] as List<dynamic>;
      items.addAll(newsData.map((item) => item.toString()));
    }

    return DashboardNews(newsItems: items);
  }
}

class DashboardNewsNotifier extends StateNotifier<DashboardNews> {
  DashboardNewsNotifier() : super(DashboardNews.empty());

  Future<void> fetchNews() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('appData')
          .doc('dashboardData')
          .get();

      if (doc.exists && doc.data() != null) {
        state = DashboardNews.fromFirestore(doc.data()!);
      }
    } catch (e) {
      // Silently handle error and keep empty state
    }
  }
}

final dashboardNewsProvider =
    StateNotifierProvider<DashboardNewsNotifier, DashboardNews>((ref) {
  return DashboardNewsNotifier();
});

// Provider to track if sidebar image has been animated
final sidebarImageAnimatedProvider = StateProvider<bool>((ref) => false);
