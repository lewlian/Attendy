import 'dart:convert';
import 'dart:html' as html;
import 'package:attendyv2/attendance_screen.dart';
import 'package:attendyv2/auth_service.dart';
import 'package:attendyv2/register_student_screen.dart';
import 'package:csv/csv.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/firestore.dart' as fs;
import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentDocument;
  String filePath;

  getCsv() async {
    List<List<dynamic>> rows = List<List<dynamic>>();
    var cloud =
        await Firestore.instance.collection("attendance").getDocuments();

    rows.add([
      "email",
      "name",
      "present",
      "seat",
      "sid",
    ]);
    print("reached here");
    print(cloud.documents[0]['name']);

    if (cloud.documents != null) {
      for (int i = 0; i < cloud.documents.length; i++) {
        print(cloud.documents[i]["name"]);
        List<dynamic> row = List<dynamic>();
        row.add(cloud.documents[i]["name"]);
        row.add(cloud.documents[i]["sid"]);
        row.add(cloud.documents[i]["seat"]);
        row.add(cloud.documents[i]["email"]);
        row.add(cloud.documents[i]["present"]);
        print(row.toString());
        rows.add(row);
      }

      String csv = const ListToCsvConverter().convert(rows);

      // prepare
      final bytes = utf8.encode(csv);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'some_name.txt';
      html.document.body.children.add(anchor);

      // download
      anchor.click();

      // cleanup
      html.document.body.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    }
  }

  Future getClasses() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn =
        await firestore.collection('attendance').orderBy("seat").getDocuments();
    return qn.documents;
  }

  void updateData(present) async {
    var firestore = Firestore.instance;
    await firestore
        .collection('attendance')
        .document(_currentDocument.documentID)
        .updateData({'present': present});

    print("document updated");
    print(present.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Attendance List', style: TextStyle(fontSize: 32)),
          SizedBox(height: 10.0),
          FutureBuilder(
              future: getClasses(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Text('loading...'),
                  );
                } else {
                  return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) {
                        String name = snapshot.data[index].data["name"];
                        String email = snapshot.data[index].data["email"];
                        int sid = snapshot.data[index].data["sid"];
                        int seat = snapshot.data[index].data["seat"];
                        bool present = snapshot.data[index].data["present"];
                        return Container(
                          color:
                              present ? Colors.greenAccent : Colors.redAccent,
                          child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Text(seat.toString()),
                              ),
                              title: Text(name),
                              subtitle: Text(email),
                              trailing:
                                  present ? Text("PRESENT") : Text("ABSENT"),
                              onTap: () {
                                _currentDocument = snapshot.data[index];
                                setState(() {
                                  present = !present;
                                });
                                updateData(present);
                              }),
                        );
                      });
                }
              }),
          SizedBox(height: 10),
          RaisedButton(
            onPressed: () {
              AuthService().signOut();
            },
            child: Center(
              child: Text('Sign out'),
            ),
            color: Colors.red,
          ),
          RaisedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RegisterStudent()),
              );
            },
            child: Center(
              child: Text('Register New Student'),
            ),
            color: Colors.blueAccent,
          ),
          RaisedButton(
            onPressed: () {
              getCsv();
            },
            child: Center(
              child: Text('Export CSV'),
            ),
            color: Colors.blueAccent,
          ),
        ],
      ),
    );
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
