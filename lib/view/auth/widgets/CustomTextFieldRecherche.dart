import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../constance.dart';
import '../../scanner.dart';

class CustomTextFieldRecherche extends StatelessWidget {
  final Function(String) onChanged;
  final String hintText;

  // Ajouter un constructeur pour passer le contrôleur et le rappel onChanged
  CustomTextFieldRecherche({required this.onChanged, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        color: Colors.white,
        height: 60.0,
        child: TextField(
          onChanged: onChanged, // Connecter le rappel onChanged
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.black,
            ),
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton( // Utilisez un IconButton au lieu d'un Icon
              icon: Icon(Icons.qr_code),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ScannerPage(), // Redirection vers la page de scanner
                  ),
                );
              },
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: primaryColor), // Couleur de la bordure
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: primaryColor), // Couleur de la bordure lorsqu'il est en focus
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.0),
              borderSide: BorderSide(color: primaryColor), // Couleur de la bordure en cas d'erreur
            ),
            labelStyle: TextStyle(color: primaryColor), // Couleur du texte de l'étiquette
          ),
        ),
      ),
    );
  }
}
