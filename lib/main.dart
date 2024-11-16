import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_geohash/dart_geohash.dart';
import 'package:driver/AllScreen/CarInfo.dart';
import 'package:driver/AllScreen/LoginScreen.dart';
import 'package:driver/AllScreen/MainScreen.dart';
import 'package:driver/AllScreen/RegistrationScreen.dart';
import 'package:driver/infoHandler/appHandler.dart';
import 'package:driver/configMaps.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';

void main() async {
  // Replace with your actual latitude and longitude
  double latitude = 35.437543893; // Example latitude (San Francisco)
  double longitude = 45.309779235; // Example longitude (San Francisco)

  // Create a GeoHasher instance (optional, for reusability)
  final geoHasher = GeoHasher();

  // Encode latitude and longitude to geohash string
  String geohash = geoHasher.encode(latitude, longitude);
  print('Geohash: $geohash'); // Output: Geohash: dgqpj2 tn263s48gg

  // Decode geohash string back to latitude and longitude
  List<double> decoded = geoHasher.decode(geohash);
  double decodedLatitude = decoded[0]; // Access latitude from list
  double decodedLongitude = decoded[1]; // Access longitude from list

  print('Decoded latitude: $decodedLatitude');
  print('Decoded longitude: $decodedLongitude');


  WidgetsFlutterBinding.ensureInitialized();

  // Retrieve Firebase options from a configuration file or environment variables
  FirebaseOptions options = const FirebaseOptions(
    projectId: "elaf-9df7c",
    apiKey: "AIzaSyDgePtHpf54xvNThnzZjvVj9xVyMVr_lik",
    appId: "1:51236179516:android:3bcbbc90692cb1d2abfd39",
    messagingSenderId: '1:51236179516:android:3bcbbc90692cb1d2abfd39',
    databaseURL: "https://elaf-9df7c-default-rtdb.firebaseio.com/",
  );

  await Firebase.initializeApp(name: "elaf", options: options);

  currentFirebaseUser = FirebaseAuth.instance.currentUser;

  runApp(MyApp());
}


DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
DatabaseReference allRequest = FirebaseDatabase.instance.ref().child("All Rides Request");

DatabaseReference driverRf = FirebaseDatabase.instance.ref().child("drivers");
DatabaseReference? rideRequestRef =FirebaseDatabase.instance.ref().child("drivers").child("zM7DlnldCXUuinwQhbIMyQvsjVk2").child("newRide");
class MyApp extends StatelessWidget {
  // const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppInfo(),
      child: MaterialApp(
        title: "Taxi App",
        theme: ThemeData(
          // primarySwatch: Colors.blue,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.login
            : MainScreen.main,
        // initialRoute: LoginScreen.login,
        routes: {
          RegistrationScreen.register: (context) => RegistrationScreen(),
          LoginScreen.login: (context) => LoginScreen(),
          MainScreen.main: (context) => MainScreen(),
          CarInfo.idScreen: (context) => CarInfo(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
