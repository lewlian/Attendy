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
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _currentDocument;
  String filePath;
  int _classSize;
  getCsv() async {
    List<List<dynamic>> rows = List<List<dynamic>>();
    var cloud =
        await Firestore.instance.collection("attendance").getDocuments();

    rows.add([
      "name",
      "sid",
      "seat",
      "email",
      "present",
    ]);
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String dateFormatted = formatter.format(now);
    print(dateFormatted);

    if (cloud.documents != null) {
      for (int i = 0; i < cloud.documents.length; i++) {
        print(cloud.documents[i]["name"]);
        List<dynamic> row = List<dynamic>();
        row.add(cloud.documents[i]["name"]);
        row.add(cloud.documents[i]["sid"]);
        row.add(cloud.documents[i]["seat"]);
        row.add(cloud.documents[i]["email"]);
        if (cloud.documents[i]["present"]) {
          row.add("present");
        } else {
          row.add("absent");
        }
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
        ..download = 'attendance$dateFormatted.csv';
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
    _classSize = qn.documents.length;
    return qn.documents;
  }

  void updateSeat(value) async {
    var firestore = Firestore.instance;
    await firestore
        .collection('attendance')
        .document(_currentDocument.documentID)
        .updateData({'seat': value});
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

  void deleteData(name) async {
    var firestore = Firestore.instance;
    await firestore
        .collection('attendance')
        .document(_currentDocument.documentID)
        .delete()
        .then((doc) {
      print("data deleted successful");
      showAlertDialog(
          context, "Success", "Student successfully removed from class!");
    }).catchError((error) {
      print("doc save error");
      print(error);
      showAlertDialog(context, "Error", "Please try again.");
    });
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
                  return Container(
                    height: 400,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (_, index) {
                          String name = snapshot.data[index].data["name"];
                          String email = snapshot.data[index].data["email"];
                          int sid = snapshot.data[index].data["sid"];
                          int seat = snapshot.data[index].data["seat"];
                          bool present = snapshot.data[index].data["present"];
                          String comments =
                              snapshot.data[index].data["comments"];
                          return Container(
                            padding: EdgeInsets.all(8.0),
                            margin: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                                color: present
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                border: Border(bottom: BorderSide())),
                            child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Text(seat.toString()),
                                ),
                                title: Text(name),
                                subtitle: Text(email),
                                trailing: SizedBox(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text("edit seat"),
                                      DropdownButton<String>(
                                        items: List<int>.generate(
                                                _classSize, (i) => i + 1)
                                            .map((int value) {
                                          return new DropdownMenuItem<String>(
                                            value: value.toString(),
                                            child: new Text(value.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          _currentDocument =
                                              snapshot.data[index];
                                          updateSeat(int.parse(value));
                                          setState(() {});
                                        },
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: SizedBox(
                                          width: 200,
                                          child: TextFormField(
                                            initialValue: comments,
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              hintText: 'comments',
                                            ),
                                          ),
                                        ),
                                      ),
                                      present
                                          ? Text("PRESENT")
                                          : Text("ABSENT"),
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _currentDocument =
                                                snapshot.data[index];
                                            deleteData(name);
                                            setState(() {
                                              name = "";
                                            });
                                          })
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  _currentDocument = snapshot.data[index];
                                  setState(() {
                                    present = !present;
                                  });
                                  updateData(present);
                                }),
                          );
                        }),
                  );
                }
              }),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () {
                    AuthService().signOut();
                  },
                  child: Center(
                    child: Text('Sign out'),
                  ),
                  color: Colors.red,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterStudent()),
                    );
                  },
                  child: Center(
                    child: Text('Register New Student'),
                  ),
                  color: Colors.blueAccent,
                ),
              ),
              Container(
                margin: EdgeInsets.all(20),
                child: RaisedButton(
                  onPressed: () {
                    getCsv();
                  },
                  child: Center(
                    child: Text('Export CSV'),
                  ),
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ],
      ),
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
