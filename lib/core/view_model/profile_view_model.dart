import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../helper/localstoragedata.dart';
import '../modele/Usermodel.dart';

class ProfileViewModel extends GetxController {
  ValueNotifier<bool> get loading => _loading;
  ValueNotifier<bool> _loading = ValueNotifier(false);

  // Declaring _userModel as nullable
  UserModel? _userModel;
  UserModel? get userModel => _userModel;

  final LocalStorageData localStorageData = Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    getCurrentUser();
  }

  void getCurrentUser() async {
    _loading.value = true;
    try {
      final user = await localStorageData.getUser;
      if (user != null) {
        _userModel = user;
      } else {
        _userModel = UserModel(userId: '', name: 'Unknown', email: '', pic: '');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      _userModel = UserModel(userId: '', name: 'Unknown', email: '', pic: '');
    } finally {
      _loading.value = false;
      update();
    }
  }

  Future<void> updateUserProfile(String name, String email, String pic) async {
    if (_userModel == null) return;

    _loading.value = true;
    try {
      _userModel = UserModel(userId: _userModel!.userId, name: name, email: email, pic: pic);
      await _firestore.collection('Utilisateur').doc(_userModel!.userId).update({
        'name': name,
        'email': email,
        'pic': pic,
      });
      await localStorageData.setUser(_userModel!);
      print('User profile updated successfully');
    } catch (e) {
      print('Error updating user profile: $e');
    } finally {
      _loading.value = false;
      update();
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _userModel != null) {
      try {
        final String fileExtension = pickedFile.path.split('.').last.toLowerCase();
        if (fileExtension == 'png') {
          final storageRef = FirebaseStorage.instance.ref().child('userImages/${_userModel!.userId}.png');
          await storageRef.putFile(File(pickedFile.path));
          String downloadUrl = await storageRef.getDownloadURL();
          await updateUserProfile(_userModel!.name, _userModel!.email, downloadUrl);
          File(pickedFile.path).delete();
        } else {
          print('Error: Selected file is not a PNG image');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }
}
