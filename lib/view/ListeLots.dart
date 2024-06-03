import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stockify/view/auth/widgets/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stockify/view/auth/widgets/CustomTextFieldRecherche.dart';
import '../../../core/modele/LotsModel.dart';
import '../../../core/modele/ProductModle.dart';
import '../constance.dart';
import '../constant.dart';
import 'UpdateLot.dart';
import 'addcategorieetmarqueetlaison.dart';
import 'ajouterLot.dart';
import 'auth/widgets/customeAlertDialog.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // Import syncfusion_flutter_pdf
import 'package:printing/printing.dart';

class listeLot extends StatefulWidget {
  @override
  _listeLot createState() => _listeLot();
}

class _listeLot extends State<listeLot> {
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  String sanitizeString(String input) {
    return input.replaceAllMapped(
      RegExp(r'[^\u0000-\uD7FF\uE000-\uFFFF]'),
          (match) {
        // Replace non-UTF-16 characters with placeholders
        return '[INVALID CHARACTER]';
      },
    );
  }


  Future<String> getProductName(DocumentReference produitRef) async {
    final produitDoc = await produitRef.get();
    final produitData = produitDoc.data() as Map<String, dynamic>;
    return sanitizeString(produitData['nomDeProduit'] ?? 'Unknown');
  }

  Future<Map<String, String>> getProductNames(List<DocumentSnapshot> lotDocs) async {
    final productNames = <String, String>{};
    for (final lotDoc in lotDocs) {
      final lot = Lot.fromFirestore(lotDoc as DocumentSnapshot<Map<String, dynamic>>);
      final productName = await getProductName(lot.produitRef);
      productNames[lot.produitRef.id] = productName;
    }
    return productNames;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste Produits de Lots'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () async {
              // Fetch lot and product data
              final lots = await FirebaseFirestore.instance.collection('lots').get();
              final productDetails = await getProductDetails(lots.docs);

              // Generate PDF
              final pdfData = await generatePDF(lots.docs.map((e) => Lot.fromFirestore(e as DocumentSnapshot<Map<String, dynamic>>)).toList(), productDetails);

              // Print PDF
              await Printing.layoutPdf(onLayout: (format) async => pdfData);
            },
          ),
        ],
      ),
      backgroundColor: myColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomTextFieldRecherche(
            onChanged: (newQuery) {
              setState(() {
                searchQuery = newQuery;
              });
            },
            hintText: 'Rechercher par nom de produit',
          ),
          Padding(
            padding: const EdgeInsets.all(12.15),
            child: Text(
              'Tous les lots disponibles ',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('lots').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> lotSnapshot) {
                if (lotSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (lotSnapshot.hasError) {
                  return Center(child: Text('Error: ${lotSnapshot.error}'));
                }

                // Fetch product names asynchronously for all lots
                return FutureBuilder<Map<String, String>>(
                  future: getProductNames(lotSnapshot.data!.docs),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final productNames = snapshot.data!;

                    // Filter lots based on product names
                    final filteredLots = searchQuery.isEmpty
                        ? lotSnapshot.data!.docs
                        : lotSnapshot.data!.docs.where((lotDoc) {
                      final lot = Lot.fromFirestore(lotDoc as DocumentSnapshot<Map<String, dynamic>>);
                      final productName = productNames[lot.produitRef.id]?.toLowerCase() ?? '';
                      return productName.contains(searchQuery.toLowerCase());
                    }).toList();

                    return filteredLots.isEmpty
                        ? Center(
                      child: Icon(
                        Icons.search_off,
                        size: 100,
                        color: Colors.grey,
                      ),
                    )
                        : ListView.builder(
                      itemCount: filteredLots.length,
                      itemBuilder: (context, index) {
                        final lot = Lot.fromFirestore(filteredLots[index] as DocumentSnapshot<Map<String, dynamic>>);
                        return buildLotItem(lot, index, lotSnapshot);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddDataScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: primaryColor, // Set the background color to the primary color
      ),
    );
  }

  Widget buildLotItem(Lot lot, int index, AsyncSnapshot<QuerySnapshot> lotSnapshot) {
    var remainingDays = lot.dateExpiration != null ? lot.dateExpiration.toDate().difference(DateTime.now()).inDays : null;
    var status = getStatus(remainingDays);
    var color = getStatusColor(remainingDays);

    return FutureBuilder(
      future: FirebaseFirestore.instance.collection('produits').doc(lot.produitRef.id).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> produitSnapshot) {
        if (produitSnapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF099b6c)),
            ),
          );
        }
        if (produitSnapshot.hasError) {
          return Center(child: Text('Error: ${produitSnapshot.error}'));
        }
        var produitData = Produit.fromFirestore(produitSnapshot.data!);
        return Column(
          children: [
            Container(
              height: 50,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  Text(
                    status,
                    style: TextStyle(fontSize: 14),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UpdateProductScreen(productId: '', lotId: '',),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return CustomAlertDialog(
                            titleText: "Confirmation",
                            contentText: "Voulez-vous vraiment supprimer ce lot ?",
                            okButtonText: "Supprimer",
                            cancelButtonText: "Annuler",
                            buttonColor: Color(0xFF099b6c),
                            backgroundColor: Colors.grey,
                            buttonTextColor: Colors.black,
                            onOkPressed: () {
                              String? lotDocumentId = lotSnapshot.data!.docs[index].id;
                              if (lotDocumentId != null && lotDocumentId.isNotEmpty) {
                                deleteLot(lotDocumentId);
                                Navigator.of(context).pop(); // Close the dialog
                              } else {
                                print('Error: The document ID is null or empty.');
                              }
                            },
                            onCancelPressed: () {
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Image.network(
                      produitData.image ?? 'https://via.placeholder.com/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Column(
                        children: [
                          Text(
                            sanitizeString(produitData.nomDeProduit ?? 'Unknown'),
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(height: 4),
                          CustomText(
                            text: lot.idLot ?? 'Unknown',
                            fontSize: 12,
                          ),
                          SizedBox(height: 4),
                          CustomText(
                            text: lot.quantite?.toString() ?? 'Unknown',
                            fontSize: 12,
                          ),
                          SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.only(left: 11, top: 20),
                            child: CustomText(
                              text: lot.dateExpiration != null ? '${lot.dateExpiration.toDate().day}/${lot.dateExpiration.toDate().month}/${lot.dateExpiration.toDate().year}' : 'Unknown',
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Image.network(
                        lot.qrImageUrl ?? 'https://via.placeholder.com/150',
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteLot(String? documentId) {
    if (documentId == null || documentId.isEmpty) {
      print('ID du document est nul ou vide');
      return;
    }

    FirebaseFirestore.instance.collection('lots').doc(documentId).delete().then((_) {
      print('Lot supprimé avec succès');
    }).catchError((error) {
      print('Erreur lors de la suppression du lot: $error');
    });
  }

  String getStatus(int? days) {
    if (days == null) return 'vide';
    if (days <= 0) return 'Expiré';
    if (days == 3) return '3 jours restant';
    if (days == 6) return '6 jours restant';
    return 'Il reste plus de 6 jours';
  }

  Color getStatusColor(int? days) {
    if (days == null) return Colors.grey;
    if (days <= 0) return Colors.red;
    if (days == 3) return Colors.orange;
    if (days == 6) return Colors.green;
    return Colors.blue; // Couleur par défaut pour plus de 6 jours restants
  }

  Future<Map<String, Produit>> getProductDetails(List<DocumentSnapshot> lotDocs) async {
    final productDetails = <String, Produit>{};
    for (final lotDoc in lotDocs) {
      final lot = Lot.fromFirestore(lotDoc as DocumentSnapshot<Map<String, dynamic>>);
      final productSnapshot = await lot.produitRef.get();
      productDetails[lot.produitRef.id] = Produit.fromFirestore(productSnapshot as DocumentSnapshot<Map<String, dynamic>>);
    }
    return productDetails;
  }
  Future<Uint8List> generatePDF(List<Lot> lots, Map<String, Produit> productDetails) async {
    final pdf = PdfDocument();
    final page = pdf.pages.add();

    // Add title
    final titleFormat = PdfStringFormat(alignment: PdfTextAlignment.center);
    page.graphics.drawString(
        'Liste des Lots',
        PdfStandardFont(PdfFontFamily.timesRoman, 20),
        bounds: Rect.fromLTWH(0, 0, page.getClientSize().width, 40),
        format: titleFormat
    );

    // Add lot details
    double y = 50;
    for (final lot in lots) {
      final produitData = productDetails[lot.produitRef.id]!;
      page.graphics.drawImage(
          PdfBitmap(await networkImageToByteList(lot.qrImageUrl ?? 'https://via.placeholder.com/150')),
          Rect.fromLTWH(0, y, 50, 50)
      );
      page.graphics.drawImage(
          PdfBitmap(await networkImageToByteList(produitData.image ?? 'https://via.placeholder.com/150')),
          Rect.fromLTWH(60, y, 50, 50)
      );
      page.graphics.drawString(
          'Nom de Produit: ${sanitizeString(produitData.nomDeProduit ?? 'Unknown')}',
          PdfStandardFont(PdfFontFamily.timesRoman, 12),
          bounds: Rect.fromLTWH(120, y, 200, 20)
      );
      page.graphics.drawString(
          'ID Lot: ${sanitizeString(lot.idLot ?? 'Unknown')}',
          PdfStandardFont(PdfFontFamily.timesRoman, 12),
          bounds: Rect.fromLTWH(120, y + 20, 200, 20)
      );
      page.graphics.drawString(
          'Quantité: ${sanitizeString(lot.quantite?.toString() ?? 'Unknown')}',
          PdfStandardFont(PdfFontFamily.timesRoman, 12),
          bounds: Rect.fromLTWH(120, y + 40, 200, 20)
      );
      page.graphics.drawString(
          'Date d\'expiration: ${lot.dateExpiration != null ? '${lot.dateExpiration.toDate().day}/${lot.dateExpiration.toDate().month}/${lot.dateExpiration.toDate().year}' : 'Unknown'}',
          PdfStandardFont(PdfFontFamily.timesRoman, 12),
          bounds: Rect.fromLTWH(120, y + 60, 200, 20)
      );
      y += 90;
    }

    // Save PDF to bytes
    final bytes = await pdf.save();
    pdf.dispose();
    return Uint8List.fromList(bytes);
  }

  Future<Uint8List> networkImageToByteList(String url) async {
    final response = await NetworkAssetBundle(Uri.parse(url)).load(url);
    return response.buffer.asUint8List();
  }
}
