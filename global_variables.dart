import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';


final AppBarTitle = "Firebase Demo";

final FirebaseAuth fbaseauth = FirebaseAuth.instance;

final FirebaseFirestore firestore = FirebaseFirestore.instance;

final FirebaseStorage fstorage = FirebaseStorage.instance;

// Create a storage reference from our app
final storageRef = fstorage.ref();