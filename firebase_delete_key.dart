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
  TextEditingController keyctr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My App"),
      ),
      body: Container(
          child: Column(
        children: [
          TextFormField(
              controller: keyctr,
              decoration: InputDecoration(hintText: "Enter any key to delete")),
          ElevatedButton(onPressed: deleteField, child: Text("Ok"))
        ],
      )),
    );
  }

  Future<void> deleteField() async {
    var key = keyctr.text.toLowerCase();
    try {
      await firestore
          .collection("data2")
          .doc("student1")
          .update({key: FieldValue.delete()});
    } catch (e) {
      print(e);
    }
  }
}
