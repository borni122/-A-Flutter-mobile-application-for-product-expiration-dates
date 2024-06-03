import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:stockify/view/auth/widgets/CustomDropdownEmplacement.dart';
import 'package:stockify/view/auth/widgets/Customtextfiledemplacemnt.dart';
import 'package:stockify/view/auth/widgets/custom_buttom.dart';

class AddEmplacementScreen extends StatefulWidget {
  @override
  _AddEmplacementScreenState createState() => _AddEmplacementScreenState();
}

class _AddEmplacementScreenState extends State<AddEmplacementScreen> {
  final TextEditingController entrepotController = TextEditingController();
  final TextEditingController lotIdController = TextEditingController();
  int selectedEtagere = 1; // Default value for shelf
  int selectedRayon = 1; // Default value for row
  bool isScanned = false;

  @override
  void initState() {
    super.initState();
    _scanBarcode();
  }

  Future<void> _scanBarcode() async {
    try {
      String result = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', // Color of the scan line
        'Cancel', // Cancel button text
        true, // Whether to show the flash icon
        ScanMode.BARCODE, // Scan mode
      );

      if (result != '-1') {
        setState(() {
          lotIdController.text = result;
          isScanned = true;
        });
      } else {
        setState(() {
          lotIdController.text = 'No barcode found';
          isScanned = false;
        });
      }
    } catch (e) {
      setState(() {
        lotIdController.text = 'Erreur inconnue: $e';
        isScanned = false;
      });
    }
  }

  Future<void> _addEmplacement() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Check if the emplacement already exists
      QuerySnapshot query = await firestore.collection('emplacements')
          .where('entrepot', isEqualTo: entrepotController.text)
          .where('etagere', isEqualTo: selectedEtagere)
          .where('rayon', isEqualTo: selectedRayon)
          .get();

      if (query.docs.isEmpty) {
        // Add new emplacement
        DocumentReference emplacementRef = await firestore.collection('emplacements').add({
          'entrepot': entrepotController.text,
          'etagere': selectedEtagere,
          'rayon': selectedRayon,
        });

        // Update the lot with the emplacement ID
        if (lotIdController.text.isNotEmpty) {
          await firestore.collection('lots').doc(lotIdController.text).update({
            'emplacementId': emplacementRef.id,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nouvel emplacement ajouté')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Emplacement déjà existant')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'ajout de l\'emplacement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un nouvel emplacement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextFormField(
              controller: entrepotController,
              text: 'Entrepôt',
              hint: 'Entrepôt',
              label: 'Entrepôt',
              enabled: true,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Z]'))], // Only allow uppercase A-Z
            ),
            SizedBox(height: 16.0),
            CustomDropdownFormField<int>(
              value: selectedEtagere,
              onChanged: (newValue) {
                setState(() {
                  selectedEtagere = newValue!;
                });
              },
              hint: 'Select Etagere',
              items: List.generate(5, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Etagere ${index + 1}'),
                );
              }),
            ),
            SizedBox(height: 16.0),
            CustomDropdownFormField<int>(
              value: selectedRayon,
              onChanged: (newValue) {
                setState(() {
                  selectedRayon = newValue!;
                });
              },
              items: List.generate(5, (index) {
                return DropdownMenuItem<int>(
                  value: index + 1,
                  child: Text('Rayon ${index + 1}'),
                );
              }),
              hint: 'Rayon',
            ),
            SizedBox(height: 16.0),
            CustomTextFormField(
              controller: lotIdController,
              text: 'Lot ID',
              hint: 'Lot ID',
              label: 'Lot ID',
              enabled: false, inputFormatters: [], // Disable editing of Lot ID field
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: Text('Re-scan QR or barcode'),
            ),
            SizedBox(height: 16.0),
            CustomButton(
              onPress: _addEmplacement,
              text: 'Ajouter l\'emplacement',
            ),

          ],
        ),
      ),
    );
  }
}
