import 'package:data_table_2/data_table_2.dart';
import 'package:coffee_mapper_web/utils/table_constants.dart';

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
      label: 'Region\nName',
      size: ColumnSize.L,
      width: TableConstants.kRegionNameWidth,
    ),
    ColumnDef(
      label: 'Region\nCategory',
      size: ColumnSize.L,
      width: TableConstants.kRegionCategoryWidth,
    ),
    ColumnDef(
      label: 'Region\nBoundary',
      size: ColumnSize.M,
      width: TableConstants.kBoundaryWidth,
      suffix: 'm',
    ),
    ColumnDef(
      label: 'Region\nArea',
      size: ColumnSize.M,
      width: TableConstants.kAreaWidth,
      suffix: 'm²',
    ),
    ColumnDef(
      label: 'Plantation\nYear',
      size: ColumnSize.M,
      width: TableConstants.kPlantationYearWidth,
    ),
    ColumnDef(
      label: 'Plant\nVariety',
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
      label: 'Region\nMedia',
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
      label: 'Region\nName',
      size: ColumnSize.L,
      width: TableConstants.kRegionNameWidth,
    ),
    ColumnDef(
      label: 'Region\nCategory',
      size: ColumnSize.L,
      width: TableConstants.kRegionCategoryWidth,
    ),
    ColumnDef(
      label: 'Region\nBoundary',
      size: ColumnSize.M,
      width: TableConstants.kBoundaryWidth,
      suffix: 'm',
    ),
    ColumnDef(
      label: 'Region\nArea',
      size: ColumnSize.M,
      width: TableConstants.kAreaWidth,
      suffix: 'm²',
    ),
    ColumnDef(
      label: 'Shade\nType',
      size: ColumnSize.M,
      width: TableConstants.kShadeTypeWidth,
    ),
    ColumnDef(
      label: 'Plantation\nYear',
      size: ColumnSize.M,
      width: TableConstants.kPlantationYearWidth,
    ),
    ColumnDef(
      label: 'Plant\nVariety',
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
      label: 'Region\nMedia',
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

  static const ColumnDef deleteColumn = ColumnDef(
    label: 'X',
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
      size: ColumnSize.M,
      width: 120.0,
    ),
  ];
} 