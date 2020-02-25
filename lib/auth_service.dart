import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthService {
  //Handle Authentication
  handleAuth() {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return LoginPage();
          }
        });
  }

  //Sign  out
  signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Sign in
  signIn(email, password) async {
    try {
      FirebaseAuth _auth = FirebaseAuth.instance;
      AuthResult result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user.uid;
    } catch (e) {
      print('Error auth: $e');
      return (e);
    }
    ;
  }
}
