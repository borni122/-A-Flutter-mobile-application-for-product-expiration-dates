import 'package:flutter/material.dart';
import 'package:stockify/constance.dart';
import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function onPress;
  final bool isDisabled;

  CustomButton({
    required this.onPress,
    this.text = 'Write text',
    this.color = primaryColor,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: isDisabled ? Colors.grey : color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: EdgeInsets.all(18),
      ),
      onPressed: isDisabled ? null : () => onPress(),
      child: CustomText(
        alignment: Alignment.center,
        text: text,
        color: Colors.white,
      ),
    );
  }
}
