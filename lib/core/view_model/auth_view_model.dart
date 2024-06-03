import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:stockify/core/modele/Usermodel.dart';
import '../../helper/localstoragedata.dart';
import '../../navBare.dart';
import '../../view/control_view.dart';
import '../service/firestore_user.dart';

class AuthViewModel extends GetxController {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  FirebaseAuth _auth = FirebaseAuth.instance;
  FacebookLogin _facebookLogin = FacebookLogin();
  String? email, password;
  final RxBool isSendingVerificationEmail = false.obs;

  late String name;
  Rx<User?> _user = Rx<User?>(null);

  String? get user => _user.value?.email;
  final LocalStorageData localStorageData = Get.find();

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
  }

  Future<bool> checkLoggedIn() async {
    // Vérifiez si un utilisateur est déjà connecté localement
    final UserModel? user = await localStorageData.getUser;
    return user != null;
  }

  void saveUser(UserCredential userCredential) async {
    UserModel userModel = UserModel(
      userId: userCredential.user!.uid,
      email: userCredential.user?.email ?? '',
      name: name.isEmpty ? userCredential.user?.displayName ?? 'No Name' : name,
      pic: '',
    );

    await FireStoreUser().addUserToFireStore(userModel);
    setUser(userModel);
  }

  void googleSignInMethod() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );

        await _auth.signInWithCredential(credential).then((user) {
          saveUser(user);
          Get.offAll(Widget028());
        });
      }
    } catch (error) {
      print("Error signing in with Google: $error");
    }
  }

  void facebookSignInMethod() async {
    try {
      final FacebookLoginResult result = await _facebookLogin.logIn(customPermissions: ['email']);
      if (result.status == FacebookLoginStatus.success) {
        final accessToken = result.accessToken?.token;
        if (accessToken != null) {
          final AuthCredential credential = FacebookAuthProvider.credential(accessToken);
          await _auth.signInWithCredential(credential);
        } else {
          print("Facebook access token is null");
        }
      } else if (result.status == FacebookLoginStatus.cancel) {
        print("Facebook sign in canceled");
      } else if (result.status == FacebookLoginStatus.error) {
        print("Error signing in with Facebook: ${result.error}");
      }
    } catch (error) {
      print("Error signing in with Facebook: $error");
    }
  }

  Future<void> signInWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      await FireStoreUser().getCurrentUser(userCredential.user!.uid).then((documentSnapshot) {
        setUser(UserModel.fromJson(documentSnapshot.data() as Map<String, dynamic>));
      });
      Get.offAll(Widget028());// Navigate to home screen after login
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        'Error login account',
        e.toString(),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  Future<void> createAccountWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      saveUser(userCredential);
      Get.offAll(Widget028());
    } catch (e) {
      print(e.toString());
      Get.snackbar(
        'Error creating account',
        e.toString(),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  void setUser(UserModel userModel) async {
    await localStorageData.setUser(userModel);
  }

  void resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(email: email!);
      Get.snackbar('Success', 'Password reset email sent',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void sendEmailVerification() async {
    try {
      isSendingVerificationEmail.value = true;
      await _auth.currentUser!.sendEmailVerification();
      Get.snackbar('Success', 'Verification email sent', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSendingVerificationEmail.value = false;
    }
  }

  Future<bool> isEmailVerified() async {
    await _auth.currentUser!.reload();
    return _auth.currentUser!.emailVerified;
  }
}
