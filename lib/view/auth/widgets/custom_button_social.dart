import 'package:flutter/material.dart';
import 'custom_text.dart';

class CustomButtonSocial extends StatelessWidget {
  final String text;
  final String imageName;
  final Function onPress;

  CustomButtonSocial({
    required this.text,
    required this.imageName,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Colors.grey.shade50,
      ),
      child: TextButton(
        onPressed: () => onPress(),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Row(
          children: [
            Image.asset(imageName),
            SizedBox(width: 10), // Adjusted to a smaller fixed width
            Expanded( // Expanded widget to take up remaining space
              child: CustomText(
                text: text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
