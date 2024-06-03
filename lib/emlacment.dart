import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'ajoutemp.dart'; // Assurez-vous d'importer correctement le fichier ajoutemp.dart
import 'constance.dart'; // Assurez-vous d'importer correctement le fichier constance.dart

class Position extends StatefulWidget {
  @override
  _PositionState createState() => _PositionState();
}

class _PositionState extends State<Position> {
  late List<DocumentSnapshot> products; // Liste des produits, initialisée dans initState
  late int numRows; // Nombre de lignes dans le tableau
  late int numCols; // Nombre de colonnes dans le tableau

  @override
  void initState() {
    super.initState();
    numRows = 5; // Nombre de lignes (rayons)
    numCols = 5; // Nombre de colonnes (étages)
    products = []; // Initialisation de la liste des produits ici
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('emplacements').get();
      setState(() {
        products = querySnapshot.docs;
        print('Nombre de produits récupérés: ${products.length}');
      });
    } catch (e) {
      print('Erreur lors de la récupération des produits: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Emplacements des Produits'),
        ),

        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: numCols,
          ),
          itemCount: numRows * numCols,
          itemBuilder: (context, index) {
            int row = index ~/ numCols +
                1; // Calcul de la ligne (ajout de 1 car Firestore utilise une indexation à partir de 1)
            int col = index % numCols +
                1; // Calcul de la colonne (ajout de 1 car Firestore utilise une indexation à partir de 1)
            // Récupération du produit correspondant à la position dans la grille
            DocumentSnapshot? product = products.firstWhereOrNull(
                    (doc) => doc['rayon'] == row && doc['etagere'] == col);
            // Création du widget pour la case correspondante
            return Container(
              padding: EdgeInsets.all(8.0),
              color: product != null
                  ? Colors.red
                  : Colors.white, // Couleur des cases
              child: product != null
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Plein'),
                  SizedBox(height: 4.0),
                  Text(
                      'Emplacement $row - $col'), // Affichage des valeurs numériques de rayon et etagere
                ],
              )
                  : Center(
                child: Text('Vide'),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEmplacementScreen(),
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: primaryColor, // Définissez la couleur de fond sur la couleur primaire
        ),
      ),
    );
  }
}
