import 'dart:async';

import 'package:driver/AllScreen/RegistrationScreen.dart';
import 'package:driver/AllWidgets/ProgressDialog.dart';
import 'package:driver/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'MainScreen.dart';


class LoginScreen extends StatelessWidget {
  static const String login = "login";
  TextEditingController emailtec = TextEditingController();
  TextEditingController passowrdtec = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2B4865), // Set the background to #3953A3
      body: Center( // Center the content on the screen
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
              children: [
                SizedBox(height: 50.0),
                // Remove the image logo and change the text color to red
                Text(
                  "Login As Driver",
                  style: TextStyle(
                    fontSize: 38,
                    fontFamily: 'Pacifico',
                    color: Colors.pinkAccent, // Red text color for "Welcome Driver"
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.0),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Driver Email input field with icon and a more subtle design
                      TextField(
                        controller: emailtec,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.white),
                          labelText: "Driver Email",
                          labelStyle: TextStyle(fontSize: 14.0, color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 12.0),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1), // Subtle opacity
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                      SizedBox(height: 20.0),

                      // Password input field with icon
                      TextField(
                        controller: passowrdtec,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: Colors.white),
                          labelText: "Password",
                          labelStyle: TextStyle(fontSize: 14.0, color: Colors.white),
                          hintStyle: TextStyle(color: Colors.white54, fontSize: 12.0),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        style: TextStyle(fontSize: 14.0, color: Colors.white),
                      ),
                      SizedBox(height: 40.0),

                      // Sign In Button with consistent design
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (!emailtec.text.contains("@")) {
                              displayToastMessage("Email is not valid", context);
                            } else if (passowrdtec.text.isEmpty) {
                              displayToastMessage("Password is empty", context);
                            } else {
                              loginAuthUser(context);
                            }
                          },
                          child: Text(
                            'Sign in',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold),
                          ),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.grey[100]!),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Text Button for account navigation with a modern, simple look
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                        context, RegistrationScreen.register, (route) => false);
                  },
                  child: const Text(
                    "Don’t have an account? Sign up",
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //firebase authorization process variable
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // this method is used to retrieve user credentials for login process
  void loginAuthUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(message: "Authentication Process.....");
        });
    final User? user = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: emailtec.text, password: passowrdtec.text)
            .catchError((errMSG) {
      Navigator.pop(context);
      displayToastMessage("Error: $errMSG", context);
    }))
        .user;

    if (user != null) {
      driverRf.child(user.uid).once().then((event) {
        if (event.snapshot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainScreen.main, (route) => false);
          displayToastMessage("Logged In Now", context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          print("No User Exists");
          displayToastMessage("Error: the user dosent exixts", context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage("Error Occured cannot be Signed in", context);
    }
  }
}
