import 'package:cloud_firestore/cloud_firestore.dart';

class GrievanceData {
  String? id;
  String name;
  String phone;
  String? email;
  String grievance;
  String ticketID;
  DateTime submittedOn;
  String status;

  GrievanceData({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.grievance,
    required this.ticketID,
    required this.submittedOn,
    this.status = 'active',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'grievance': grievance,
      'ticketID': ticketID,
      'submittedOn': Timestamp.fromDate(submittedOn),
      'status': status,
    };
  }

  factory GrievanceData.fromJson(Map<String, dynamic> json) {
    return GrievanceData(
      id: json['id'] as String?,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      grievance: json['grievance'] as String,
      ticketID: json['ticketID'] as String,
      submittedOn: (json['submittedOn'] as Timestamp).toDate(),
      status: json['status'] as String? ?? 'active',
    );
  }
}
