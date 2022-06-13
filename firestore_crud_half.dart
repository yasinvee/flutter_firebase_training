import 'package:flutter/material.dart';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'global_variables.dart';

void main(List<String> args) async {
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
    // TODO: implement build
    return MaterialApp(title: "Firebase Demo", initialRoute: "/", routes: {
      '/': (context) => loginPage(),
      "/infoinput": (context) => infoInputPage(),
      "/infopage": (context) => infoPage(),
      "/infoupdate": (context) => infoUpdate()
    });
  }
}

class loginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: Container(
          child: Center(
        child: ElevatedButton(
          onPressed: () => googleAuth(context),
          child: Text("Login With Google"),
        ),
      )),
    );
  }

  Future<void> googleAuth(BuildContext context) async {
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

      await fbaseauth
          .signInWithCredential(credential)
          .then((value) => setScreen(context));
    } catch (e) {
      print("Error: $e");
      return;
    }
  }

  void setScreen(context) async {
    try {
      var user_uid = fbaseauth.currentUser!.uid;

      var docRef = firestore.collection("users").doc(user_uid);

      docRef.get().then((doc) {
        if (doc.exists) {
          Navigator.pushReplacementNamed(context, "/infopage");
        } else {
          Navigator.pushReplacementNamed(context, "/infoinput");
        }
      });
    } catch (e) {
      print(e);
    }
  }
}

class infoInputPage extends StatelessWidget {
  final TextEditingController unamectr = TextEditingController();
  final TextEditingController agectr = TextEditingController();
  final TextEditingController eductr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello")),
      body: Container(
        child: Column(
          children: [
            TextFormField(
              controller: unamectr,
              decoration: InputDecoration(hintText: "Enter username"),
            ),
            TextFormField(
              controller: agectr,
              decoration: InputDecoration(hintText: "Enter age"),
            ),
            TextFormField(
              controller: eductr,
              decoration: InputDecoration(hintText: "Enter education"),
            ),
            ElevatedButton(onPressed: setData, child: Text("Add Info"))
          ],
        ),
      ),
    );
  }

  Future<void> setData() async {
    var userId = fbaseauth.currentUser!.uid;

    var uname = unamectr.text;
    var age = agectr.text;
    var edu = eductr.text;

    try {
      await firestore
          .collection("users")
          .doc(userId)
          .set({"username": uname, "age": age, "education": edu});
    } catch (e) {
      print(e);
    }
  }
}

class infoPage extends StatelessWidget {
  var users = firestore.collection("users");
  var userId = fbaseauth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppBarTitle)),
      body: FutureBuilder<DocumentSnapshot>(
          future: users.doc(userId).get(),
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
              // return Text("Full Name: ${data['full_name']} ${data['last_name']}");

              return Container(
                child: Column(children: [
                  StyledText("Username: ${data["username"]}"),
                  StyledText("Age: ${data["age"]}"),
                  StyledText("Education: ${data["education"]}"),
                  Wrap(
                    direction: Axis.horizontal,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/infoupdate");
                          },
                          child: Text("Update Information")),
                      // ElevatedButton(
                      //     onPressed: () => deleteInformation(context),
                      //     child: Text("Delete Information")),
                    ],
                  ),
                ]),
              );
            }

            return Text("loading");
          }),
    );
  }
}

class StyledText extends StatelessWidget {
  late String data;
  StyledText(data) {
    this.data = data;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.blue,
        fontSize: 20,
      ),
    );
  }
}

class infoUpdate extends StatelessWidget {
  TextEditingController uname = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hello")),
      body: Container(
        child: Column(children: [
          TextFormField(
            controller: uname,
            decoration: InputDecoration(hintText: "Enter username"),
          ),
          Wrap(
            direction: Axis.horizontal,
            children: [
              ElevatedButton(
                  onPressed: onPressed, child: Text("Update Username")),
              // ElevatedButton(onPressed: onPressed, child: Text("Update Age")),
              // ElevatedButton(onPressed: onPressed, child: Text("Update Education"))
            ],
          ),
        ]),
      ),
    );
  }

  Future<void> onPressed() async {
    var userId = fbaseauth.currentUser!.uid;
    var uname_ = uname.text;

    try {
      await firestore
          .collection("users")
          .doc(userId)
          .update({"username": uname_});
    } catch (e) {
      print(e);
    }
  }
}
