import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver/assistants/assistants.dart';
import 'package:driver/global.dart';
import 'package:driver/model/user_ride_request_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../AllScreen/new_trip_screen.dart';

class NotificationDialogBox extends StatefulWidget {
  UserRideRequestInfo? userRideRequestInfo;

  NotificationDialogBox({this.userRideRequestInfo});

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      child: Container(
        margin: EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Color(0xFF355C7D), // Light pink color for the dialog background
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Gradient Section
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0XF8B195), Color(0XF8B196)], // Gradient with Dark Blue and Lavender Gray
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Vehicle Icon with circular background
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      onlineDriver.car_type == "Car"
                          ? "images/car.png"
                          : onlineDriver.car_type == "Bus"
                          ? "images/bus.png"
                          : "images/default_vehicle.png",
                      width: 60,
                      height: 60,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "New Ride Request",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Ride Details Section
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Origin Address Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            "images/pick.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Pickup Location",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6C5B7B), // Lavender gray color
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.userRideRequestInfo!.originAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF355C7D), // Dark blue color
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  // Destination Address Card
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.orange.shade100),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            "images/posimarker.png",
                            width: 25,
                            height: 25,
                          ),
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Drop-off Location",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6C5B7B), // Lavender gray color
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.userRideRequestInfo!.destinationAddress!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF355C7D), // Dark blue color
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Decline Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF8B195), // Light pink color
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Decline",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF355C7D), // Dark blue color
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  // Accept Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        audioPlayer.pause();
                        audioPlayer.stop();
                        audioPlayer = AssetsAudioPlayer();
                        acceptRideRequest(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC06C84), // Rose color
                        padding: EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Accept",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
    );
  }

  // to accept user requests
  void acceptRideRequest(BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {

      if(snap.snapshot.value == "idle"){
        FirebaseDatabase.instance.ref().child("drivers")
            .child(firebaseAuth.currentUser!.uid).child("newRideStatus").set("accepted");
        AssistantsMethod.pauseLiveLocationUpdate();
        Navigator.push(context, MaterialPageRoute(builder: (c) => NewTripScreen(
            userRideRequestInfo: widget.userRideRequestInfo
        )));

      }else{
        Fluttertoast.showToast(msg: "Ride Request Dose Not Exist");
      }
    });
  }
}
// Method acceptRideRequest:
//
// Retrieves the current ride status of the driver from Firebase Realtime Database.
// If the driver's status is "idle", updates the ride status to "accepted", pauses live location updates, and navigates to the NewTripScreen with the provided user ride request information.
// If the ride request does not exist or the driver's status is not "idle", displays a toast message indicating that the ride request does not exist.