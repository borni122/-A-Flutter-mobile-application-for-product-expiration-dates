import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';

Future<void> generateAndUploadBarcode(String idLot, BuildContext context) async {
  try {
    // Créer le widget de code-barres
    BarcodeWidget barcodeWidget = BarcodeWidget(
      barcode: Barcode.code128(), // Type de code-barres Code 128
      data: idLot,
      width: 400,
      height: 100,
      drawText: false,
    );

    // Rendre le widget de code-barres
    RenderRepaintBoundary boundary = await _capturePng(barcodeWidget, context);

    // Convertir l'image en bytes
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    // Télécharger l'image sur Firebase Storage
    String fileName = 'barcodes/$idLot.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = storageRef.putData(
      pngBytes,
      SettableMetadata(contentType: 'image/png'), // Spécifier le type de fichier comme image/png
    );

    // Obtenir l'URL de téléchargement
    TaskSnapshot snapshot = await uploadTask;
    String url = await snapshot.ref.getDownloadURL();

    // Mettre à jour Firestore avec l'URL
    await FirebaseFirestore.instance.collection('lots').doc(idLot).update({'imageurlbarcode': url});
  } catch (e) {
    print('Erreur lors de la capture ou du téléchargement du code-barres: $e');
  }
}

Future<RenderRepaintBoundary> _capturePng(Widget widget, BuildContext context) async {
  RenderRepaintBoundary boundary;

  // Créer une nouvelle clé pour la limite
  GlobalKey key = GlobalKey();

  // Créer un nouveau widget hors écran
  Widget newWidget = RepaintBoundary(
    key: key,
    child: widget,
  );

  // Rendre le widget dans un Overlay hors écran
  OverlayEntry overlayEntry = OverlayEntry(builder: (_) => newWidget);
  Overlay.of(context)!.insert(overlayEntry);

  // Attendre le rendu du widget
  await Future.delayed(Duration(milliseconds: 20));

  // Obtenir la limite
  boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;

  // Supprimer l'entrée de superposition
  overlayEntry.remove();

  return boundary;
}
