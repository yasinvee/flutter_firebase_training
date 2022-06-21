// // ignore_for_file: nullable_type_in_catch_clause

// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_core/firebase_core.dart';

// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'firebase_options.dart';
// import 'global_variables.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return MaterialApp(title: "Firebase Demo", initialRoute: "/", routes: {
//       '/': (context) => loginPage(),
//       "/fileupload": (context) => uploadFile(),
//       "/imageshow": (context) => showImages(),
//     });
//   }
// }

// class loginPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(AppBarTitle),
//         automaticallyImplyLeading: false,
//       ),
//       body: Container(
//           child: Center(
//         child: ElevatedButton(
//           onPressed: () => googleAuth(context),
//           child: Text("Login With Google"),
//         ),
//       )),
//     );
//   }

//   Future<void> googleAuth(BuildContext context) async {
//     try {
//       //To check internet connectivity
//       await InternetAddress.lookup('firebase.google.com');

//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

//       final GoogleSignInAuthentication? googleAuth =
//           await googleUser?.authentication;
//       if (googleAuth == null) {
//         return;
//       }

//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       await fbaseauth.signInWithCredential(credential).then(
//           (value) => Navigator.pushReplacementNamed(context, "/fileupload"));
//     } catch (e) {
//       print("Error: $e");
//       return;
//     }
//   }
// }

// class uploadFile extends StatefulWidget {
//   State<uploadFile> createState() => _uploadFile();
// }

// class _uploadFile extends State<uploadFile> {
//   String filePath = "No File";
//   var i = 0;
//   late String fileName;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("App")),
//       body: Container(
//           child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text("File Path $filePath"),
//           ElevatedButton(
//             child: Text("Pick File"),
//             onPressed: getFile,
//           ),
//           ElevatedButton(
//               onPressed: upload, child: Text("Upload Selected File")),
//         ],
//       )),
//     );
//   }

//   void getFile() async {
//     final result = await FilePicker.platform.pickFiles(allowMultiple: false);

//     if (result != null) {
//       PlatformFile file = result.files.first;
//       this.fileName = file.name;
//       setState(() {
//         this.filePath = file.path!;
//       });
//     }
//   }

//   void upload() async {
//     this.i += 1;
//     final fileRef = storageRef.child("images/pic${i}.jpeg");
//     File file = File(this.filePath);

//     try {
//       await fileRef.putFile(file);
//     } catch (e) {
//       print(e);
//     }
//   }

//   void getImages() async {
//     try {
//       await storageRef.child("images").listAll().then((value) => getImageURLs(value));
//     } catch (e) {
//       print(e);
//     }
//   }

//   void getImageURLs(refs) async
//   {
//     List urlList;
//     try
//     {
//       urlList.add(await );
//     }
//     catch(e)
//     {
//       print(e)
//     }
//     Navigator.pushNamed(context, "/imageshow", arguments: value.items
//   }
// }

// class showImages extends StatefulWidget {
//   State<showImages> createState() => _showImages();
// }

// class _showImages extends State<showImages> {

//   @override
//   Widget build(BuildContext context) {

//     List imageList = ModalRoute.of(context)?.settings.arguments as List;
//     List<Widget> buttonList=[];

//     var i=0;
//     if(imageList!=null)
//     {
//     for(var image in imageList)
//     {
//       buttonList[i] = Image.network(image.getDownloadURL());
//     }
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Hello"),
//       ),
//       body: Container(
//         child: SafeArea(child: 
//           Column(
//             children: buttonList,
//           )
//         ),
//       ),
//     );
//   }
// }
