import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OdiaTextField extends StatelessWidget {
  final String englishLabel;
  final String odiaLabel;
  final String? value;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final int? maxLength;
  final int? maxLines;
  final Widget? suffix;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final bool alignLabelWithHint;

  const OdiaTextField({
    super.key,
    required this.englishLabel,
    required this.odiaLabel,
    required this.onChanged,
    this.value,
    this.isRequired = true,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.maxLength,
    this.maxLines = 1,
    this.suffix,
    this.textAlign = TextAlign.left,
    this.contentPadding,
    this.alignLabelWithHint = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        readOnly: readOnly,
        maxLength: maxLength,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textAlign: textAlign,
        style: const TextStyle(
          fontFamily: 'Gilroy-Medium',
          fontSize: 14, // Fixed size
        ),
        decoration: InputDecoration(
          labelText: '$englishLabel ($odiaLabel)',
          labelStyle: const TextStyle(
            fontFamily: 'Gilroy-Medium',
            fontSize: 14,
          ),
          alignLabelWithHint: alignLabelWithHint,
          border: const OutlineInputBorder(),
          contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          counterText: '',
          suffix: suffix,
          errorStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontFamily: 'Gilroy-Medium',
          ),
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