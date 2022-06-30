import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(title: "Simple Singup Page", initialRoute: "/", routes: {
      '/': (context) => signUpPage(),
      '/homepage': (context) => homePage(),
    });
  }
}

class signUpPage extends StatefulWidget {
  State<signUpPage> createState() => _signUpPageState();
}

class _signUpPageState extends State<signUpPage> {
  dynamic avatar = null;
  late File profileImage;
  String labelText = "";

  var emailCtr = TextEditingController();
  var passCtr = TextEditingController();
  var nameCtr = TextEditingController();
  var ageCtr = TextEditingController();
  var classCtr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign Up")),
      body: Container(
        padding: EdgeInsets.all(10),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  child: CircleAvatar(
                    backgroundColor: Colors.lightBlue,
                    radius: 70,
                    backgroundImage: avatar,
                    child: GestureDetector(
                      onTap: () => pickFile(),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  labelText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "cursive",
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                MyTextField("Enter email", emailCtr, false),
                SizedBox(
                  height: 5,
                ),
                MyTextField("Enter password", passCtr, true),
                SizedBox(
                  height: 10,
                ),
                MyTextField("Enter name", nameCtr, false),
                SizedBox(
                  height: 10,
                ),
                MyTextField("Enter age", ageCtr, false),
                SizedBox(
                  height: 10,
                ),
                MyTextField("Enter class", classCtr, false),
                ElevatedButton(onPressed: onPressed, child: Text("Upload Data"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        this.profileImage = File(file.path!);
        this.avatar = FileImage(this.profileImage);
      });
    }
  }

  void onPressed() {
    setState(() {
      labelText = "Uploading Data";
    });
    Future.wait(
      createAccount(),
    );
  }

  Future<void> createAccount() async {
    try {
      final credential = await fbaseauth
          .createUserWithEmailAndPassword(
            email: this.emailCtr.text,
            password: this.passCtr.text,
          )
          .then((value) => signInAccount());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInAccount() async {
    try {
      final credential = await fbaseauth
          .signInWithEmailAndPassword(
              email: this.emailCtr.text, password: this.passCtr.text)
          .then((value) {
        uploadData().then(
            (value) => Navigator.pushReplacementNamed(context, "/homepage"));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> uploadData() async {
    var profileImageRef = storageRef
        .child("images/${fbaseauth.currentUser!.uid}/profilepic.jpeg");

    var profileImageLink;

    try {
      await profileImageRef.putFile(profileImage).then((p0) async {
        await profileImageRef.getDownloadURL().then((value) {
          try {
            firestore.collection("users").doc(fbaseauth.currentUser!.uid).set({
              "name": nameCtr.text,
              "age": int.parse(ageCtr.text),
              "class": classCtr.text,
              "profile_image": value
            });
          } catch (e) {
            print(e);
          }
        });
      });
    } catch (e) {
      print(e);
    }
  }
}

class MyTextField extends StatelessWidget {
  bool secure = false;
  late String placeholder;
  late TextEditingController controller;

  MyTextField(placeholder, ctrlr, [secure]) {
    this.placeholder = placeholder;
    this.controller = ctrlr;
    this.secure = secure!;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: this.controller,
      obscureText: secure,
      decoration: InputDecoration(
          hintText: placeholder,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          )),
    );
  }
}

class homePage extends StatelessWidget {
  var uid = fbaseauth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Firebase Post and Get Data"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("users").doc(uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {
            Map<String, dynamic> data =
                snapshot.data!.data() as Map<String, dynamic>;
            return Column(children: [
              Text(data["name"]),
              Text(data["age"].toString()),
              Image.network(data["profile_image"])
            ]);
          }

          return Text("loading");
        },
      ),
    );
  }
}
