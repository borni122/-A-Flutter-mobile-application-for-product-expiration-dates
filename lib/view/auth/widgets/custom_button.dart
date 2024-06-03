import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final String hint;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;
  final bool? readOnly;
  final void Function()? onTap;
  final bool? enabled;
  final List<TextInputFormatter>? inputFormatters;

  CustomTextFormField({
    required this.controller,
    required this.text,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: text,
        hintText: hint,
      ),
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      onTap: onTap,
      enabled: enabled,
      inputFormatters: inputFormatters,
    );
  }
}
