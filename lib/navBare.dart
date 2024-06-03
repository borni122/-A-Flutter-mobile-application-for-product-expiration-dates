import 'package:flutter/material.dart';
import 'package:stockify/view/Account/screens/account_screen.dart';
import 'package:stockify/view/Analyse%20de%20donn%C3%A9es/dashbord.dart';

import 'emlacment.dart';
import 'view/ListeLots.dart';

class Widget028 extends StatefulWidget {
  const Widget028({Key? key}) : super(key: key);
  @override
  State<Widget028> createState() => _Widget028State();
}

class _Widget028State extends State<Widget028> {
  int _currentIndex = 0;
  final List<Widget> body = [
    DashboardScreen(),
    listeLot(),
    Position(),
    AccountScreen(),

    // Ajoutez d'autres pages ici si nécessaire
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 236, 236, 236),
      body: Center(
        child: body[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF099B6C),
        unselectedItemColor: const Color.fromARGB(255, 210, 210, 210),
        onTap: (int newIndex) {
          setState(() {
            _currentIndex = newIndex;
          });
        },
        items: const [
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.list),
          ),
          BottomNavigationBarItem( // Ajoutez le nouvel élément ici
            label: '',
            icon: Icon(Icons.approval),
          ),

          BottomNavigationBarItem(
            label: '',
            icon: Icon(Icons.person),
          ),

        ],
      ),
    );
  }
}
