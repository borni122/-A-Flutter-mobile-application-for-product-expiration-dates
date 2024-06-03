import 'package:cloud_firestore/cloud_firestore.dart';

class Produit {
  String nomDeProduit;
  String image;
  DocumentReference categorieRef; // Référence à la catégorie associée
  DocumentReference marqueRef; // Référence à la marque associée

  Produit({
    required this.nomDeProduit,
    required this.image,
    required this.categorieRef,
    required this.marqueRef,
  });

  // Method to create Produit instance from a Firestore document snapshot
  static Produit fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    return Produit(
      nomDeProduit: data?['nomDeProduit'],
      image: data?['image'],
      categorieRef: data?['categorieRef'],
      marqueRef: data?['marqueRef'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomDeProduit': nomDeProduit,
      'image': image,
      'categorieRef': categorieRef,
      'marqueRef': marqueRef,
    };
  }
}
