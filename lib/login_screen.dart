import 'package:attendyv2/auth_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email, password;

  final formKey = new GlobalKey<FormState>();

  checkFields() {
    final form = formKey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Container(
                width: 300.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Image.asset('assets/images/logo.jpg', height: 200),
                    ),
                    Form(
                        key: formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 20.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 50.0,
                                  child: TextFormField(
                                    decoration:
                                        InputDecoration(hintText: 'Email'),
                                    validator: (value) => value.isEmpty
                                        ? 'Email is required'
                                        : validateEmail(value.trim()),
                                    onChanged: (value) {
                                      this.email = value;
                                    },
                                  ),
                                )),
                            Padding(
                                padding: EdgeInsets.only(
                                    left: 25.0,
                                    right: 25.0,
                                    top: 20.0,
                                    bottom: 5.0),
                                child: Container(
                                  height: 50.0,
                                  child: TextFormField(
                                    obscureText: true,
                                    decoration:
                                        InputDecoration(hintText: 'Password'),
                                    validator: (value) => value.isEmpty
                                        ? 'Password is required'
                                        : null,
                                    onChanged: (value) {
                                      this.password = value;
                                    },
                                  ),
                                )),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                  onTap: () {
                                    if (checkFields()) {
                                      var res =
                                          AuthService().signIn(email, password);
                                    }
                                  },
                                  child: Container(
                                      height: 40.0,
                                      width: 100.0,
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                      ),
                                      child: Center(child: Text('Sign in')))),
                            ),
                          ],
                        ))
                  ],
                ))));
  }
}

showAlertDialog(BuildContext context) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Failed to Log in"),
    content:
        Text("Please make sure that your username and password is correct"),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
