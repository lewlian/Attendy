import 'package:attendyv2/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterStudent extends StatefulWidget {
  @override
  _RegisterStudentState createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  String name, email;
  int sid;
  bool present = true;

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
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'Please enter full name',
                labelText: 'Name *',
              ),
              validator: (String value) {
                return value.contains('@') ? 'Do not use the @ char.' : null;
              },
              onChanged: (value) {
                this.name = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(
                icon: Icon(Icons.person),
                hintText: 'What is your berkeley email address?',
                labelText: 'Email *',
              ),
              validator: (value) => value.isEmpty
                  ? 'Email is required'
                  : validateEmail(value.trim()),
              onChanged: (value) {
                this.email = value;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Berkeley student ID',
                  labelText: 'SID *',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  this.sid = int.parse(value);
                }),
          ),
          RaisedButton(
            onPressed: () async {
              print(this.email + this.name + this.sid.toString());
              Firestore fstore = Firestore.instance;
              fstore.collection("attendance").add({
                "name": this.name,
                "email": this.email,
                "sid": this.sid,
                "present": present,
              }).then((doc) {
                print("doc save successful");
                showAlertDialog(
                    context, "Success", "Student successfully added to class!");
              }).catchError((error) {
                print("doc save error");
                print(error);
                showAlertDialog(context, "Error", "Please try again.");
              });
              setState(() {
                this.name = "";
                this.email = "";
                this.sid = int.parse("");
              });
            },
            child: Center(
              child: Text('Add to Class'),
            ),
            color: Colors.blueAccent,
          ),
          RaisedButton(
            child: Center(
              child: Text("Back to Attendance"),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
          )
        ],
      )),
    );
  }
}

showAlertDialog(BuildContext context, String message, String submessage) {
  // set up the button
  Widget okButton = FlatButton(
    child: Text("Ok"),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(message),
    content: Text(submessage),
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
