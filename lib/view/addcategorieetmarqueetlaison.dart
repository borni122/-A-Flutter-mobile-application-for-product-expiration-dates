import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/modele/catégorie.dart';
import '../core/modele/marque.dart';
import 'addfournniseur.dart';
import 'auth/widgets/Custom_DropdownButtonFormField.dart';
import 'auth/widgets/custom_buttom.dart';
import 'auth/widgets/custom_text.dart';
import 'auth/widgets/customalret.dart';

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final TextEditingController marqueController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  List<Categorie> selectedCategories = [];
  List<Marque> marquesOptions = [];
  List<Categorie> categoriesOptions = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      await _getMarqueOptions();
      await _getCategoriesOptions();
    } catch (e) {
      _showErrorSnackBar('Error fetching data: $e');
    }
  }

  Future<void> _getMarqueOptions() async {
    QuerySnapshot marqueSnapshot = await FirebaseFirestore.instance.collection('marques').get();
    setState(() {
      marquesOptions = marqueSnapshot.docs.map((doc) => Marque(
        id: doc.id,
        nomDeMarque: doc['nomDeMarque'] as String,
      )).toList();
    });
  }

  Future<void> _getCategoriesOptions() async {
    QuerySnapshot categorieSnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categoriesOptions = categorieSnapshot.docs.map((doc) => Categorie(
        id: doc.id,
        nomDeCategorie: doc['nomDeCategorie'] as String,
      )).toList();
    });
  }

  void _addData() async {
    try {
      Marque selectedMarque = marquesOptions.firstWhere((m) => m.nomDeMarque == marqueController.text);

      final List<String> selectedCategoryIds = selectedCategories.map((category) => category.id).toList();

      await FirebaseFirestore.instance.collection('marque_catégorie').add({
        'marqueId': selectedMarque.id,
        'categorieIds': selectedCategoryIds,
      });

      marqueController.clear();
      selectedCategories.clear();

      _showSuccessSnackBar('Enregistrement réussi');
    } catch (e) {
      _showErrorSnackBar('Une erreur est survenue lors de l\'enregistrement.');
    }
  }

  void _addNewMarque() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Ajouter une nouvelle marque',
          content: 'Nom de la marque',
          hintText: 'Nom de la marque',
          controller: marqueController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              DocumentReference newMarqueRef = await FirebaseFirestore.instance.collection('marques').add({
                'nomDeMarque': marqueController.text,
              });
              setState(() {
                marquesOptions.add(Marque(id: newMarqueRef.id, nomDeMarque: marqueController.text));
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error adding marque: $e');
            }
          },
        );
      },
    );
  }

  void _addNewCategorie() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Ajouter une nouvelle catégorie',
          content: 'Nom de la catégorie',
          hintText: 'Nom de la catégorie',
          controller: categorieController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              DocumentReference newCategorieRef = await FirebaseFirestore.instance.collection('categories').add({
                'nomDeCategorie': categorieController.text,
              });
              setState(() {
                categoriesOptions.add(Categorie(id: newCategorieRef.id, nomDeCategorie: categorieController.text));
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error adding categorie: $e');
            }
          },
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Marque & Catégorie'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomText(
              text: 'Ajouter nom de marque',
              fontSize: 16.0,
              color: Colors.black,
              alignment: Alignment.topLeft,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildMarqueDropdown(),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNewMarque,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            CustomText(
              text: 'Sélectionner catégories',
              fontSize: 16.0,
              color: Colors.black,
              alignment: Alignment.topLeft,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildCategoriesDropdown(),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNewCategorie,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            CustomButton(
              text: 'Enregistrer',
              onPress: _addData,
            ),
            SizedBox(height: 16.0),
            CustomButton(
              text: 'Suivant',
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFournisseurScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueDropdown() {
    return CustomDropdownFormField<Marque>(
      value: null,
      hint: 'Sélectionner une marque',
      onChanged: (newValue) {
        setState(() {
          marqueController.text = newValue!.nomDeMarque;
        });
      },
      items: marquesOptions.map((marque) {
        return DropdownMenuItem<Marque>(
          value: marque,
          child: Text(marque.nomDeMarque),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesDropdown() {
    return Wrap(
      children: categoriesOptions.map((categorie) {
        return CheckboxListTile(
          title: Text(categorie.nomDeCategorie),
          value: selectedCategories.contains(categorie),
          onChanged: (bool? value) {
            setState(() {
              if (value!) {
                selectedCategories.add(categorie);
              } else {
                selectedCategories.remove(categorie);
              }
            });
          },
          checkColor: Colors.white,
          activeColor: Colors.green,
        );
      }).toList(),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/modele/catégorie.dart';
import '../core/modele/marque.dart';
import 'addfournniseur.dart';
import 'auth/widgets/Custom_DropdownButtonFormField.dart';
import 'auth/widgets/custom_buttom.dart';
import 'auth/widgets/custom_text.dart';
import 'auth/widgets/customalret.dart';

class AddDataScreen extends StatefulWidget {
  @override
  _AddDataScreenState createState() => _AddDataScreenState();
}

class _AddDataScreenState extends State<AddDataScreen> {
  final TextEditingController marqueController = TextEditingController();
  final TextEditingController categorieController = TextEditingController();
  List<Categorie> selectedCategories = [];
  List<Marque> marquesOptions = [];
  List<Categorie> categoriesOptions = [];

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    try {
      await _getMarqueOptions();
      await _getCategoriesOptions();
    } catch (e) {
      _showErrorSnackBar('Error fetching data: $e');
    }
  }

  Future<void> _getMarqueOptions() async {
    QuerySnapshot marqueSnapshot = await FirebaseFirestore.instance.collection('marques').get();
    setState(() {
      marquesOptions = marqueSnapshot.docs.map((doc) => Marque(
        id: doc.id,
        nomDeMarque: doc['nomDeMarque'] as String,
      )).toList();
    });
  }

  Future<void> _getCategoriesOptions() async {
    QuerySnapshot categorieSnapshot = await FirebaseFirestore.instance.collection('categories').get();
    setState(() {
      categoriesOptions = categorieSnapshot.docs.map((doc) => Categorie(
        id: doc.id,
        nomDeCategorie: doc['nomDeCategorie'] as String,
      )).toList();
    });
  }

  void _addData() async {
    try {
      Marque selectedMarque = marquesOptions.firstWhere((m) => m.nomDeMarque == marqueController.text);

      final List<String> selectedCategoryIds = selectedCategories.map((category) => category.id).toList();

      await FirebaseFirestore.instance.collection('marque_catégorie').add({
        'marqueId': selectedMarque.id,
        'categorieIds': selectedCategoryIds,
      });

      marqueController.clear();
      selectedCategories.clear();

      _showSuccessSnackBar('Enregistrement réussi');
    } catch (e) {
      _showErrorSnackBar('Une erreur est survenue lors de l\'enregistrement.');
    }
  }

  void _addNewMarque() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Ajouter une nouvelle marque',
          content: 'Nom de la marque',
          hintText: 'Nom de la marque',
          controller: marqueController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              DocumentReference newMarqueRef = await FirebaseFirestore.instance.collection('marques').add({
                'nomDeMarque': marqueController.text,
              });
              setState(() {
                marquesOptions.add(Marque(id: newMarqueRef.id, nomDeMarque: marqueController.text));
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error adding marque: $e');
            }
          },
        );
      },
    );
  }

  void _addNewCategorie() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Ajouter une nouvelle catégorie',
          content: 'Nom de la catégorie',
          hintText: 'Nom de la catégorie',
          controller: categorieController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              DocumentReference newCategorieRef = await FirebaseFirestore.instance.collection('categories').add({
                'nomDeCategorie': categorieController.text,
              });
              setState(() {
                categoriesOptions.add(Categorie(id: newCategorieRef.id, nomDeCategorie: categorieController.text));
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error adding categorie: $e');
            }
          },
        );
      },
    );
  }

  void _updateMarque(Marque marque) {
    marqueController.text = marque.nomDeMarque;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Modifier la marque',
          content: 'Nom de la marque',
          hintText: 'Nom de la marque',
          controller: marqueController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('marques').doc(marque.id).update({
                'nomDeMarque': marqueController.text,
              });
              setState(() {
                marquesOptions = marquesOptions.map((m) {
                  if (m.id == marque.id) {
                    return Marque(id: marque.id, nomDeMarque: marqueController.text);
                  }
                  return m;
                }).toList();
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error updating marque: $e');
            }
          },
        );
      },
    );
  }

  void _deleteMarque(Marque marque) async {
    try {
      await FirebaseFirestore.instance.collection('marques').doc(marque.id).delete();
      setState(() {
        marquesOptions.removeWhere((m) => m.id == marque.id);
      });
      _showSuccessSnackBar('Marque supprimée');
    } catch (e) {
      _showErrorSnackBar('Error deleting marque: $e');
    }
  }

  void _updateCategorie(Categorie categorie) {
    categorieController.text = categorie.nomDeCategorie;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomAlertDialog(
          title: 'Modifier la catégorie',
          content: 'Nom de la catégorie',
          hintText: 'Nom de la catégorie',
          controller: categorieController,
          onCancelPressed: () {
            Navigator.of(context).pop();
          },
          onConfirmPressed: () async {
            try {
              await FirebaseFirestore.instance.collection('categories').doc(categorie.id).update({
                'nomDeCategorie': categorieController.text,
              });
              setState(() {
                categoriesOptions = categoriesOptions.map((c) {
                  if (c.id == categorie.id) {
                    return Categorie(id: categorie.id, nomDeCategorie: categorieController.text);
                  }
                  return c;
                }).toList();
              });
              Navigator.of(context).pop();
            } catch (e) {
              _showErrorSnackBar('Error updating categorie: $e');
            }
          },
        );
      },
    );
  }

  void _deleteCategorie(Categorie categorie) async {
    try {
      await FirebaseFirestore.instance.collection('categories').doc(categorie.id).delete();
      setState(() {
        categoriesOptions.removeWhere((c) => c.id == categorie.id);
      });
      _showSuccessSnackBar('Catégorie supprimée');
    } catch (e) {
      _showErrorSnackBar('Error deleting categorie: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Marque & Catégorie'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            CustomText(
              text: 'Ajouter nom de marque',
              fontSize: 16.0,
              color: Colors.black,
              alignment: Alignment.topLeft,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildMarqueDropdown(),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addNewMarque,
                ),
              ],
            ),
            SizedBox(height: 16.0),
            CustomText(
              text: 'Sélectionner catégories',
              fontSize: 16.0,
              color: Colors.black,
              alignment: Alignment.topLeft,
            ),
            _buildCategoriesList(),
            SizedBox(height: 16.0),
            CustomButton(
              text: 'Enregistrer',
              onPress: _addData,
            ),
            SizedBox(height: 16.0),
            CustomButton(
              text: 'Suivant',
              onPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddFournisseurScreen()),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueDropdown() {
    return CustomDropdownFormField<Marque>(
      value: null,
      hint: 'Sélectionner une marque',
      onChanged: (newValue) {
        setState(() {
          marqueController.text = newValue!.nomDeMarque;
        });
      },
      items: marquesOptions.map((marque) {
        return DropdownMenuItem<Marque>(
          value: marque,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(marque.nomDeMarque),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _updateMarque(marque),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteMarque(marque),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoriesList() {
    return Column(
      children: categoriesOptions.map((categorie) {
        return ListTile(
          title: Text(categorie.nomDeCategorie),
          leading: Checkbox(
            value: selectedCategories.contains(categorie),
            onChanged: (bool? value) {
              setState(() {
                if (value!) {
                  selectedCategories.add(categorie);
                } else {
                  selectedCategories.remove(categorie);
                }
              });
            },
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _updateCategorie(categorie),
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteCategorie(categorie),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
*/