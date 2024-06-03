import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Lot {
  String idLot;
  int quantite;
  Timestamp dateExpiration;
  DocumentReference produitRef;
  DocumentReference fournisseurRef;
  String qrImageUrl;
  String type;
  String emplacementId; // Nouvelle propriété ajoutée

  Lot({
    required this.idLot,
    required this.quantite,
    required this.dateExpiration,
    required this.produitRef,
    required this.fournisseurRef,
    required this.qrImageUrl,
    required this.type,
    required this.emplacementId, // Ajout de la propriété au constructeur
  });

  factory Lot.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    var data = snapshot.data();
    return Lot(
      idLot: data?['idLot'] ?? '',
      quantite: data?['quantite'] ?? 0,
      dateExpiration: data?['dateExpiration'] ?? Timestamp.now(),
      produitRef: data?['produitRef'] ?? FirebaseFirestore.instance.collection('produits').doc(),
      fournisseurRef: data?['fournisseurRef'] ?? FirebaseFirestore.instance.collection('fournisseurs').doc(),
      qrImageUrl: data?['qrImageUrl'] ?? '',
      type: data?['type'] ?? '',
      emplacementId: data?['id_emplacement'] ?? '', // Récupération de la nouvelle propriété
    );
  }

  String formattedExpirationDate() {
    if (dateExpiration == null) {
      return 'Unknown';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateExpiration.toDate());
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'idLot': idLot,
      'quantite': quantite,
      'dateExpiration': dateExpiration,
      'produitRef': produitRef,
      'fournisseurRef': fournisseurRef,
      'qrImageUrl': qrImageUrl,
      'type': type,
      'emplacementId': emplacementId, // Ajout de la nouvelle propriété dans la conversion en Map
    };
  }
}


