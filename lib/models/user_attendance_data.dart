class UserAttendanceData {
  final String uid;
  final String name;
  final String email;
  final String lastLogin;
  final List<String> allocatedPanchayats;
  final Map<String, double?> dailyDurations;
  final Map<String, Map<String, dynamic>?> rawCheckInData;
  final Map<String, Map<String, dynamic>?> rawCheckOutData;

  UserAttendanceData({
    required this.uid,
    required this.name,
    required this.email,
    required this.lastLogin,
    required this.allocatedPanchayats,
    required this.dailyDurations,
    required this.rawCheckInData,
    required this.rawCheckOutData,
  });
}
