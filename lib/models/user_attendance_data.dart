class UserAttendanceData {
  final String uid;
  final String name;
  final String email;
  final String lastLogin;
  final String allocatedPanchayat;
  final Map<String, double?> dailyDurations; 
  final Map<String, Map<String, dynamic>?> rawCheckInData; 
  final Map<String, Map<String, dynamic>?> rawCheckOutData; 

  UserAttendanceData({
    required this.uid,
    required this.name,
    required this.email,
    required this.lastLogin,
    required this.allocatedPanchayat,
    required this.dailyDurations,
    required this.rawCheckInData,
    required this.rawCheckOutData,
  });
}
