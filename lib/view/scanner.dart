import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../core/modele/LotsModel.dart';
import '../core/modele/ProductModle.dart';

class ScannerPage extends StatefulWidget {
  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  String _scanResult = '';
  AudioPlayer _audioPlayer = AudioPlayer();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Lot? _currentLot;
  Produit? _currentProduit;

  @override
  void initState() {
    super.initState();
    _scanBarcode(); // Appeler la fonction de numérisation dès que la page est créée
  }

  Future<void> _scanBarcode() async {
    String scanResult = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.BARCODE);
    if (!mounted) return;

    if (scanResult != '-1') {
      await _audioPlayer.play(AssetSource('audio/BEEP_Bip de caisse (ID 1417)_LS.mp3'));
      setState(() {
        _scanResult = scanResult;
      });
      _fetchLotDetails(scanResult);
    } else {
      setState(() {
        _scanResult = 'Scan cancelled';
      });
    }
  }

  Future<void> _fetchLotDetails(String idLot) async {
    DocumentSnapshot<Map<String, dynamic>> lotSnapshot =
    await _firestore.collection('lots').doc(idLot).get().then((doc) => doc as DocumentSnapshot<Map<String, dynamic>>);

    Lot lot = Lot.fromFirestore(lotSnapshot);

    DocumentSnapshot<Map<String, dynamic>> produitSnapshot =
    await lot.produitRef.get().then((doc) => doc as DocumentSnapshot<Map<String, dynamic>>);

    Produit produit = Produit.fromFirestore(produitSnapshot);

    setState(() {
      _currentLot = lot;
      _currentProduit = produit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR & Barcode Scanner'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scan Result:',
            ),
            Text(
              _scanResult,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _currentLot != null && _currentProduit != null ? _buildLotInfo() : Container(),
          ],
        ),
      ),
      floatingActionButton: _scanResult.isNotEmpty
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _scanResult = '';
            _currentLot = null;
            _currentProduit = null;
          });
        },
        child: Icon(Icons.arrow_back),
      )
          : Container(), // Hide the FloatingActionButton if scan result is empty
    );
  }

  Widget _buildLotInfo() {
    return Expanded(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            child: Image.network(
              _currentProduit!.image,
              height: 300.0, // Large size for the image
              fit: BoxFit.cover,
            ),
          ),
          ListTile(
            title: Text('Produit:'),
            subtitle: Text(_currentProduit!.nomDeProduit),
          ),
          ListTile(
            title: Text('Quantité:'),
            subtitle: Text('${_currentLot!.quantite}'),
          ),
          ListTile(
            title: Text('Date expiration:'),
            subtitle: Text(_currentLot!.formattedExpirationDate()),
          ),
        ],
      ),
    );
  }
}
