import 'package:flutter/material.dart';

import '../../../../view/auth/login_screen.dart';

class TabPageSelectorWidget extends StatelessWidget {
  const TabPageSelectorWidget({
    super.key,
    required this.data,
  });

  final Map<String, String> data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Image.asset(
          data["image"]!,
          fit: BoxFit.fill,
          // height: 600,
        ),
        Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.black), // Couleur du texte
              ),
            ),
          ),

        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
            ),
            child: Text(
              data["description"]!,
              style:
                  textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
