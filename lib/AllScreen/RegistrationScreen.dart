import 'package:driver/AllScreen/CarInfo.dart';
import 'package:driver/AllScreen/LoginScreen.dart';
import 'package:driver/AllScreen/MainScreen.dart';
import 'package:driver/configMaps.dart';
import 'package:driver/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../AllWidgets/ProgressDialog.dart';

import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  static const String register = "register";
  TextEditingController nametec = TextEditingController();
  TextEditingController emailtec = TextEditingController();
  TextEditingController phonetec = TextEditingController();
  TextEditingController passowrdtec = TextEditingController();

  RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF2B4865), // Set background to #2B4865
        body: Center( // Center the content on the screen
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Center vertically
                crossAxisAlignment: CrossAxisAlignment.center,
                // Center horizontally
                children: [
                  SizedBox(height: 50.0),
                  // Remove the image logo and change the text to "Registration for Driver"
                  Text(
                    "Registration for Driver",
                    style: TextStyle(
                      fontSize: 38,
                      fontFamily: 'Pacifico',
                      color: Colors
                          .pinkAccent, // White text to contrast with background
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40.0),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Name field with icon
                        TextField(
                          controller: nametec,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.person, color: Colors.white),
                            labelText: "Name",
                            labelStyle: TextStyle(fontSize: 14.0,
                                color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white54,
                                fontSize: 12.0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                        SizedBox(height: 20.0),

                        // Email field with icon
                        TextField(
                          controller: emailtec,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.white),
                            labelText: "Email",
                            labelStyle: TextStyle(fontSize: 14.0,
                                color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white54,
                                fontSize: 12.0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                        SizedBox(height: 20.0),

                        // Phone field with icon
                        TextField(
                          controller: phonetec,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.phone, color: Colors.white),
                            labelText: "Phone",
                            labelStyle: TextStyle(fontSize: 14.0,
                                color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white54,
                                fontSize: 12.0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                        SizedBox(height: 20.0),

                        // Password field with icon
                        TextField(
                          controller: passowrdtec,
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.white),
                            labelText: "Password",
                            labelStyle: TextStyle(fontSize: 14.0,
                                color: Colors.white),
                            hintStyle: TextStyle(color: Colors.white54,
                                fontSize: 12.0),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          style: TextStyle(fontSize: 14.0, color: Colors.white),
                        ),
                        SizedBox(height: 30.0),

                        // Register Button
                        Container(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nametec.text.length < 4) {
                                displayToastMessage(
                                    "Name character must be greater than 4",
                                    context);
                              } else if (!emailtec.text.contains("@")) {
                                displayToastMessage(
                                    "Email is not valid", context);
                              } else if (phonetec.text.isEmpty) {
                                displayToastMessage(
                                    "Phone number is required", context);
                              } else if (passowrdtec.text.length < 7) {
                                displayToastMessage(
                                    "Password must be at least 8 characters",
                                    context);
                              } else {
                                registerNewUser(context);
                              }
                            },
                            child: const Text('Register',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.grey[100]!),
                              shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
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

                  // Navigation to login screen
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginScreen.login, (route) => false);
                    },
                    child: const Text(
                      "Already have an account? Sign in",
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
    );
  }


// user registration method
final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

// this method is used for user Registration
void registerNewUser(BuildContext context) async {
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog(message: "Registration Process.....");
      });
  final User? user = (await _firebaseAuth
      .createUserWithEmailAndPassword(
      email: emailtec.text, password: passowrdtec.text)
      .catchError((errMSG) {
    Navigator.pop(context);

    displayToastMessage("Error: $errMSG", context);
  }))
      .user;

  if (user != null) {
// save user into database
    Map userDataMap = {
      "name": nametec.text.trim(),
      "email": emailtec.text.trim(),
      "phone": phonetec.text.trim()
    };
    driverRf.child(user.uid).set(userDataMap);
    currentFirebaseUser = firebaseUser;
    displayToastMessage(
        "Your Account Has been created Successfully", context);
    Navigator.pushNamed(context, CarInfo.idScreen);
  } else {
    Navigator.pop(context);

    displayToastMessage("No user a ccount has not been created", context);
  }
}}

// to display the popup messages
displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
