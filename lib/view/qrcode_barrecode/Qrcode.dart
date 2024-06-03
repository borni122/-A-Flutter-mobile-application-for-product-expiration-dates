import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

// Generate and upload a QR Code after adding a product
Future<void> generateAndUploadQRCode(String productId) async {
  final qrValidationResult = QrValidator.validate(
    data: productId,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );

  if (qrValidationResult.status == QrValidationStatus.valid) {
    final qrCode = qrValidationResult.qrCode!;
    final painter = QrPainter.withQr(
      qr: qrCode,
      color: const Color(0xFF000000),
      emptyColor: const Color(0xFFFFFFFF),
      gapless: false,
      embeddedImageStyle: null,
      embeddedImage: null,
    );

    // Render the QR code as an image
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    painter.paint(canvas, Size.square(200));
    final picture = pictureRecorder.endRecording();
    final img = await picture.toImage(200, 200);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();

    // Save the image to a temporary file
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/qr_$productId.png');
    await file.writeAsBytes(buffer);

    // Upload the QR code image to Firebase Storage
    String fileName = 'qr_codes/$productId.png';
    Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

    // Specify the file type when uploading the file
    UploadTask uploadTask = storageRef.putFile(
      file,
      SettableMetadata(contentType: 'image/png'), // Specify the file type here
    );

    TaskSnapshot snapshot = await uploadTask;
    String qrUrl = await snapshot.ref.getDownloadURL();

    // Update the Firestore document with the QR code URL
    await FirebaseFirestore.instance.collection('lots').doc(productId).update({'qrImageUrl': qrUrl});
  }
}
