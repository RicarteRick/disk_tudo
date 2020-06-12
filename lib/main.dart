import 'package:flutter/material.dart';
import 'package:disk_tudo/ui/home_page.dart';

void main() async{

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        primaryColor: Colors.deepPurple[800],
    ),
  ));
}