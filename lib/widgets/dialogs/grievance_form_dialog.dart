import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_mapper_web/models/grievance_data.dart';
import 'package:coffee_mapper_web/widgets/forms/farmer_application/form_fields/odia_text_field.dart';
import 'package:coffee_mapper_web/utils/responsive_utils.dart';
import 'package:coffee_mapper_web/widgets/dialogs/ticket_success_overlay.dart';

class GrievanceFormDialog extends StatefulWidget {
  const GrievanceFormDialog({super.key});

  @override
  State<GrievanceFormDialog> createState() => _GrievanceFormDialogState();
}

class _GrievanceFormDialogState extends State<GrievanceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool _isLoading = false;
  bool _showSuccess = false;
  String? _submittedTicketId;

  final _formData = GrievanceData(
    name: '',
    phone: '',
    grievance: '',
    ticketID: '',
    submittedOn: DateTime.now(),
  );

  bool _isValidEmail(String? email) {
    if (email == null || email.isEmpty) return true; // Optional field
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Scroll to bottom if grievance content validation fails
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Generate timestamp for both document ID and ticket ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String docID = timestamp.toString();

      // Update form data
      _formData.ticketID = docID;
      _formData.submittedOn = DateTime.now();

      // Submit to Firestore
      await FirebaseFirestore.instance
          .collection('grievances')
          .doc(docID)
          .set(_formData.toJson());

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _showSuccess = true;
        _submittedTicketId = docID;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting form: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
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
        width: screenWidth * (isMobile ? 0.8 : 0.6),
        height: screenHeight * 0.7,
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: _showSuccess && _submittedTicketId != null
            ? TicketSuccessOverlay(
                ticketID: _submittedTicketId!,
                onClose: () => Navigator.of(context).pop(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Submit a Grievance (ଅଭିଯୋଗ ଦାଖଲ କରନ୍ତୁ)',
                          style: TextStyle(
                            fontFamily: 'Gilroy-SemiBold',
                            fontSize:
                                ResponsiveUtils.getFontSize(screenWidth, 23),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  OdiaTextField(
                                    englishLabel: 'Name',
                                    odiaLabel: 'ନାମ',
                                    value: _formData.name,
                                    onChanged: (value) =>
                                        _formData.name = value,
                                  ),
                                  OdiaTextField(
                                    englishLabel: 'Phone Number',
                                    odiaLabel: 'ଫୋନ୍ ନମ୍ବର',
                                    value: _formData.phone,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    validator: (value) {
                                      if (value?.length != 10) {
                                        return 'Phone number must be 10 digits';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        _formData.phone = value,
                                  ),
                                  OdiaTextField(
                                    englishLabel: 'Email ID',
                                    odiaLabel: 'ଇମେଲ୍ ଆଇଡି',
                                    value: _formData.email,
                                    isRequired: false,
                                    validator: (value) {
                                      if (!_isValidEmail(value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        _formData.email = value,
                                  ),
                                  OdiaTextField(
                                    englishLabel: 'Grievance Content',
                                    odiaLabel: 'ଅଭିଯୋଗ ବିବରଣୀ',
                                    value: _formData.grievance,
                                    maxLines: isMobile ? 9 : 8,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 20),
                                    alignLabelWithHint: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter your grievance';
                                      }
                                      if (value.length > 1200) {
                                        return 'Grievance content cannot exceed 1200 characters';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) =>
                                        _formData.grievance = value,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Submit button
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
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                  ),
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.of(context).pop(),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontFamily: 'Gilroy-SemiBold',
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  style: FilledButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  onPressed: _isLoading ? null : _submitForm,
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
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
                  ),
                ],
              ),
      ),
    );
  }
}
