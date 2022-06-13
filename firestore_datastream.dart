import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io';
import 'firebase_options.dart';
import 'global_variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Firebase Stream",
      home: Login(),
    );
  }
}

class Login extends StatelessWidget {
  var context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(title: Text("FireStore Stream")),
      body: Center(
          child: ElevatedButton(onPressed: googleAuth, child: Text("Login"))),
    );
  }

  Future<void> googleAuth() async {
    try {
      //To check internet connectivity
      await InternetAddress.lookup('firebase.google.com');

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      if (googleAuth == null) {
        return;
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await fbaseauth.signInWithCredential(credential).then((value) =>
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => SecondPage())));
    } catch (e) {
      print("Error: $e");
      return;
    }
  }
}

class SecondPage extends StatefulWidget {
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> dataStream = firestore.collection('data').snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text("Stream of Data"),
      ),
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
                    title: Text("Message:"),
                    subtitle: Text("${data['message']} from ${data['from']}"),
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
