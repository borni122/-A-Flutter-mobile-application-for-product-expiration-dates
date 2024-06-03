import 'package:flutter/material.dart';
import 'custom_text.dart';
import 'package:stockify/constance.dart';

class CustomTextFormField extends StatelessWidget {
  final String text;
  final String hint;
  final void Function(String?)? onSave;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final String label; // <-- Add label parameter here

  const CustomTextFormField({
    required this.text,
    required this.hint,
    this.onSave,
    this.validator,
    required this.controller,
    required this.label, // <-- Add label parameter here
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          CustomText(
            text: text,
            fontSize: 14,
            color: Colors.grey.shade900,
          ),
          TextField(
            controller: controller,
            onSubmitted: onSave,
            onChanged: (value) {
              // You can add any custom logic here
            },
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: primaryColor),
              ),
              labelStyle: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
