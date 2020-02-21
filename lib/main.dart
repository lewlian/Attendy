import 'package:flutter/material.dart';
import 'package:firebase/firebase.dart' as Firebase;
import 'auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthService().handleAuth());
  }
}
