import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:stockify/helper/binding.dart';
import 'package:stockify/firebase_options.dart';
import 'package:stockify/splashScreen.dart';
import 'package:stockify/view/Account/screens/account_screen.dart';
import 'package:stockify/view/Analyse%20de%20donn%C3%A9es/dashbord.dart';
import 'package:stockify/view/ProfilView.dart';
import 'package:stockify/view/UpdateLot.dart';
import 'package:stockify/view/addcategorieetmarqueetlaison.dart';
import 'package:stockify/view/addfournniseur.dart';
import 'package:stockify/view/auth/emailverificationScreen.dart';
import 'package:stockify/view/auth/login_screen.dart';
import 'package:stockify/view/control_view.dart';
import 'package:stockify/view/ListeLots.dart';
import 'package:stockify/view/ajouterLot.dart';
import 'package:stockify/constant.dart';
import 'package:stockify/view/notificationphone.dart';
import 'package:stockify/view/scanner.dart';

import 'constance.dart';
import 'emlacment.dart';
import 'features/tab_page_selector/src/page/tab_page_selector_page.dart';
import 'navBare.dart'; // Import LotNotifier class

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Schedule notifications
  scheduleNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: Binding(),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'nsb',
        scaffoldBackgroundColor: white,
        appBarTheme: const AppBarTheme(
          backgroundColor: vert,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}
