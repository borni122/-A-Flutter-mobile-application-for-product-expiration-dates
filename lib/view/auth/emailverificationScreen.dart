import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stockify/constance.dart';
import 'package:stockify/core/view_model/auth_view_model.dart';
import 'package:stockify/view/auth/widgets/CustomButtonV%C3%A9rification.dart';

import 'dart:async';

import 'package:stockify/view/auth/widgets/Textcustom.dart';

class EmailVerificationScreen extends StatefulWidget {
  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthViewModel authViewModel = Get.find<AuthViewModel>();
  Timer? _timer;
  final RxInt _counter = 30.obs;  // Make _counter observable

  @override
  void initState() {
    super.initState();
    authViewModel.sendEmailVerification();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_counter.value > 0) {
        _counter.value--;  // Update observable
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkEmailVerified() async {
    bool isVerified = await authViewModel.isEmailVerified();
    if (isVerified) {
      Get.offAllNamed('/Widget028'); // Navigate to the home screen after verification
    } else {
      Get.snackbar('Erreur', 'Email non vérifié encore', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _resendVerificationEmail() {
    if (_counter.value == 0) {
      _counter.value = 30;  // Reset the counter
      authViewModel.sendEmailVerification();
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText(text: "Vérification de l'Email", fontSize: 20, color: Colors.black),
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 100, color: primaryColor),
              SizedBox(height: 20),
              CustomText(
                text: "Un email de vérification a été envoyé à votre adresse email.",
                fontSize: 16,
                color: Colors.grey,
                alignment: Alignment.center,
              ),
              SizedBox(height: 20),
              CustomButton(
                onPress: _checkEmailVerified,
                text: 'J\'AI VÉRIFIÉ',
              ),
              SizedBox(height: 20),
              Obx(() => CustomButton(
                onPress: _resendVerificationEmail,
                text: 'RENVOYER L\'EMAIL (${_counter.value})',
                isDisabled: _counter.value > 0,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
