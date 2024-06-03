import 'package:flutter/material.dart';
import 'package:stockify/constance.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final String? errorText;
  final String? dropdownValue;

  const CustomDropdownFormField({
    Key? key,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.items,
    this.errorText,
    this.dropdownValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint ?? ''),
      onChanged: onChanged,
      items: items,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor),
        ),
        labelText: dropdownValue ?? '',
        errorText: errorText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor), // Set border color
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: primaryColor), // Set border color
        ),
        labelStyle: TextStyle(color: primaryColor), // Set label text color
      ),
    );
  }
}
