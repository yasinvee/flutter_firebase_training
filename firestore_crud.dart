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
      "/infoupdate": (context) => infoupdate(),
      "/infodelete": (context) => infoDelete()
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

  void setScreen(BuildContext context) {
    String userId = fbaseauth.currentUser!.uid;

    var docRef = firestore.collection("users").doc(userId);

    docRef.get().then((doc) {
      if (doc.exists) {
        Navigator.pushReplacementNamed(context, "/infopage");
      } else {
        Navigator.pushReplacementNamed(context, "/infoinput");
      }
    });
  }
}

class infoInputPage extends StatelessWidget {
  late final userUid;

  final TextEditingController nameCtrlr = TextEditingController();
  final TextEditingController ageCtrlr = TextEditingController();
  final TextEditingController eduCtrlr = TextEditingController();

  @override
  Widget build(BuildContext context) {
    userUid = fbaseauth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Text("User ID " + userUid.toString() + "Logged In"),
              TextFormField(
                controller: nameCtrlr,
                decoration: InputDecoration(hintText: "Enter your name"),
              ),
              TextFormField(
                controller: ageCtrlr,
                decoration: InputDecoration(hintText: "Enter your age"),
              ),
              TextFormField(
                controller: eduCtrlr,
                decoration: InputDecoration(hintText: "Enter your education"),
              ),
              ElevatedButton(
                  onPressed: () => addInfo(userUid.toString()),
                  child: Text("Add Information")),
              ElevatedButton(
                  onPressed: () => signOut(context), child: Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addInfo(uid) async {
    var fullName = nameCtrlr.text;
    var age = ageCtrlr.text;
    var education = eduCtrlr.text;

    try {
      await firestore
          .collection("users")
          .doc(uid)
          .set({"username": fullName, 'age': age, 'education': education});
    } catch (e) {
      print(e);
    }
  }

  Future signOut(BuildContext context) async {
    await fbaseauth
        .signOut()
        .then((value) => Navigator.pushReplacementNamed(context, "/"));
  }
}

class infoPage extends StatelessWidget {
  final userUid = fbaseauth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection("users").doc(userUid).get(),
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
            return Column(
              children: [
                StyledText("Name: ${data['username']}"),
                StyledText("Age: ${data['age']}"),
                StyledText("Education: ${data['education']}"),
                Wrap(
                  direction: Axis.horizontal,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/infoupdate");
                        },
                        child: Text("Update Information")),
                    ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, "/infodelete"),
                        child: Text("Delete Information")),
                  ],
                ),
              ],
            );
          }

          return Text("loading");
        },
      ),
    );
  }

  //To delete any specific key or field value you have to use
  //update method with FieldValue.delete() as key of thke field
  //you want to delete

}

class StyledText extends StatelessWidget {
  late final text;

  StyledText(text) {
    this.text = text;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      this.text,
      style: TextStyle(
          color: Colors.blue, fontSize: 20, backgroundColor: Colors.white),
    );
  }
}

class infoupdate extends StatelessWidget {
  TextEditingController infoCtrlr = TextEditingController();
  late final context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(AppBarTitle),
      ),
      body: Container(
        child: Column(
          children: [
            TextFormField(
              controller: infoCtrlr,
              decoration: InputDecoration(hintText: "Enter new value"),
            ),
            Wrap(
              direction: Axis.horizontal,
              children: [
                ElevatedButton(
                    onPressed: updateUsername, child: Text("Update username")),
                ElevatedButton(onPressed: updateAge, child: Text("Update age")),
                ElevatedButton(
                    onPressed: updateEdu, child: Text("Update education")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> updateUsername() async {
    final userUid = fbaseauth.currentUser!.uid;

    String new_username = infoCtrlr.text;

    try {
      await firestore
          .collection("users")
          .doc(userUid)
          .update({"username": new_username}).then(
              (value) => Navigator.pushNamed(this.context, "/infopage"));
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateAge() async {
    final userUid = fbaseauth.currentUser!.uid;

    String new_age = infoCtrlr.text;

    try {
      await firestore
          .collection("users")
          .doc(userUid)
          .update({"age": new_age}).then(
              (value) => Navigator.pushNamed(this.context, "/infopage"));
    } catch (e) {
      print(e);
    }

    //add new key or update information with update method
    //set method requires all fields in database
    //it will delete all other fields if only one field is updated with set method
  }

  Future<void> updateEdu() async {
    final userUid = fbaseauth.currentUser!.uid;

    String new_edu = infoCtrlr.text;

    try {
      await firestore
          .collection("users")
          .doc(userUid)
          .update({"education": new_edu}).then(
              (value) => Navigator.pushNamed(this.context, "/infopage"));
    } catch (e) {
      print(e);
    }
  }
}

class infoDelete extends StatefulWidget {
  State<infoDelete> createState() => _infoDeleteState();
}

class _infoDeleteState extends State<infoDelete> {
  var isVisible = false;
  TextEditingController field = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppBarTitle)),
      body: Container(
        child: Column(
          children: [
            TextFormField(
              onChanged: (value) => detectKeyChange(value),
              controller: field,
              decoration: InputDecoration(hintText: "Enter key"),
            ),
            ElevatedButton(
                onPressed: () => deleteInformation(context),
                child: Text("Delete all info")),
            Visibility(
              visible: isVisible,
              child: ElevatedButton(
                onPressed: deleteKey,
                child: Text("Delete entered key"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteInformation(BuildContext context) async {
    var userUid = fbaseauth.currentUser!.uid;

    try {
      firestore.collection("users").doc(userUid).delete().then(
          (value) => Navigator.pushReplacementNamed(context, "/infopage"));
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteKey() async {
    var userUid = fbaseauth.currentUser!.uid;
    var key = field.text;

    try {
      firestore.collection("users").doc(userUid).update({key: FieldValue.delete()}).then(
          (value) => Navigator.pushReplacementNamed(context, "/infopage"));
    } catch (e) {
      print(e);
    }
  }

  void detectKeyChange(value) {
    setState(() {
      if (value != null) isVisible = true;
    });
  }
}
