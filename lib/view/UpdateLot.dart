import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constance.dart';
import 'auth/widgets/custom_buttom.dart';
import 'auth/widgets/custom_text.dart';
import 'auth/widgets/textfieldCustomUpdate.dart';


class UpdateProductScreen extends StatefulWidget {
  final String productId;
  final String lotId;

  UpdateProductScreen({required this.productId, required this.lotId});

  @override
  _UpdateProductScreenState createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  XFile? _imageFile;
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _dateController = TextEditingController();
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    DocumentSnapshot productSnapshot = await _firestore.collection('produits').doc(widget.productId).get();
    DocumentSnapshot lotSnapshot = await _firestore.collection('lots').doc(widget.lotId).get();

    if (productSnapshot.exists) {
      Map<String, dynamic>? productData = productSnapshot.data() as Map<String, dynamic>?;
      if (productData != null) {
        productNameController.text = productData['nomDeProduit'] ?? '';
        _imageUrl = productData['image'] ?? '';
      }
    }

    if (lotSnapshot.exists) {
      Map<String, dynamic>? lotData = lotSnapshot.data() as Map<String, dynamic>?;
      if (lotData != null) {
        _quantityController.text = lotData['quantite']?.toString() ?? '';
        _selectedDate = lotData['dateExpiration'].toDate();
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Update Product'),
        actions: [
          IconButton(
            icon: Icon(Icons.update),
            onPressed: () {
              _loadInitialData();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.camera_alt),
                              title: CustomText(text: 'Take a photo'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: CustomText(text: 'Choose from gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _getImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                  child: _imageFile != null
                      ? Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  )
                      : _imageUrl.isNotEmpty
                      ? Image.network(_imageUrl, fit: BoxFit.cover)
                      : Icon(
                    Icons.add_photo_alternate,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                controller: productNameController,
                text: 'Product Name',
                hint: 'Enter product name',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
                label: '',
                keyboardType: TextInputType.text,
                readOnly: false,
                onTap: () {}, // Add a default onTap handler
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                controller: _quantityController,
                text: 'Quantity',
                hint: 'Enter quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
                label: '',
                readOnly: false,
                onTap: () {}, // Add a default onTap handler
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                controller: _dateController,
                text: 'Expiration Date',
                hint: 'Select expiration date',
                readOnly: true,
                onTap: () {
                  _selectDate(context);
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please select an expiration date';
                  }
                  return null;
                },
                label: '',
                keyboardType: TextInputType.datetime,
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Update',
                onPress: () async {
                  await _updateProductAndLot();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _updateProductAndLot() async {
    try {
      String? imageUrl = _imageUrl;
      if (_imageFile != null) {
        imageUrl = await _uploadImage(File(_imageFile!.path));
      }

      await _firestore.collection('produits').doc(widget.productId).update({
        'nomDeProduit': productNameController.text,
        'image': imageUrl,
      });

      await _firestore.collection('lots').doc(widget.lotId).update({
        'quantite': int.parse(_quantityController.text),
        'dateExpiration': Timestamp.fromDate(_selectedDate),
      });
    } catch (e) {
      print('Error updating product and lot: $e');
    }
  }

  Future<String> _uploadImage(File imageFile) async {
    try {
      final storageReference = FirebaseStorage.instance
          .ref()
          .child('product_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = storageReference.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }
}
