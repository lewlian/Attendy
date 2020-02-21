import 'package:attendyv2/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  String date;

  AttendancePage({Key key, @required this.date}) : super(key: key);

  @override
  _AttendancePageState createState() => _AttendancePageState(date);
}

class _AttendancePageState extends State<AttendancePage> {
  String date;
  _AttendancePageState(this.date);

  @override
  Widget build(BuildContext context) {
    Future getAttendance() async {
      var firestore = Firestore.instance;
      QuerySnapshot qn = await firestore.collection('classes').getDocuments();
      return qn.documents;
    }

    return Scaffold(
        body: Column(
      children: <Widget>[
        Container(child: Text(date)),
        FutureBuilder(
            future: getAttendance(),
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
                      String present = snapshot.data[index].data["className"];
                      print(present);
                      return ListTile(
                          title: Text(present.toString()), onTap: () {});
                    });
              }
            }),
      ],
    ));
  }
}
