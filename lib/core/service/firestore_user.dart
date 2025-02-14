import 'package:cloud_firestore/cloud_firestore.dart';

import '../modele/Usermodel.dart';

class FireStoreUser {
  final CollectionReference _userCollectionRef =
      FirebaseFirestore.instance.collection('Utilisateur');

  Future<void> addUserToFireStore(UserModel userModel) async {
    return await _userCollectionRef.doc(userModel.userId)
        .set(userModel.toJson());
  }

  Future<DocumentSnapshot> getCurrentUser (String uid)async{
    return await _userCollectionRef.doc(uid).get();
  }
}
