class ShadeData {
  final String id;
  final String district;
  final String block;
  final String village;
  final String panchayat;
  final String region;
  final String regionCategory;
  final double area;
  final double perimeter;
  final String mapImageUrl;
  final List<String> boundaryImageURLs;
  final List<String> polygonCoordinates;
  final String dateUpdated;
  final String dateSaved;
  final String savedBy;
  final String status;
  final String agencyName;
  final double averageHeight;
  final double averageYield;
  final int beneficiaries;
  final String khataNumber;
  final String plotNumber;
  final String shadeType;
  final List<String> mediaURLs;
  final double survivalPercentage;
  final List<String> plantVarieties;
  final int plantationYear;
  
  ShadeData({
    required this.id,
    required this.district,
    required this.block,
    required this.village,
    required this.panchayat,
    required this.region,
    required this.regionCategory,
    required this.area,
    required this.perimeter,
    required this.mapImageUrl,
    required this.boundaryImageURLs,
    required this.polygonCoordinates,
    required this.dateUpdated,
    required this.dateSaved,
    required this.savedBy,
    required this.status,
    required this.agencyName,
    required this.averageHeight,
    required this.averageYield,
    required this.beneficiaries,
    required this.khataNumber,
    required this.plotNumber,
    required this.shadeType,
    required this.mediaURLs,
    required this.survivalPercentage,
    required this.plantVarieties,
    required this.plantationYear,
  });
} 
