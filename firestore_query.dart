import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'global_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "My App", debugShowCheckedModeBanner: false, home: homePage());
  }
}

class homePage extends StatelessWidget {

    Stream<QuerySnapshot> dataStream = firestore
      .collection('data')
      .where("langs", arrayContainsAny: ["fr", "arabic"])
      .snapshots();

      //   Stream<QuerySnapshot> dataStream = firestore
      // .collection('data')
      // .where("age", whereIn: [55, 60])
      // .snapshots();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppBarTitle)),
      body: Container(
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: dataStream,
            builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text("Loading");
              }

              return ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return ListTile(
                    title: Text("Employee Data"),
                    subtitle: Text("Name : ${data['employee_name']}, Age: ${data['age']}, Job Start ${DateTime.parse(data["job_start"].toDate().toString())}"),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
