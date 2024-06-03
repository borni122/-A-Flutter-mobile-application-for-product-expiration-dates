import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomComboBox extends StatefulWidget {
  final String? selectedBrandId;
  final String? selectedCategoryId;
  final Function(String?) onChanged;

  CustomComboBox({required this.selectedBrandId, required this.selectedCategoryId, required this.onChanged});

  @override
  _CustomComboBoxState createState() => _CustomComboBoxState();
}

class _CustomComboBoxState extends State<CustomComboBox> {
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedBrandId == null || widget.selectedCategoryId == null) {
      return Text('Veuillez d\'abord sélectionner une marque et une catégorie.');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('produits')
          .where('marqueRef', isEqualTo: FirebaseFirestore.instance.collection('marques').doc(widget.selectedBrandId))
          .where('categorieRef', isEqualTo: FirebaseFirestore.instance.collection('categories').doc(widget.selectedCategoryId))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Erreur de snapshot: ${snapshot.error}");
          return Text('Erreur lors du chargement des produits: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CircularProgressIndicator();
        }

        List<String> products = snapshot.data!.docs.map((doc) => doc['nomDeProduit'] as String).toList();

        return DropdownButtonFormField<String>(
          value: _selectedProductId,
          hint: Text('Sélectionnez un produit'),
          onChanged: (String? newValue) {
            setState(() {
              _selectedProductId = newValue;
            });
            widget.onChanged(newValue);
          },
          items: products.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        );
      },
    );
  }
}
