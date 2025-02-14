import 'package:flutter/material.dart';

class OdiaDropdownField extends StatelessWidget {
  final String englishLabel;
  final String odiaLabel;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final bool isLoading;

  const OdiaDropdownField({
    super.key,
    required this.englishLabel,
    required this.odiaLabel,
    required this.items,
    required this.onChanged,
    this.value,
    this.isRequired = true,
    this.validator,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: 'Gilroy-Medium',
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: isLoading ? null : onChanged,
        style: const TextStyle(
          fontFamily: 'Gilroy-Medium',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          labelText: '$englishLabel ($odiaLabel)',
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 14,
          ),
          errorStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Gilroy-Medium',
          ),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: isLoading 
            ? const SizedBox(
                height: 20,
                width: 20,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : null,
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          if (validator != null) {
            return validator!(value);
          }
          return null;
        },
      ),
    );
  }
} 