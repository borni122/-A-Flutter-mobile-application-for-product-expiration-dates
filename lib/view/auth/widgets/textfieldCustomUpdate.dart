import 'package:flutter/material.dart';
import 'custom_text.dart';
import 'package:stockify/constance.dart';

class CustomTextFormField extends StatelessWidget {
  final String text;
  final String hint;
  final void Function(String?)? onSave;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType; // Update keyboardType to be non-nullable

  const CustomTextFormField({
    required this.text,
    required this.hint,
    this.onSave,
    this.validator,
    required this.controller,
    required this.label,
    required this.keyboardType, required bool readOnly, required Null Function() onTap, // Update keyboardType to be non-nullable
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: text,
            fontSize: 14,
            color: Colors.grey.shade900,
          ),
          SizedBox(height: 8), // Add some spacing
          TextField(
            controller: controller,
            onSubmitted: onSave,
            onChanged: (value) {
              // You can add any custom logic here
            },
            keyboardType: keyboardType, // Pass keyboardType to TextField
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.black,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
