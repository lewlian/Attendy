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
  signOut() {
    FirebaseAuth.instance.signOut();
  }

  // Sign in
  signIn(email, password) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((user) {
      return ('Login Success');
    }).catchError((e) {
      throw (e);
    });
  }
}
