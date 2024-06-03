import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockify/constance.dart';
import 'package:stockify/core/view_model/auth_view_model.dart';
import 'package:stockify/view/auth/widgets/custom_text.dart';
import 'package:stockify/view/auth/widgets/custom_text_form_field.dart';
import 'package:stockify/view/auth/widgets/custom_buttom.dart';

class ForgotPasswordScreen extends GetWidget<AuthViewModel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Mot de passe oublié", fontSize: 20, color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "Entrez votre email pour recevoir un lien de réinitialisation du mot de passe",
                fontSize: 16,
                color: Colors.grey,
              ),
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
              CustomButton(
                onPress: () {
                  _formKey.currentState?.save();
                  if (_formKey.currentState!.validate()) {
                    controller.resetPassword();
                  }
                },
                text: 'ENVOYER LE LIEN DE RÉINITIALISATION',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
