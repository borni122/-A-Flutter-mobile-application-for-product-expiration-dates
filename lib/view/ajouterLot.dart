import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../constance.dart';
import 'auth/widgets/custom_buttom.dart';
import 'auth/widgets/custom_text.dart';
import 'auth/widgets/custom_text_form_field2.dart';
import 'auth/widgets/Custom_DropdownButtonFormField.dart';
import 'auth/widgets/custom_ComboBox.dart';
import 'package:stockify/view/qrcode_barrecode/Qrcode.dart';
import 'package:stockify/view/qrcode_barrecode/barrecode.dart';
import 'auth/widgets/fournniseurcustom.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  XFile? _imageFile;
  final TextEditingController _newProductController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _selectedBrandId;
  String? _selectedCategoryId;
  String? _selectedSupplier;
  bool _isExpired = false;
  Color _checkboxColor = primaryColor;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _brands = [];
  late List<String> _suppliers = [];
  List<Map<String, dynamic>> _categories = [];
  TextEditingController _dateController = TextEditingController();
  String? _selectedBrandError;
  String? _selectedCategoryError;
  String? _selectedSupplierError;
  String? _selectedProductId;
  bool _showNewProductTextField = false;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadSuppliers();
    _loadCategories();
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
  }

  Future<void> _loadBrands() async {
    final QuerySnapshot brandSnapshot = await _firestore.collection('marques').get();
    setState(() {
      _brands = brandSnapshot.docs.map((doc) => {'id': doc.id, 'nom': doc.get('nomDeMarque')}).toList();
    });
  }

  Future<void> _loadSuppliers() async {
    final QuerySnapshot supplierSnapshot = await _firestore.collection('fournisseurs').get();
    setState(() {
      _suppliers = supplierSnapshot.docs.map((doc) => doc.get('nomFournisseur') as String).toList();
    });
  }


  Future<void> _loadCategories() async {
    final QuerySnapshot categorySnapshot = await _firestore.collection('categories').get();
    setState(() {
      _categories = categorySnapshot.docs.map((doc) => {'id': doc.id, 'nom': doc.get('nomDeCategorie')}).toList();
    });
  }

  Future<void> _loadBrandCategories(String brandId) async {
    // Chargez les catégories en fonction de l'ID de la marque dans la collection "marque_catégorie"
    final QuerySnapshot categorySnapshot = await _firestore
        .collection('marque_catégorie')
        .where('marqueId', isEqualTo: brandId)
        .get();

    // Obtenez une liste des ID de catégorie pour cette marque
    List<String> categoryIds = categorySnapshot.docs
        .map((doc) => (doc.data() as Map<String, dynamic>)['categorieIds'] as List<dynamic>)
        .expand((ids) => ids.map((id) => id as String))
        .toList();

    // Chargez les détails des catégories en fonction des ID récupérés
    List<Map<String, dynamic>> categories = [];
    for (String categoryId in categoryIds) {
      final DocumentSnapshot categoryDoc = await _firestore.collection('categories').doc(categoryId).get();
      if (categoryDoc.exists) {
        categories.add({'id': categoryId, 'nom': categoryDoc.get('nomDeCategorie')});
      }
    }

    setState(() {
      _categories = categories;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Add Product'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // This will pop the current screen and go back to the previous one
          },
        ),
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
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey[300],
                  child: _selectedProductId != null || _newProductController.text.isNotEmpty
                      ? _buildProductImage(_selectedProductId ?? _newProductController.text) ?? Placeholder()
                      : (_imageFile != null
                      ? Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  )
                      : Icon(
                    Icons.add_photo_alternate,
                    size: 60,
                  )),
                ),
              ),
              SizedBox(height: 20),
              CustomDropdownFormField<String>(
                value: _selectedBrandId,
                hint: 'Marque de produit',
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedBrandId = newValue;
                      _selectedBrandError = null;
                      // Réinitialiser le produit sélectionné lorsque la marque change
                      _selectedProductId = null;
                      // Charger les catégories correspondant à la marque sélectionnée
                      _loadBrandCategories(newValue);
                    });
                  }
                },
                items: _brands.map((brand) {
                  return DropdownMenuItem<String>(
                    value: brand['id'],
                    child: CustomText(text: brand['nom'] as String),
                  );
                }).toList(),
                errorText: _selectedBrandError,
              ),
              SizedBox(height: 20),
              CustomDropdownFormField<String>(
                value: _selectedCategoryId,
                hint: 'Catégorie de produit',
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategoryId = newValue;
                    _selectedCategoryError = null;
                    // Réinitialiser le produit sélectionné lorsque la catégorie change
                    _selectedProductId = null;
                  });
                },
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'],
                    child: CustomText(text: category['nom'] as String),
                  );
                }).toList(),
                errorText: _selectedCategoryError,
              ),
              SizedBox(height: 20),
              _buildProductComboBox(),
              SizedBox(height: 20),
              _showNewProductTextField
                  ? CustomTextFormField(
                controller: _newProductController,
                hint: 'Enter new product name',
                label: 'New Product',
                text: '',
              )
                  : Container(),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: CustomText(text: 'EXPIRABLE'),
                      leading: Checkbox(
                        value: _isExpired,
                        onChanged: (bool? value) {
                          setState(() {
                            _isExpired = value!;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor: _checkboxColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: CustomText(text: 'NON EXPIRABLE'),
                      leading: Checkbox(
                        value: !_isExpired,
                        onChanged: (bool? value) {
                          setState(() {
                            _isExpired = !value!;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor: _checkboxColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              CustomDropdownFormFieldFournniseur<String>(
                value: _selectedSupplier,
                hint: 'Fournisseur',
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSupplier = newValue;
                    _selectedSupplierError = null;
                  });
                },
                items: _suppliers, // Utilisez la liste des noms des fournisseurs
                errorText: _selectedSupplierError,
              ),


              SizedBox(height: 20),
              CustomTextFormField(
                controller: _quantityController,
                hint: 'Quantité',
                text: '',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une quantité';
                  }
                  return null;
                },
                label: '',
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _selectDate(context);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: 'Date:',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                onPress: () {
                  _saveProduct();
                },
                text: 'ENREGISTRER',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductComboBox() {
    if (_selectedBrandId == null || _selectedCategoryId == null) {
      return CustomText(text: 'Veuillez d\'abord sélectionner une marque et une catégorie.');
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('produits')
          .where('marqueRef', isEqualTo: _firestore.collection('marques').doc(_selectedBrandId))
          .where('categorieRef', isEqualTo: _firestore.collection('categories').doc(_selectedCategoryId))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("Erreur de snapshot: ${snapshot.error}");
          return CustomText(text: 'Erreur lors du chargement des produits: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          );
          // Afficher un indicateur de chargement
        }

        List<String> products = snapshot.data!.docs.map((doc) => doc['nomDeProduit'] as String).toList();
        print("Produits: $products");

        return Row(
          children: [
            Expanded(
              child: CustomDropdownFormField<String>(
                value: _selectedProductId,
                hint: 'Sélectionnez un produit',
                onChanged: (String? newValue) {
                  print("Produit sélectionné: $newValue");
                  setState(() {
                    _selectedProductId = newValue;
                  });
                },
                // Utiliser les noms de produits pour créer les éléments du menu déroulant
                items: products.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: CustomText(text: value),
                  );
                }).toList(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _showNewProductTextField = true; // Afficher le champ de texte pour ajouter un nouveau produit
                  _selectedProductId = null; // Réinitialiser le produit sélectionné
                });
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: primaryColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: source);
      setState(() {
        _imageFile = image;
      });
    } catch (e) {
      print('Error retrieving image: $e');
    }
  }

  Future<void> _saveProduct() async {
    // Check if the product already exists
    if (_selectedProductId != null && _selectedProductId != 'Ajouter un nouveau produit') {
      QuerySnapshot productSnapshot =
      await _firestore.collection('produits').where('nomDeProduit', isEqualTo: _selectedProductId).get();
      if (productSnapshot.docs.isNotEmpty) {
        // Product already exists, proceed to add lot
        String productId = productSnapshot.docs.first.id;
        await _saveLot(productId);
      } else {
        // Product does not exist, proceed to add product and lot
        await _saveNewProductAndLot();
      }
    } else {
      // New product entered, proceed to add product and lot
      await _saveNewProductAndLot();
    }
  }

  Future<void> _saveNewProductAndLot() async {
    try {
      // Upload image
      String imageUrl = await uploadImageToStorage(_imageFile!);

      // Get ID of selected category
      String categoryId = _selectedCategoryId!;

      // Get ID of selected brand
      String brandId = _selectedBrandId!;

      // Add product
      DocumentReference productRef = await _firestore.collection('produits').add({
        'nomDeProduit': _newProductController.text, // Use selected product or new product text
        'image': imageUrl,
        'categorieRef': _firestore.collection('categories').doc(categoryId),
        'marqueRef': _firestore.collection('marques').doc(brandId),
      });

      // Save lot
      await _saveLot(productRef.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product and lot saved successfully')),
      );
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product')),
      );
    }
  }

  Future<void> _saveLot(String productId) async {
    try {
      // Convert date to Timestamp if _selectedDate is a DateTime
      Timestamp expirationTimestamp = _selectedDate is DateTime
          ? Timestamp.fromDate(_selectedDate)
          : Timestamp.now(); // If _selectedDate is null, use current date

      // Add lot
      DocumentReference lotRef = _firestore.collection('lots').doc(); // Create a new document reference
      await lotRef.set({
        'quantite': int.parse(_quantityController.text),
        'dateExpiration': expirationTimestamp,
        'produitRef': _firestore.collection('produits').doc(productId),
        'fournisseurRef': _firestore.collection('fournisseurs').doc(_selectedSupplier),
        'type': _isExpired ? 'Expired' : 'Non Expired',
        'idemplacement': '',
      });

      // Get ID of added lot
      String lotId = lotRef.id;

      // Generate and upload QR code
      await generateAndUploadQRCode(lotId);
      await generateAndUploadBarcode(lotId, context);
    } catch (error) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving lot')),
      );
    }
  }

  Future<String> uploadImageToStorage(XFile image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref = storage.ref().child('product_images/${DateTime.now().millisecondsSinceEpoch}');

    // Set metadata for file
    SettableMetadata metadata = SettableMetadata(contentType: 'image/png'); // Specify image type here

    // Upload file with metadata
    UploadTask uploadTask = ref.putFile(File(image.path), metadata);

    // Wait for upload to finish
    TaskSnapshot snapshot = await uploadTask;

    // Get download URL
    return await snapshot.ref.getDownloadURL();
  }

  Future<String?> getProductImageUrl(String productName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('produits')
          .where('nomDeProduit', isEqualTo: productName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.get('image');
      }
    } catch (error) {
      print('Error fetching product image URL: $error');
    }
    return null;
  }

  Widget _buildProductImage(String? productName) {
    if (productName == null) {
      // Retournez un widget vide lorsque productName est null
      return Container();
    }

    return FutureBuilder<String?>(
      future: getProductImageUrl(productName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          );

        } else if (snapshot.hasError || snapshot.data == null) {
          return Icon(Icons.image_not_supported); // Default icon if there's an error or no image available
        } else {
          return Image.network(
            snapshot.data!,
            width: MediaQuery.of(context).size.width, // Utilisez la largeur de l'écran comme largeur de l'image
            height: MediaQuery.of(context).size.height, // Utilisez la hauteur de l'écran comme hauteur de l'image
            fit: BoxFit.cover, // Ajustez l'image pour couvrir toute la taille du conteneur
          );
        }
      },
    );
  }


}



