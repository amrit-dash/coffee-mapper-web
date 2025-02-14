import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:coffee_mapper_web/models/nursery_data.dart';
import 'package:coffee_mapper_web/widgets/tables/nursery_highlights/nursery_table.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/services/nursery_service.dart';
//Admin Provider - Deprecated For Now
//import 'package:coffee_mapper_web/providers/admin_provider.dart';

class NurseryHighlightsSection extends ConsumerStatefulWidget {
  const NurseryHighlightsSection({super.key});

  @override
  ConsumerState<NurseryHighlightsSection> createState() =>
      _NurseryHighlightsSectionState();
}

class _NurseryHighlightsSectionState
    extends ConsumerState<NurseryHighlightsSection> {
  final NurseryService _nurseryService = NurseryService();
  List<NurseryData> allData = [];
  late Stream<List<NurseryData>> _dataStream;

  @override
  void initState() {
    super.initState();
    _dataStream = _nurseryService.getNurseryDataStream();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    // Only show this section if user is admin - Deprecated
    // All Users Can See This Section
    // final adminData = ref.watch(adminProvider);
    // if (adminData == null || !adminData.isAdmin) {
    //   return const SizedBox.shrink();
    // }

    return SizedBox(
      height: ResponsiveUtils.getTableContainerHeight(screenWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 20),
            child: Text(
              'Coffee Nursery Details for 2024-25',
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                fontSize: ResponsiveUtils.getFontSize(screenWidth, 20),
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(35, 0, 0, 0),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                  BoxShadow(
                    color: Color.fromARGB(35, 0, 0, 0),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: StreamBuilder<List<NurseryData>>(
                stream: _dataStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return NurseryTable(
                      nurseryData: const [],
                      error: 'Error: ${snapshot.error}',
                    );
                  }

                  if (!snapshot.hasData) {
                    return const NurseryTable(
                      nurseryData: [],
                      isLoading: true,
                    );
                  }

                  allData = snapshot.data!;
                  return NurseryTable(nurseryData: allData);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
