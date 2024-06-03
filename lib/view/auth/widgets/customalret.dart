import 'package:flutter/material.dart';
import 'custom_buttom.dart';
import 'custom_text.dart';
import 'custom_text_form_field2.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String hintText;
  final TextEditingController controller;
  final VoidCallback onCancelPressed;
  final VoidCallback onConfirmPressed;

  const CustomAlertDialog({
    required this.title,
    required this.content,
    required this.hintText,
    required this.controller,
    required this.onCancelPressed,
    required this.onConfirmPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // Fond blanc
      title: CustomText(
        text: title,
        color: Colors.black, // Texte noir
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(
            text: content,
            color: Colors.black, // Texte noir
          ),
          CustomTextFormField(
            controller: controller,
            text: '', // Remplacez par la valeur du texte si nécessaire
            hint: hintText, // Utilisez le hintText fourni
            label: '', // Remplacez par la valeur du label si nécessaire
            // Autres propriétés CustomTextFormField ici
          ),
          CustomButton( // Utilisez votre CustomButton ici
            onPress: onConfirmPressed, // Définissez l'action sur onConfirmPressed
            text: 'OK', // Texte du bouton
            color: Colors.green, // Couleur du bouton
          ),
        ],
      ),
      actions: [
        CustomButton(
          onPress: onCancelPressed,
            text: 'Annuler',
            color: Colors.green, // Texte noir
          ),
      ],
    );
  }
}
