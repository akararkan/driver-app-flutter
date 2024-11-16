import 'package:driver/AllScreen/LoginScreen.dart';
import 'package:driver/AllScreen/MainScreen.dart';
import 'package:driver/AllScreen/RegistrationScreen.dart';
import 'package:driver/configMaps.dart';
import 'package:driver/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';

class CarInfo extends StatelessWidget {
  static const String idScreen = "carId";

  CarInfo({Key? key}) : super(key: key);

  TextEditingController carModelController = TextEditingController();
  TextEditingController carNumController = TextEditingController();
  TextEditingController carColorController = TextEditingController();
  TextEditingController carTypeTec = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 22,
              ),
              Image.asset(
                "images/c.webp",
                width: 390,
                height: 350,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(22, 22, 22, 32),
                child: Column(
                  children: [
                    SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Enter Car Details",
                      style: TextStyle(
                        fontFamily: "Bramd-Bold",
                        fontSize: 24,
                        color: Color(0xFF355C7D), // Dark Blue for title
                      ),
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    TextField(
                      controller: carModelController,
                      decoration: InputDecoration(
                        labelText: "Car Model",
                        hintText: "Enter Car Model Here",
                        labelStyle: TextStyle(
                          color: Color(0xFF355C7D), // Dark Blue for label
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF6C5B7B), // Lavender Gray for hint text
                        ),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carTypeTec,
                      decoration: InputDecoration(
                        labelText: "Car Type",
                        hintText: "Enter Car Type Here",
                        labelStyle: TextStyle(
                          color: Color(0xFF355C7D), // Dark Blue for label
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF6C5B7B), // Lavender Gray for hint text
                        ),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carNumController,
                      decoration: InputDecoration(
                        labelText: "Car Number",
                        hintText: "Enter Car Number Here",
                        labelStyle: TextStyle(
                          color: Color(0xFF355C7D), // Dark Blue for label
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF6C5B7B), // Lavender Gray for hint text
                        ),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: carColorController,
                      decoration: InputDecoration(
                        labelText: "Car Color",
                        hintText: "Enter Car Color Here",
                        labelStyle: TextStyle(
                          color: Color(0xFF355C7D), // Dark Blue for label
                        ),
                        hintStyle: TextStyle(
                          color: Color(0xFF6C5B7B), // Lavender Gray for hint text
                        ),
                      ),
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    SizedBox(
                      height: 42,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TextButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color(0xFFC06C84), // Rose color for the button
                          ),
                        ),
                        onPressed: () {
                          if (carModelController.text.isEmpty) {
                            displayToastMessage("Please Write Car Model", context);
                          } else if (carNumController.text.isEmpty) {
                            displayToastMessage("Please Write Car Number", context);
                          } else if (carColorController.text.isEmpty) {
                            displayToastMessage("Please Write Car Color", context);
                          } else {
                            registerDriver(context);
                          }

                          print("taxi requested");
                        },
                        child: Padding(
                          padding: EdgeInsets.all(17),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "NEXT",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //this method is used for registering  driver account
  void registerDriver(BuildContext context) async {
    String? userID = FirebaseAuth.instance.currentUser?.uid;

    // Get the user's current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Now that we have the position, proceed with the registration process
    saveDriverCarInfo(context, position);
  }

  // this method is used for saving car information like model color, type and so on
  void saveDriverCarInfo(BuildContext context, Position position) {
    String? userID = FirebaseAuth.instance.currentUser?.uid;

    Map<String, dynamic> carInfoMap = {
      "car_color": carColorController.text,
      "car_number": carNumController.text,
      "car_model": carModelController.text,
      "car_type": carTypeTec.text,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "onlineTime":"morning"
    };
    FirebaseDatabase.instance
        .reference()
        .child("drivers")
        .child(userID!)
        .child("car_details")
        .set(carInfoMap)
        .then((value) {
      Navigator.pushNamedAndRemoveUntil(
          context, LoginScreen.login, (route) => false);
    }).catchError((error) {
      print("Failed to save driver car info: $error");
    });
  }
}
