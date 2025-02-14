import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerFormData {
  String? id;
  String? name;
  String? careOfName;
  String? classType;

  // Address Details
  String? district;
  String? block;
  String? panchayat;
  String? village;
  String? post;
  String? policeStation;
  String? mobileNumber;

  // Land Details
  double? landSize;
  String? landCategory;
  String? khataNumber;
  String? plotNumber;
  String? mauja;

  // Bank Details
  String? aadharNumber;
  String? bankAccountNumber;
  String? bankName;
  String? bankBranch;
  String? bankIFSC;

  // Form Metadata
  DateTime? submittedOn;
  DateTime? archivedOn;
  String? archivedBy;
  bool agreement;
  String status;

  // Submission Details
  int? ticketId;

  FarmerFormData({
    this.id,
    this.name,
    this.careOfName,
    this.classType,
    this.district,
    this.block,
    this.panchayat,
    this.village,
    this.post,
    this.policeStation,
    this.mobileNumber,
    this.landSize,
    this.landCategory,
    this.khataNumber,
    this.plotNumber,
    this.mauja,
    this.aadharNumber,
    this.bankAccountNumber,
    this.bankName,
    this.bankBranch,
    this.bankIFSC,
    this.submittedOn,
    this.archivedOn,
    this.archivedBy,
    this.agreement = false,
    this.status = 'active',
    this.ticketId,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'careOfName': careOfName,
      'classType': classType,
      'district': district,
      'block': block,
      'panchayat': panchayat,
      'village': village,
      'post': post,
      'policeStation': policeStation,
      'mobileNumber': mobileNumber,
      'landSize': landSize,
      'landCategory': landCategory,
      'khataNumber': khataNumber,
      'plotNumber': plotNumber,
      'mauja': mauja,
      'aadharNumber': aadharNumber,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'bankBranch': bankBranch,
      'bankIFSC': bankIFSC,
      'submittedOn':
          submittedOn != null ? Timestamp.fromDate(submittedOn!) : null,
      'archivedOn': archivedOn != null ? Timestamp.fromDate(archivedOn!) : null,
      'archivedBy': archivedBy,
      'agreement': agreement,
      'status': status,
      'ticketId': ticketId,
    };
  }

  factory FarmerFormData.fromJson(Map<String, dynamic> json) {
    return FarmerFormData(
      id: json['id'] as String?,
      name: json['name'] as String?,
      careOfName: json['careOfName'] as String?,
      classType: json['classType'] as String?,
      district: json['district'] as String?,
      block: json['block'] as String?,
      panchayat: json['panchayat'] as String?,
      village: json['village'] as String?,
      post: json['post'] as String?,
      policeStation: json['policeStation'] as String?,
      mobileNumber: json['mobileNumber'] as String?,
      landSize: json['landSize'] as double?,
      landCategory: json['landCategory'] as String?,
      khataNumber: json['khataNumber'] as String?,
      plotNumber: json['plotNumber'] as String?,
      mauja: json['mauja'] as String?,
      aadharNumber: json['aadharNumber'] as String?,
      bankAccountNumber: json['bankAccountNumber'] as String?,
      bankName: json['bankName'] as String?,
      bankBranch: json['bankBranch'] as String?,
      bankIFSC: json['bankIFSC'] as String?,
      submittedOn: json['submittedOn'] != null
          ? (json['submittedOn'] as Timestamp).toDate()
          : null,
      archivedOn: json['archivedOn'] != null
          ? (json['archivedOn'] as Timestamp).toDate()
          : null,
      archivedBy: json['archivedBy'] as String?,
      agreement: json['agreement'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
      ticketId: json['ticketId'] as int?,
    );
  }
}
