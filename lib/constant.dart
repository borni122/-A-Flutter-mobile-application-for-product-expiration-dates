import 'package:flutter/material.dart';

const vert = Color.fromARGB(255, 255, 255, 255);
const black = Color.fromARGB(255, 0, 0, 0);
Color myColor = Color.fromARGB(255, 247, 247, 247);
const white = Color.fromARGB(255, 255, 255, 255);
const verty = Color(0xFF1F5215);
const  greey = Color(0xFFF5FEFD);
const red = Color.fromARGB(255, 141, 4, 4);

var loading = true;

newSnackBar(BuildContext context, {title}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: myColor,
      content: Text(
        title,
      ),
    ),
  );
}
