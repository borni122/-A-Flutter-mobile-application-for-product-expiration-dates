import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/modele/fourniseur.dart';
import 'ajouterLot.dart';
import 'auth/widgets/custom_text_form_field2.dart'; // Importez votre widget CustomTextFormField ici
import 'auth/widgets/custom_buttom.dart'; // Importez votre widget CustomButton ici

// Page ou widget pour ajouter un fournisseur
class AddFournisseurScreen extends StatefulWidget {
  @override
  _AddFournisseurScreenState createState() => _AddFournisseurScreenState();
}

class _AddFournisseurScreenState extends State<AddFournisseurScreen> {
  final TextEditingController nomController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  void _addFournisseur() async {
    try {
      // Créez un nouvel objet Fournisseur à partir des données saisies
      Fournisseur fournisseur = Fournisseur(
        idFournisseur: '', // Vous pouvez générer un ID ou le récupérer d'une autre source
        nomFournisseur: nomController.text,
        telephone: telephoneController.text,
      );

      // Ajoutez le fournisseur à la base de données Firestore
      await FirebaseFirestore.instance.collection('fournisseurs').add(fournisseur.toMap());

      // Effacez les champs de saisie après l'ajout
      nomController.clear();
      telephoneController.clear();

      // Affichez un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fournisseur ajouté avec succès'),
        ),
      );
    } catch (e) {
      // En cas d'erreur, affichez un message d'erreur
      print("Error adding fournisseur: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur est survenue lors de l\'ajout du fournisseur.'),
        ),
      );
    }
  }

  void _anotherMethod() {
    // Méthode pour gérer l'ajout d'un autre type d'entité ou effectuer une autre action
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: Center(
                child: Text(
                  'Ajouter Fournisseur',
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextFormField(
                controller: nomController,
                label: 'Nom du fournisseur',
                text: 'Nom du fournisseur',
                hint: 'Nom du fournisseur',
              ),
              SizedBox(height: 16.0),
              CustomTextFormField(
                controller: telephoneController,
                label: 'Numéro de téléphone',
                text: 'Numéro de téléphone',
                hint: 'Numéro de téléphone',
              ),
              SizedBox(height: 16.0),
              CustomButton(
                text: 'Ajouter',
                onPress: _addFournisseur,
              ),
              SizedBox(height: 16.0), // Espacement entre les boutons
              CustomButton(
                text: 'Suivant',
                onPress: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );

  }
}
