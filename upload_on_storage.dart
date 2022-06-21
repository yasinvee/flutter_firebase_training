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
    return MaterialApp(title: "Firebase Demo", initialRoute: "/", routes: {
      '/': (context) => loginPage(),
      "/fileupload": (context) => uploadFile(),
      // "/imageshow": (context) => showImages(),
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

      await fbaseauth.signInWithCredential(credential).then(
          (value) => Navigator.pushReplacementNamed(context, "/fileupload"));
    } catch (e) {
      print("Error: $e");
      return;
    }
  }
}

class uploadFile extends StatefulWidget {
  State<uploadFile> createState() => _uploadFile();
}

class _uploadFile extends State<uploadFile> {
  String fname = "No file picked";
  late String filePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Heloo")),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Text("File name ${fname}"),
              ElevatedButton(onPressed: pickFile, child: Text("Pick file")),
              ElevatedButton(onPressed: uploadImage, child: Text("Upload"))
            ],
          ),
        ),
      ),
    );
  }

  void pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      PlatformFile file = result.files.first;

      this.filePath = file.path!;

      setState(() {
        this.fname = file.name;
      });
    }
  }

  void uploadImage() async {
    final fileRef = storageRef.child("images/pic.jpeg");

    await addUrl(fileRef);

    File f = File(this.filePath);

    try {
      final task = await fileRef.putFile(f);
    } catch (e) {
      print(e);
    }
  }

  Future<void> addUrl(fileref) async {
    try {
      await fileref.getDownloadURL().then((value) => addtofirestore(value));
    } catch (e) {
      print(e);
    }
  }

  void addtofirestore(url) async {
    try {
      await firestore
          .collection("files")
          .doc(fbaseauth.currentUser!.uid)
          .set({"url": url});
    } catch (e) {
      print(e);
    }
  }
}
