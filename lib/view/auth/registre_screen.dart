import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockify/constance.dart';
import 'package:stockify/core/view_model/auth_view_model.dart';
import 'package:stockify/view/auth/login_screen.dart';
import 'package:stockify/view/auth/widgets/custom_text.dart';
import 'package:stockify/view/auth/widgets/custom_text_form_field.dart';
import 'package:stockify/view/auth/widgets/custom_buttom.dart';

import 'emailverificationScreen.dart';

class RegistreScreen extends GetWidget<AuthViewModel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        leading: GestureDetector(
            onTap: () {
              Get.offAll(LoginScreen());
            },
            child: Icon(Icons.arrow_back, color: Colors.black)),
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
                Image.asset('assets/image/logo.png', height: 100),
                SizedBox(height: 30),
                CustomText(text: "Création Compte Stockify", fontSize: 22),
                SizedBox(height: 25),
                CustomText(
                    text: "Enregistrez-vous",
                    color: Colors.grey,
                    fontSize: 15),
                SizedBox(height: 25),
                CustomTextFormField(
                  text: 'Nom',
                  hint: 'Entrez votre nom',
                  isUser: true,
                  onSave: (value) {
                    controller.name = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le champ nom ne peut pas être vide";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  text: 'Email',
                  hint: 'exemple@gmail.com',
                  isEmail: true,
                  onSave: (value) {
                    controller.email = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le champ email ne peut pas être vide";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  text: 'Mot de passe',
                  hint: '********',
                  isPassword: true,
                  onSave: (value) {
                    controller.password = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Le mot de passe ne peut pas être vide";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomButton(
                  onPress: () async {
                    _formKey.currentState?.save();
                    if (_formKey.currentState!.validate()) {
                      await controller.signInWithEmailAndPassword();
                      bool isVerified = await controller.isEmailVerified();
                      if (isVerified) {
                        Get.offAllNamed('/Widget028');
                      } else {
                        Get.to(EmailVerificationScreen());
                      }
                    }
                  },
                  text: 'S\'INSCRIRE',
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}
