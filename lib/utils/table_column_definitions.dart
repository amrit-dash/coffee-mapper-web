import 'package:coffee_mapper_web/utils/table_constants.dart';
import 'package:data_table_2/data_table_2.dart';

class ColumnDef {
  final String label;
  final ColumnSize size;
  final double width;
  final String? suffix;

  const ColumnDef({
    required this.label,
    required this.size,
    required this.width,
    this.suffix,
  });
}

class TableColumns {
  static const List<ColumnDef> shadeColumns = [
    ColumnDef(
      label: 'Name',
      size: ColumnSize.L,
      width: TableConstants.kRegionNameWidth,
    ),
    ColumnDef(
      label: 'Category',
      size: ColumnSize.L,
      width: TableConstants.kRegionCategoryWidth,
    ),
    ColumnDef(
      label: 'Boundary',
      size: ColumnSize.M,
      width: TableConstants.kBoundaryWidth,
      suffix: 'm',
    ),
    ColumnDef(
      label: 'Area',
      size: ColumnSize.M,
      width: TableConstants.kAreaWidth,
      suffix: 'm²',
    ),
    ColumnDef(
      label: 'Year',
      size: ColumnSize.M,
      width: TableConstants.kPlantationYearWidth,
    ),
    ColumnDef(
      label: 'Shade Type',
      size: ColumnSize.L,
      width: TableConstants.kShadeTypeWidth,
    ),
    ColumnDef(
      label: 'Average\nHeight',
      size: ColumnSize.M,
      width: TableConstants.kAverageHeightWidth,
      suffix: 'ft',
    ),
    ColumnDef(
      label: 'Beneficiaries\nCount',
      size: ColumnSize.M,
      width: TableConstants.kBeneficiariesCountWidth,
    ),
    ColumnDef(
      label: 'Survival\nPercentage',
      size: ColumnSize.M,
      width: TableConstants.kSurvivalPercentageWidth,
      suffix: '%',
    ),
    ColumnDef(
      label: 'Plot\nNumber',
      size: ColumnSize.M,
      width: TableConstants.kPlotNumberWidth,
    ),
    ColumnDef(
      label: 'Khata\nNumber',
      size: ColumnSize.M,
      width: TableConstants.kKhataNumberWidth,
    ),
    ColumnDef(
      label: 'Implementing\nAgency',
      size: ColumnSize.L,
      width: TableConstants.kAgencyWidth,
    ),
    ColumnDef(
      label: 'Saved By',
      size: ColumnSize.M,
      width: TableConstants.kSavedByWidth,
    ),
    ColumnDef(
      label: 'Updated On',
      size: ColumnSize.L,
      width: TableConstants.kUpdatedOnWidth,
    ),
    ColumnDef(
      label: 'Project\nMedia',
      size: ColumnSize.S,
      width: TableConstants.kMediaWidth,
    ),
    ColumnDef(
      label: 'Boundary\nImages',
      size: ColumnSize.S,
      width: TableConstants.kBoundaryImageWidth,
    ),
    ColumnDef(
      label: 'Survey\nStatus',
      size: ColumnSize.M,
      width: TableConstants.kSurveyStatusWidth,
    ),
  ];

  static const List<ColumnDef> coffeeColumns = [
    ColumnDef(
      label: 'Name',
      size: ColumnSize.L,
      width: TableConstants.kRegionNameWidth,
    ),
    ColumnDef(
      label: 'Category',
      size: ColumnSize.L,
      width: TableConstants.kRegionCategoryWidth,
    ),
    ColumnDef(
      label: 'Boundary',
      size: ColumnSize.M,
      width: TableConstants.kBoundaryWidth,
      suffix: 'm',
    ),
    ColumnDef(
      label: 'Area',
      size: ColumnSize.M,
      width: TableConstants.kAreaWidth,
      suffix: 'm²',
    ),
    ColumnDef(
      label: 'Year',
      size: ColumnSize.M,
      width: TableConstants.kPlantationYearWidth,
    ),
    ColumnDef(
      label: 'Plant Variety',
      size: ColumnSize.L,
      width: TableConstants.kPlantVarietyWidth,
    ),
    ColumnDef(
      label: 'Average\nHeight',
      size: ColumnSize.M,
      width: TableConstants.kAverageHeightWidth,
      suffix: 'ft',
    ),
    ColumnDef(
      label: 'Average\nYield',
      size: ColumnSize.M,
      width: TableConstants.kAverageYieldWidth,
      suffix: 'kg',
    ),
    ColumnDef(
      label: 'Beneficiaries\nCount',
      size: ColumnSize.M,
      width: TableConstants.kBeneficiariesCountWidth,
    ),
    ColumnDef(
      label: 'Survival\nPercentage',
      size: ColumnSize.M,
      width: TableConstants.kSurvivalPercentageWidth,
      suffix: '%',
    ),
    ColumnDef(
      label: 'Plot\nNumber',
      size: ColumnSize.M,
      width: TableConstants.kPlotNumberWidth,
    ),
    ColumnDef(
      label: 'Khata\nNumber',
      size: ColumnSize.M,
      width: TableConstants.kKhataNumberWidth,
    ),
    ColumnDef(
      label: 'Implementing\nAgency',
      size: ColumnSize.L,
      width: TableConstants.kAgencyWidth,
    ),
    ColumnDef(
      label: 'Saved By',
      size: ColumnSize.M,
      width: TableConstants.kSavedByWidth,
    ),
    ColumnDef(
      label: 'Updated On',
      size: ColumnSize.L,
      width: TableConstants.kUpdatedOnWidth,
    ),
    ColumnDef(
      label: 'Project\nMedia',
      size: ColumnSize.S,
      width: TableConstants.kMediaWidth,
    ),
    ColumnDef(
      label: 'Boundary\nImages',
      size: ColumnSize.S,
      width: TableConstants.kBoundaryImageWidth,
    ),
    ColumnDef(
      label: 'Survey\nStatus',
      size: ColumnSize.M,
      width: TableConstants.kSurveyStatusWidth,
    ),
  ];

  static const List<ColumnDef> nurseryColumns = [
    ColumnDef(
      label: 'SHG/SC Range Name',
      size: ColumnSize.L,
      width: TableConstants.kRegionNameWidth,
    ),
    ColumnDef(
      label: 'Boundary',
      size: ColumnSize.M,
      width: TableConstants.kBoundaryWidth,
      suffix: 'm',
    ),
    ColumnDef(
      label: 'Area',
      size: ColumnSize.M,
      width: TableConstants.kAreaWidth,
      suffix: 'm²',
    ),
    ColumnDef(
      label: 'Coffee\nVariety',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Seeds\nQuantity',
      size: ColumnSize.M,
      width: 100.0,
    ),
    ColumnDef(
      label: 'Seedlings\nRaised',
      size: ColumnSize.M,
      width: 100.0,
    ),
    ColumnDef(
      label: 'Sowing\nDate',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Transplanting\nDate',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'First Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Second Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Third Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Fourth Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Fifth Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Sixth Pair\nLeaves',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Saved By',
      size: ColumnSize.M,
      width: TableConstants.kSavedByWidth,
    ),
    ColumnDef(
      label: 'Updated On',
      size: ColumnSize.L,
      width: TableConstants.kUpdatedOnWidth,
    ),
    ColumnDef(
      label: 'Project\nMedia',
      size: ColumnSize.S,
      width: TableConstants.kMediaWidth,
    ),
    ColumnDef(
      label: 'Boundary\nImages',
      size: ColumnSize.S,
      width: TableConstants.kBoundaryImageWidth,
    ),
  ];

  static const ColumnDef deleteColumn = ColumnDef(
    label: 'X',
    size: ColumnSize.S,
    width: TableConstants.kDeleteColumnWidth,
  );

  static final downloadColumn = ColumnDef(
    label: 'Download\nHTML',
    size: ColumnSize.S,
    width: TableConstants.kDeleteColumnWidth,
  );

  static const List<ColumnDef> beneficiaryColumns = [
    ColumnDef(
      label: 'Ticket ID\n(ଟିକେଟ ନମ୍ବର)',
      size: ColumnSize.M,
      width: 120.0,
    ),
    ColumnDef(
      label: 'Name\n(ନାମ)',
      size: ColumnSize.L,
      width: 180.0,
    ),
    ColumnDef(
      label: 'Father/Husband\'s Name\n(ପିତା/ସ୍ୱାମୀଙ୍କ ନାମ)',
      size: ColumnSize.L,
      width: 200.0,
    ),
    ColumnDef(
      label: 'Village\n(ଗ୍ରାମ)',
      size: ColumnSize.M,
      width: 170.0,
    ),
    ColumnDef(
      label: 'Post\n(ପୋଷ୍ଟ)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Police Station\n(ଥାନା)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Land Size\n(ଜମି ପରିମାଣ)',
      size: ColumnSize.M,
      width: 120.0,
      suffix: 'acres',
    ),
    ColumnDef(
      label: 'Land Category\n(ଜମି ବର୍ଗ)',
      size: ColumnSize.L,
      width: 200.0,
    ),
    ColumnDef(
      label: 'Date of Submission\n(ଦାଖଲ ତାରିଖ)',
      size: ColumnSize.M,
      width: 150.0,
    ),
  ];

  static const List<ColumnDef> beneficiaryAdminColumns = [
    ColumnDef(
      label: 'Ticket ID\n(ଟିକେଟ ନମ୍ବର)',
      size: ColumnSize.M,
      width: 120.0,
    ),
    ColumnDef(
      label: 'Name\n(ନାମ)',
      size: ColumnSize.L,
      width: 180.0,
    ),
    ColumnDef(
      label: 'Father/Husband\'s Name\n(ପିତା/ସ୍ୱାମୀଙ୍କ ନାମ)',
      size: ColumnSize.L,
      width: 200.0,
    ),
    ColumnDef(
      label: 'Class Type\n(ଶ୍ରେଣୀ)',
      size: ColumnSize.S,
      width: 100.0,
    ),
    ColumnDef(
      label: 'Village\n(ଗ୍ରାମ)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Post\n(ପୋଷ୍ଟ)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Police Station\n(ଥାନା)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Mobile Number\n(ମୋବାଇଲ ନମ୍ବର)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Land Size\n(ଜମି ପରିମାଣ)',
      size: ColumnSize.M,
      width: 120.0,
      suffix: 'acres',
    ),
    ColumnDef(
      label: 'Land Category\n(ଜମି ବର୍ଗ)',
      size: ColumnSize.L,
      width: 200.0,
    ),
    ColumnDef(
      label: 'Khata Number\n(ଖାତା ନମ୍ବର)',
      size: ColumnSize.M,
      width: 120.0,
    ),
    ColumnDef(
      label: 'Plot Number\n(ପ୍ଲଟ ନମ୍ବର)',
      size: ColumnSize.M,
      width: 120.0,
    ),
    ColumnDef(
      label: 'Mauja\n(ମୌଜା)',
      size: ColumnSize.M,
      width: 100.0,
    ),
    ColumnDef(
      label: 'Aadhar Number\n(ଆଧାର ନମ୍ବର)',
      size: ColumnSize.M,
      width: 160.0,
    ),
    ColumnDef(
      label: 'Bank Account Number\n(ବ୍ୟାଙ୍କ ଆକାଉଣ୍ଟ ନମ୍ବର)',
      size: ColumnSize.L,
      width: 200.0,
    ),
    ColumnDef(
      label: 'Bank Name\n(ବ୍ୟାଙ୍କ ନାମ)',
      size: ColumnSize.L,
      width: 180.0,
    ),
    ColumnDef(
      label: 'Bank Branch\n(ବ୍ୟାଙ୍କ ଶାଖା)',
      size: ColumnSize.L,
      width: 180.0,
    ),
    ColumnDef(
      label: 'IFSC Code\n(IFSC କୋଡ)',
      size: ColumnSize.M,
      width: 150.0,
    ),
    ColumnDef(
      label: 'Date of Submission\n(ଦାଖଲ ତାରିଖ)',
      size: ColumnSize.L,
      width: 150.0,
    ),
  ];

  static final List<ColumnDef> legacyColumns = [
    ColumnDef(
      label: 'Name',
      size: ColumnSize.M,
      width: TableConstants.kNameWidth,
    ),
    ColumnDef(
      label: 'Father/Husband\'s Name',
      size: ColumnSize.M,
      width: TableConstants.kCareOfNameWidth,
    ),
    ColumnDef(
      label: 'Year',
      size: ColumnSize.S,
      width: TableConstants.kYearWidth,
    ),
    ColumnDef(
      label: 'Area',
      size: ColumnSize.S,
      width: TableConstants.kAreaWidth,
    ),
    ColumnDef(
      label: 'Block',
      size: ColumnSize.S,
      width: TableConstants.kBlockWidth,
    ),
    ColumnDef(
      label: 'Panchayat',
      size: ColumnSize.S,
      width: TableConstants.kPanchayatWidth,
    ),
    ColumnDef(
      label: 'Village',
      size: ColumnSize.S,
      width: TableConstants.kVillageWidth,
    ),
    ColumnDef(
      label: 'Status',
      size: ColumnSize.S,
      width: TableConstants.kStatusWidth,
    ),
  ];
}
