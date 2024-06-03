import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/modele/Usermodel.dart';

class LocalStorageData extends GetxController {
  Future<UserModel?> get getUser async {
    try {
      UserModel? userModel = await _getUserData();
      return userModel;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<UserModel?> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var value = prefs.getString('CACHED_USER_DATA');
    if (value != null) {
      return UserModel.fromJson(json.decode(value));
    } else {
      return null;
    }
  }

  Future<void> setUser(UserModel userModel) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('CACHED_USER_DATA', json.encode(userModel.toJson()));
  }

  void deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}