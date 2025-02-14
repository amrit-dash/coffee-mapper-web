import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:coffee_mapper_web/models/farmer_form_data.dart';
import 'package:coffee_mapper_web/widgets/forms/farmer_application/form_fields/odia_text_field.dart';
import 'package:coffee_mapper_web/widgets/forms/farmer_application/form_fields/odia_dropdown_field.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:coffee_mapper_web/providers/address_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FarmerFormDialog extends ConsumerStatefulWidget {
  const FarmerFormDialog({super.key});

  @override
  ConsumerState<FarmerFormDialog> createState() => _FarmerFormDialogState();
}

class _FarmerFormDialogState extends ConsumerState<FarmerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  final _formData = FarmerFormData(
    submittedOn: DateTime.now(),
  );

  // Temporary lists for dropdowns - will be replaced with DB data
  final List<String> _classTypes = ['ST', 'SC', 'OC'];
  final List<String> _landCategories = [
    'Own Land (ନିଜ ଜମି)',
    'Forest Land (ଜଙ୍ଗଲ ଜମି)',
    'Rural Forest (ଗ୍ରାମ୍ୟ ଜଙ୍ଗଲ)',
    'Collective Land (ସାମୁହିକ ଜମି)',
  ];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate timestamp for both document ID and ticket ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String docID = timestamp.toString();

      // Update form data with submission details
      _formData.ticketId = timestamp;

      // Convert form data to JSON
      final data = _formData.toJson();

      // Submit to Firestore using timestamp as document ID
      await FirebaseFirestore.instance
          .collection('farmerApplications')
          .doc(docID)
          .set(data);

      if (!mounted) return;

      // Show success message with ticket ID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).cardColor,
              ),
              const SizedBox(width: 8),
              Text(
                  'Form submitted successfully. Ticket ID: ${_formData.ticketId}'),
            ],
          ),
          duration: const Duration(seconds: 5),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = ResponsiveUtils.isMobile(screenWidth);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: screenWidth * (isMobile ? 0.95 : 0.75),
        height: screenHeight * 0.9,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'ନିରନ୍ତର ଜୀବିକା ପାଇଁ କଫି ଚାଷ (CPSL)\nକଫି ଚାଷ / ଛାୟା ବୃକ୍ଷ ରୋପଣ ପାଇଁ ଆବେଦନ ପତ୍ର',
                    style: TextStyle(
                      fontFamily: 'Gilroy-SemiBold',
                      fontSize: ResponsiveUtils.getFontSize(screenWidth, 23),
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            //const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Sub Section Header
                      _buildHeaderSubSection('ପ୍ରାପ୍ତେଷ୍ଣ:',
                          'ଉପନିର୍ଦ୍ଧେଶକ କଫି ଉନ୍ମୟନ, କୋରାପୁଟ / ପ୍ରକଳ୍ପ ନିର୍ଦ୍ଧେଶକ ଜଳ ବିଭାଜିକା, କୋରାପୁଟ'),
                      // Initial Details Section
                      _buildSectionHeader('Initial Details (ନିଜ ବିବରଣୀ)'),
                      OdiaTextField(
                        englishLabel: 'Name',
                        odiaLabel: 'ନାମ',
                        value: _formData.name,
                        onChanged: (value) => _formData.name = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Father/Husband\'s Name',
                        odiaLabel: 'ପିତା/ସ୍ୱାମୀଙ୍କ ନାମ',
                        value: _formData.careOfName,
                        onChanged: (value) => _formData.careOfName = value,
                      ),
                      OdiaDropdownField(
                        englishLabel: 'Class of Beneficiary',
                        odiaLabel: 'ହିତାଧିକାରୀଙ୍କ ଶ୍ରେଣୀ',
                        value: _formData.classType,
                        items: _classTypes,
                        onChanged: (value) =>
                            setState(() => _formData.classType = value),
                      ),

                      // Address Section
                      _buildSectionHeader('Address Details (ଠିକଣା ବିବରଣୀ)'),
                      _buildAddressSection(),
                      OdiaTextField(
                        englishLabel: 'Post',
                        odiaLabel: 'ପୋଷ୍ଟ',
                        value: _formData.post,
                        onChanged: (value) => _formData.post = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Police Station',
                        odiaLabel: 'ଥାନା',
                        value: _formData.policeStation,
                        onChanged: (value) => _formData.policeStation = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Mobile Number',
                        odiaLabel: 'ମୋବାଇଲ୍ ନମ୍ବର',
                        value: _formData.mobileNumber,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        validator: (value) {
                          if (value?.length != 10) {
                            return 'Mobile number must be 10 digits';
                          }
                          return null;
                        },
                        onChanged: (value) => _formData.mobileNumber = value,
                      ),

                      // Land Details Section
                      _buildSectionHeader('Land Details (ଜମି ବିବରଣୀ)'),
                      OdiaTextField(
                        englishLabel: 'Land Size',
                        odiaLabel: 'ମୋଟ ଜମିର ପରିମାଣ',
                        value: _formData.landSize?.toString(),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        onChanged: (value) =>
                            _formData.landSize = double.tryParse(value),
                        suffix: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.01),
                          child: const Text(
                            'acres',
                            style: TextStyle(
                              fontFamily: 'Gilroy-Medium',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      OdiaDropdownField(
                        englishLabel: 'Land Category',
                        odiaLabel: 'ଜମି କିସମ',
                        value: _formData.landCategory,
                        items: _landCategories,
                        onChanged: (value) =>
                            setState(() => _formData.landCategory = value),
                      ),
                      OdiaTextField(
                        englishLabel: 'Khata Number',
                        odiaLabel: 'ଖାତା ନମ୍ବର',
                        value: _formData.khataNumber,
                        onChanged: (value) => _formData.khataNumber = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Plot Number',
                        odiaLabel: 'ପ୍ଲଟ ନମ୍ବର',
                        value: _formData.plotNumber,
                        onChanged: (value) => _formData.plotNumber = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Mauja',
                        odiaLabel: 'ମୌଜା',
                        value: _formData.mauja,
                        onChanged: (value) => _formData.mauja = value,
                      ),

                      // Bank Details Section
                      _buildSectionHeader('Bank Details (ବାଙ୍କ ପାସବୁକ ବିବରଣୀ)'),
                      OdiaTextField(
                        englishLabel: 'Aadhar Number',
                        odiaLabel: 'ଆଧାର ନମ୍ବର',
                        value: _formData.aadharNumber,
                        maxLength: 12,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: (value) {
                          if (value?.length != 12) {
                            return 'Aadhar number must be 12 digits';
                          }
                          return null;
                        },
                        onChanged: (value) => _formData.aadharNumber = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Bank Account Number',
                        odiaLabel: 'ବାଙ୍କ ଖାତା ନମ୍ବର',
                        value: _formData.bankAccountNumber,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) =>
                            _formData.bankAccountNumber = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Bank Name',
                        odiaLabel: 'ବାଙ୍କ ନାମ',
                        value: _formData.bankName,
                        onChanged: (value) => _formData.bankName = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'Bank Branch',
                        odiaLabel: 'ବାଙ୍କ ସଖା',
                        value: _formData.bankBranch,
                        onChanged: (value) => _formData.bankBranch = value,
                      ),
                      OdiaTextField(
                        englishLabel: 'IFSC Code',
                        odiaLabel: 'ବାଙ୍କ ଇଫସସ',
                        value: _formData.bankIFSC,
                        onChanged: (value) => _formData.bankIFSC = value,
                      ),

                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 18),

                      // Date and Consent Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildDateSection(),
                          const SizedBox(height: 16),
                          _buildConsentSection(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.error),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontFamily: 'Gilroy-SemiBold',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (!_formData.agreement) {
                              // Show error message as overlay
                              final overlay = Overlay.of(context);
                              final entry = OverlayEntry(
                                builder: (context) => Positioned(
                                  bottom: screenHeight * 0.5,
                                  left: screenWidth * 0.3,
                                  right: screenWidth * 0.3,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      margin: const EdgeInsets.all(16),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).highlightColor,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error_outline,
                                              color:
                                                  Theme.of(context).cardColor,
                                              size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Please proceed with beneficiary\'s agreement',
                                            style: TextStyle(
                                              color:
                                                  Theme.of(context).cardColor,
                                              fontFamily: 'Gilroy-Medium',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );

                              overlay.insert(entry);

                              // Auto remove after 3 seconds
                              Future.delayed(const Duration(seconds: 3), () {
                                entry.remove();
                              });

                              // Scroll to checkbox
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                              return;
                            }
                            _submitForm();
                          },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Submit',
                            style: TextStyle(
                              fontFamily: 'Gilroy-SemiBold',
                              fontSize: 16,
                              color: Theme.of(context).cardColor,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsentSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _formData.agreement,
            onChanged: (value) =>
                setState(() => _formData.agreement = value ?? false),
            side: BorderSide(
              color: !_formData.agreement
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.secondary,
              width: !_formData.agreement ? 2 : 1,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Form is filled with beneficiery\'s agreement. (ହିତାଧିକାରୀଙ୍କ ସ୍ଵାକ୍ଷର)',
                  style: const TextStyle(
                    fontFamily: 'Gilroy-Medium',
                    fontSize: 14,
                  ),
                  softWrap: true,
                ),
                if (!_formData.agreement)
                  Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Please agree to proceed',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 12,
                          fontFamily: 'Gilroy-Medium',
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    String formattedDate = _formData.submittedOn != null
        ? '${_formData.submittedOn!.day.toString().padLeft(2, '0')}-'
            '${_formData.submittedOn!.month.toString().padLeft(2, '0')}-'
            '${_formData.submittedOn!.year}'
        : '';

    return Row(
      children: [
        Text(
          'Today\'s Date (ଆଜିର ତରିକା):',
          style: const TextStyle(
            fontFamily: 'Gilroy-SemiBold',
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formattedDate,
          style: TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSubSection(String sideHeader, String mainText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        const Divider(),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              sideHeader,
              style: TextStyle(
                fontFamily: 'Gilroy-SemiBold',
                fontSize: 12,
                color: Theme.of(context).highlightColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mainText,
                style: TextStyle(
                  fontFamily: 'Gilroy-Medium',
                  fontSize: 12,
                  color: Theme.of(context).highlightColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        const Divider(),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Gilroy-SemiBold',
            fontSize: 18,
            color: Theme.of(context).highlightColor,
          ),
        ),
        const SizedBox(height: 2),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAddressSection() {
    final addressDataAsync = ref.watch(addressDataProvider);

    return addressDataAsync.when(
      loading: () => Column(
        children: [
          OdiaDropdownField(
              englishLabel: 'District',
              odiaLabel: 'ଜିଲ୍ଲା',
              value: null,
              items: const [],
              onChanged: (_) {},
              isLoading: true,
              isRequired: true),
          OdiaDropdownField(
              englishLabel: 'Block',
              odiaLabel: 'ବ୍ଲକ',
              value: null,
              items: const [],
              onChanged: (_) {},
              isLoading: true,
              isRequired: true),
          OdiaDropdownField(
              englishLabel: 'Panchayat',
              odiaLabel: 'ପଂଚାୟତ',
              value: null,
              items: const [],
              onChanged: (_) {},
              isLoading: true,
              isRequired: true),
          OdiaDropdownField(
            englishLabel: 'Village',
            odiaLabel: 'ଗ୍ରାମ',
            value: null,
            items: const [],
            onChanged: (_) {},
            isLoading: true,
            isRequired: true,
          ),
        ],
      ),
      error: (err, stack) => Text('Error: $err'),
      data: (addressData) {
        final selectedDistrict = ref.watch(selectedDistrictProvider);
        final selectedBlock = ref.watch(selectedBlockProvider);
        final selectedPanchayat = ref.watch(selectedPanchayatProvider);
        final selectedVillage = ref.watch(selectedVillageProvider);

        final blocks = ref.watch(availableBlocksProvider);
        final panchayats = ref.watch(availablePanchayatsProvider);
        final villages = ref.watch(availableVillagesProvider);

        return Column(
          children: [
            OdiaDropdownField(
              englishLabel: 'District',
              odiaLabel: 'ଜିଲ୍ଲା',
              value: selectedDistrict,
              items: addressData.districts,
              onChanged: (value) {
                ref.read(selectedDistrictProvider.notifier).state = value;
                ref.read(selectedBlockProvider.notifier).state = null;
                ref.read(selectedPanchayatProvider.notifier).state = null;
                ref.read(selectedVillageProvider.notifier).state = null;
                _formData.district = value;
              },
            ),
            OdiaDropdownField(
              englishLabel: 'Block',
              odiaLabel: 'ବ୍ଲକ',
              value: selectedBlock,
              items: blocks,
              onChanged: (value) {
                ref.read(selectedBlockProvider.notifier).state = value;
                ref.read(selectedPanchayatProvider.notifier).state = null;
                ref.read(selectedVillageProvider.notifier).state = null;
                _formData.block = value;
              },
              isLoading: selectedDistrict != null && blocks.isEmpty,
            ),
            OdiaDropdownField(
              englishLabel: 'Panchayat',
              odiaLabel: 'ପଂଚାୟତ',
              value: selectedPanchayat,
              items: panchayats,
              onChanged: (value) {
                ref.read(selectedPanchayatProvider.notifier).state = value;
                ref.read(selectedVillageProvider.notifier).state = null;
                _formData.panchayat = value;
              },
              isLoading: selectedBlock != null && panchayats.isEmpty,
            ),
            OdiaDropdownField(
              englishLabel: 'Village',
              odiaLabel: 'ଗ୍ରାମ',
              value: selectedVillage,
              items: villages,
              onChanged: (value) {
                ref.read(selectedVillageProvider.notifier).state = value;
                _formData.village = value;
              },
              isLoading: selectedPanchayat != null && villages.isEmpty,
            ),
          ],
        );
      },
    );
  }
}
