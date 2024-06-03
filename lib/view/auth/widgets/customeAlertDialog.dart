import 'package:flutter/material.dart';

class CustomAlertDialog extends StatelessWidget {
  final String titleText;
  final String contentText;
  final String okButtonText;
  final String cancelButtonText;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? contentColor;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final IconData? iconData;

  const CustomAlertDialog({
    Key? key,
    required this.titleText,
    required this.contentText,
    required this.okButtonText,
    required this.cancelButtonText,
    this.backgroundColor,
    this.titleColor,
    this.contentColor,
    this.buttonColor,
    this.buttonTextColor,
    this.iconData, required Null Function() onOkPressed, required Null Function() onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 0, // Supprimer l'ombre
      backgroundColor: backgroundColor ?? Colors.grey,
      title: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: buttonColor ?? Colors.blue,
        ),
        child: Row(
          children: [
            if (iconData != null) ...[
              Icon(
                iconData,
                size: 40,
                color: Colors.red,
              ),
              SizedBox(width: 8),
            ],
            Text(
              titleText,
              style: TextStyle(fontSize: 18, color: titleColor ?? Colors.red),
            ),
          ],
        ),
      ),
      content: Text(
        contentText,
        style: TextStyle(color: contentColor),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, cancelButtonText),
          child: Text(
            cancelButtonText,
            style: TextStyle(color: buttonTextColor),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, okButtonText),
          child: Text(
            okButtonText,
            style: TextStyle(color: buttonTextColor),
          ),
        ),
      ],
    );
  }  }
