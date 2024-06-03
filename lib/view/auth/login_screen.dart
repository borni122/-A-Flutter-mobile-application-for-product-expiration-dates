import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockify/constance.dart';
import 'package:stockify/core/view_model/auth_view_model.dart';
import 'package:stockify/view/auth/registre_screen.dart';
import 'package:stockify/view/auth/widgets/custom_text.dart';
import 'package:stockify/view/auth/widgets/custom_text_form_field.dart';
import 'package:stockify/view/auth/widgets/custom_buttom.dart';
import 'package:stockify/view/auth/widgets/custom_button_social.dart';

import 'forgetpasswordScreen.dart';

class LoginScreen extends GetWidget<AuthViewModel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 50,
          right: 20,
          left: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(text: "Bienvenue", fontSize: 30),
                    GestureDetector(
                      onTap: () {
                        Get.to(RegistreScreen());
                      },
                      child: CustomText(text: "Créer un compte", color: primaryColor, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                CustomText(text: "Connexion", color: Colors.grey, fontSize: 15),
                SizedBox(height: 20),
                CustomTextFormField(
                  text: 'Email',
                  hint: 'exemple@gmail.com',
                  isEmail: true,
                  onSave: (value) {
                    controller.email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer une adresse email";
                    }
                    if (!value.contains('@')) {
                      return "Veuillez entrer une adresse email valide";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  text: 'Mot de passe',
                  hint: '**********',
                  isPassword: true,
                  onSave: (value) {
                    controller.password = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un mot de passe";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Get.to(ForgotPasswordScreen()); // Navigate to ForgotPasswordScreen
                  },
                  child: CustomText(
                    text: 'Mot de passe oublié?',
                    fontSize: 14,
                    alignment: Alignment.topRight,
                  ),
                ),
                SizedBox(height: 20),
                CustomButton(
                  onPress: () {
                    _formKey.currentState?.save();
                    if (_formKey.currentState!.validate()) {
                      controller.signInWithEmailAndPassword();
                    }
                  },
                  text: 'SE CONNECTER',
                ),
                SizedBox(height: 20),
                CustomText(
                  text: '-OU-',
                  alignment: Alignment.center,
                ),
                SizedBox(height: 20),
                CustomButtonSocial(
                  text: 'Se connecter avec Facebook',
                  onPress: () {
                    // Implémenter la méthode de connexion avec Facebook
                  },
                  imageName: 'assets/image/facebook.png',
                ),
                SizedBox(height: 20),
                CustomButtonSocial(
                  text: 'Se connecter avec Google',
                  onPress: () {
                    controller.googleSignInMethod();
                  },
                  imageName: 'assets/image/google.png',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
