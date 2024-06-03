import 'package:get/get.dart';
import 'package:stockify/core/view_model/auth_view_model.dart';
import 'package:stockify/core/view_model/profile_view_model.dart'; // Assurez-vous d'importer correctement ProfileViewModel
import '../navBare.dart';
import 'localstoragedata.dart';

class Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthViewModel());
    Get.lazyPut(() => ProfileViewModel()); // Enregistrer ProfileViewModel avec GetX
    Get.lazyPut(() => LocalStorageData());
  }
}
