import 'package:flutter/material.dart';
import 'package:stockify/constance.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final T? value;
  final String? hint;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final String? errorText;

  const CustomDropdownFormField({
    Key? key,
    required this.value,
    required this.hint,
    required this.onChanged,
    required this.items,
    this.errorText,
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
          borderSide: BorderSide(color: Colors.black), // Set border color
        ),
        labelText: hint ?? '',
        errorText: errorText,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black), // Set border color
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.black), // Set border color
        ),
        labelStyle: TextStyle(color: Colors.black), // Set label text color
      ),
    );
  }
}
