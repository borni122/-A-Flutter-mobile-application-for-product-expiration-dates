import 'dart:async';
import 'package:stockify/constance.dart';
import 'package:stockify/view/auth/login_screen.dart';

import 'constant.dart';
import 'package:flutter/material.dart';

import 'features/tab_page_selector/src/page/tab_page_selector_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => TabPageSelectorPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Image(
          image: AssetImage("assets/image/logo1.png"),
          width: 200,
        ),
      ),
    );
  }
}
