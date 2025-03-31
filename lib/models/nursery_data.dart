import 'package:cloud_firestore/cloud_firestore.dart';

class NurseryData {
  final String id;
  final String district;
  final String block;
  final String panchayat;
  final String village;
  final String regionName;
  final String regionCategory;
  final double area;
  final double perimeter;
  final String status;
  final String savedBy;
  final String updatedBy;
  final String dateUpdated;
  final String dateSaved;
  final List<String> polygonCoordinates;
  final List<String> boundaryImageURLs;
  final List<String> mediaURLs;

  // Optional fields
  final int? seedlingsRaised;
  final int? seedsQuantity;
  final String? coffeeVariety;
  final String? sowingDate;
  final String? transplantingDate;
  final String? firstPairLeaves;
  final String? secondPairLeaves;
  final String? thirdPairLeaves;
  final String? fourthPairLeaves;
  final String? fifthPairLeaves;
  final String? sixthPairLeaves;

  NurseryData({
    required this.id,
    required this.district,
    required this.block,
    required this.panchayat,
    required this.village,
    required this.regionName,
    required this.regionCategory,
    required this.area,
    required this.perimeter,
    required this.status,
    required this.savedBy,
    required this.updatedBy,
    required this.dateUpdated,
    required this.dateSaved,
    required this.polygonCoordinates,
    required this.boundaryImageURLs,
    required this.mediaURLs,
    this.seedlingsRaised,
    this.seedsQuantity,
    this.coffeeVariety,
    this.sowingDate,
    this.transplantingDate,
    this.firstPairLeaves,
    this.secondPairLeaves,
    this.thirdPairLeaves,
    this.fourthPairLeaves,
    this.fifthPairLeaves,
    this.sixthPairLeaves,
  });

  static String _getFormattedTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    final String period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final int hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    return '${dateTime.day}-${dateTime.month}-${dateTime.year}, $hour:$minute $period';
  }

  static String? _formatOptionalTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}-${date.month}-${date.year}';
    }
    return null;
  }

  static List<String> _convertPoints(List<dynamic>? points) {
    if (points == null) return [];
    return points.map((point) => point.toString()).toList();
  }

  static List<String> _convertUrls(List<dynamic>? urls) {
    if (urls == null) return [];
    return urls.map((url) => url.toString()).toList();
  }

  factory NurseryData.fromMap(Map<String, dynamic> map, String id) {
    return NurseryData(
      id: id,
      district: map['district'] ?? '',
      block: map['block'] ?? '',
      panchayat: map['panchayat'] ?? '',
      village: map['village'] ?? '',
      regionName: map['regionName'] ?? '',
      regionCategory: map['regionCategory'] ?? '',
      area: (map['area'] ?? 0.0).toDouble(),
      perimeter: (map['perimeter'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'Active',
      savedBy: map['savedBy'] ?? '',
      updatedBy: map['updatedBy'] ?? '',
      dateUpdated: map['updatedOn'] != null
          ? _getFormattedTimestamp(map['updatedOn'] as Timestamp)
          : '',
      dateSaved: map['savedOn'] != null
          ? _getFormattedTimestamp(map['savedOn'] as Timestamp)
          : '',
      polygonCoordinates: _convertPoints(map['polygonPoints']),
      boundaryImageURLs: _convertUrls(map['boundaryImageURLs']),
      mediaURLs: _convertUrls(map['mediaURLs']),
      seedlingsRaised: map['seedlingsRaised'],
      seedsQuantity: map['seedsQuantity'],
      coffeeVariety: map['coffeeVariety'],
      sowingDate: _formatOptionalTimestamp(map['sowingDate']),
      transplantingDate: _formatOptionalTimestamp(map['transplantingDate']),
      firstPairLeaves: _formatOptionalTimestamp(map['firstPairLeaves']),
      secondPairLeaves: _formatOptionalTimestamp(map['secondPairLeaves']),
      thirdPairLeaves: _formatOptionalTimestamp(map['thirdPairLeaves']),
      fourthPairLeaves: _formatOptionalTimestamp(map['fourthPairLeaves']),
      fifthPairLeaves: _formatOptionalTimestamp(map['fifthPairLeaves']),
      sixthPairLeaves: _formatOptionalTimestamp(map['sixthPairLeaves']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'district': district,
      'block': block,
      'panchayat': panchayat,
      'village': village,
      'regionName': regionName,
      'regionCategory': regionCategory,
      'area': area,
      'perimeter': perimeter,
      'status': status,
      'savedBy': savedBy,
      'updatedBy': updatedBy,
      'dateUpdated': dateUpdated,
      'dateSaved': dateSaved,
      'polygonPoints': polygonCoordinates,
      'boundaryImageURLs': boundaryImageURLs,
      'mediaURLs': mediaURLs,
      'seedlingsRaised': seedlingsRaised,
      'seedsQuantity': seedsQuantity,
      'coffeeVariety': coffeeVariety,
      'sowingDate': sowingDate,
      'transplantingDate': transplantingDate,
      'firstPairLeaves': firstPairLeaves,
      'secondPairLeaves': secondPairLeaves,
      'thirdPairLeaves': thirdPairLeaves,
      'fourthPairLeaves': fourthPairLeaves,
      'fifthPairLeaves': fifthPairLeaves,
      'sixthPairLeaves': sixthPairLeaves,
    };
  }
}
