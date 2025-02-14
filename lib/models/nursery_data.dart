class NurseryData {
  final String id;
  final String district;
  final String block;
  final String panchayat;
  final String village;
  final String rangeName;
  final int seedlingsQuantity;
  final String coffeeVariety;
  final int seedsQuantity;
  final String sowingDate;
  final String transplantingDate;
  final String leafPair1;
  final String leafPair2;
  final String leafPair3;
  final String leafPair4;
  final String leafPair5;
  final String leafPair6;
  final String status;

  NurseryData({
    required this.id,
    required this.district,
    required this.block,
    required this.panchayat,
    required this.village,
    required this.rangeName,
    required this.seedlingsQuantity,
    required this.coffeeVariety,
    required this.seedsQuantity,
    required this.sowingDate,
    required this.transplantingDate,
    required this.leafPair1,
    required this.leafPair2,
    required this.leafPair3,
    required this.leafPair4,
    required this.leafPair5,
    required this.leafPair6,
    required this.status,
  });

  factory NurseryData.fromMap(String id, Map<String, dynamic> map) {
    return NurseryData(
      id: id,
      district: map['district'] ?? '',
      block: map['block'] ?? '',
      panchayat: map['panchayat'] ?? '',
      village: map['village'] ?? '',
      rangeName: map['rangeName'] ?? '',
      seedlingsQuantity: map['seedlingsQuantity']?.toInt() ?? 0,
      coffeeVariety: map['coffeeVariety'] ?? '',
      seedsQuantity: map['seedsQuantity']?.toInt() ?? 0,
      sowingDate: map['sowingDate'] ?? '',
      transplantingDate: map['transplantingDate'] ?? '',
      leafPair1: map['leafPair1'] ?? '',
      leafPair2: map['leafPair2'] ?? '',
      leafPair3: map['leafPair3'] ?? '',
      leafPair4: map['leafPair4'] ?? '',
      leafPair5: map['leafPair5'] ?? '',
      leafPair6: map['leafPair6'] ?? '',
      status: map['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'district': district,
      'block': block,
      'panchayat': panchayat,
      'village': village,
      'rangeName': rangeName,
      'seedlingsQuantity': seedlingsQuantity,
      'coffeeVariety': coffeeVariety,
      'seedsQuantity': seedsQuantity,
      'sowingDate': sowingDate,
      'transplantingDate': transplantingDate,
      'leafPair1': leafPair1,
      'leafPair2': leafPair2,
      'leafPair3': leafPair3,
      'leafPair4': leafPair4,
      'leafPair5': leafPair5,
      'leafPair6': leafPair6,
      'status': status,
    };
  }
} 