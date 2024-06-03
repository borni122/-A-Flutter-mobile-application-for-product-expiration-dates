
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../navBare.dart';
import '../../view/ProfilView.dart';
import '../../view/homePage.dart';

class ControlViewModel extends GetxController {
  int _navigatorValue = 0;

  get navigatorValue => _navigatorValue;

  Widget currentScreen = HomePage();

  void changeSelectedValue(int selectedValue) {
    _navigatorValue = selectedValue;
    switch (selectedValue) {
      case 0:
        {
          currentScreen = Widget028();
          break;
        }

    }
    update();
  }
}
