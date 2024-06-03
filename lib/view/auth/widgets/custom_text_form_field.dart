import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constance.dart';
import '../../../constant.dart';
import 'custom_text.dart';

class CustomTextFormField extends StatefulWidget {
  final String text;
  final String hint;
  final Function? onSave;
  final Function? validator;
  final bool isPassword;
  final bool isEmail;
  final bool isUser;

  const CustomTextFormField({
    Key? key,
    required this.text,
    required this.hint,
    this.onSave,
    this.validator,
    this.isPassword = false, // Default to false, can be overridden
    this.isEmail = false, // Default to false, can be overridden
    this.isUser = false, // Default to false, can be overridden
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _isObscured = widget.isPassword;  // Start obscured if it's a password field
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: widget.text,
          fontSize: 14,
          color: Colors.grey.shade900,
        ),
        TextFormField(
          controller: _controller,
          obscureText: widget.isPassword ? _isObscured : false, // Only obscure if it's a password field
          keyboardType: widget.isEmail ? TextInputType.emailAddress : TextInputType.text, // Set keyboard type for email field
          onSaved: widget.onSave as void Function(String?)?,
          validator: widget.validator as String? Function(String?)?,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: myColor), // Set border color to myColor
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: myColor), // Set focused border color to myColor
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0),
              borderSide: BorderSide(color: myColor), // Set focused error border color to myColor
            ),
            labelStyle: TextStyle(color: myColor), // Set label color to myColor
            prefixIcon: widget.isEmail ? Icon(Icons.email, color: myColor) :
            (widget.isPassword ? Icon(Icons.lock, color: myColor) :
            (widget.isUser ? Icon(Icons.person, color: myColor) : null)), // Set prefix icon based on field type
            suffixIcon: widget.isPassword ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility : Icons.visibility_off,
                color: myColor, // Set suffix icon color to myColor
              ),
              onPressed: _togglePasswordVisibility,
            ) : null, // Only show suffix icon for password field
          ),
          style: TextStyle(color: Colors.black), // Set text color to myColor
        ),
      ],
    );
  }
}
