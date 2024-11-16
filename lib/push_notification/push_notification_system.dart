import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver/global.dart';
import 'package:driver/model/user_ride_request_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'notification_dialog_box.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //defining messaging between the 2 application, rider app, and driver app
  Future initializeCloudMessaging(BuildContext context) async {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      if (remoteMessage != null) {
        readUserRideRequestInformation(
              remoteMessage!.data["rideRequestId"], context);
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      readUserRideRequestInformation(
          remoteMessage!.data["rideRequestId"], context);
    });
  }

  // to read request details
  void readUserRideRequestInformation(
      String userRideRequestId, BuildContext context) {
    FirebaseDatabase.instance
        .ref()
        .child("All Rides Request")
        .child(userRideRequestId)
        .child("driverId")
        .onValue
        .listen((event) {
      if (event.snapshot.value == "waiting" ||
          event.snapshot.value == firebaseAuth.currentUser!.uid) {
        FirebaseDatabase.instance
            .ref()
            .child("All Rides Request")
            .child(userRideRequestId)
            .once()
            .then((snapData) {
          if (snapData.snapshot.value != null) {
            audioPlayer.open(Audio("music/music_notification.mp3"));
            audioPlayer.play();

            var snapshotValue = snapData.snapshot.value as Map;

            double originLat = double.parse(
                snapshotValue["origin"]["latitude"]?.toString() ?? "0.0");
            double originLng = double.parse(
                snapshotValue["origin"]["longitude"]?.toString() ?? "0.0");
            String originAddress =
                snapshotValue["originAddress"] ?? "Unknown Address";

            double destinationLat = double.parse(
                snapshotValue["destination"]["latitude"]?.toString() ?? "0.0");
            double destinationLng = double.parse(
                snapshotValue["destination"]["longitude"]?.toString() ?? "0.0");
            String destinationAddress =
                snapshotValue["destinationAddress"] ?? "Unknown Address";

            String userName = snapshotValue["userName"] ?? "Unknown User";
            String userPhone = snapshotValue["userPhone"] ?? "Unknown Phone";

            String? userRideRequestId = snapData.snapshot.key;

            UserRideRequestInfo userRideRequestInfo = UserRideRequestInfo();
            userRideRequestInfo.originLatLng = LatLng(originLat, originLng);
            userRideRequestInfo.destinationLatLng =
                LatLng(destinationLat, destinationLng);
            userRideRequestInfo.originAddress = originAddress;
            userRideRequestInfo.destinationAddress = destinationAddress;
            userRideRequestInfo.userName = userName;
            userRideRequestInfo.userPhone = userPhone;
            userRideRequestInfo.rideRequestId = userRideRequestId;

            showDialog(
                context: context,
                builder: (BuildContext context) => NotificationDialogBox(
                  userRideRequestInfo: userRideRequestInfo,
                ));
          } else {
            Fluttertoast.showToast(msg: "The Request Id does not Exist");
          }
        });
      } else {
        Fluttertoast.showToast(msg: "Ride Request Has been cancelled");
      }
    });
  }

  //it is used for sending user request to drivers.
  Future generateAndGetToken() async {
    String? registrationToken = await messaging.getToken();
    print("FCM registration token: ${registrationToken}");

    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(firebaseAuth.currentUser!.uid)
        .child("token") // unique id, identifier
        .set(registrationToken);
    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}

// Here's a brief description of the PushNotificationSystem class and its methods:
//
// Class PushNotificationSystem:
//
// Handles the initialization and processing of push notifications received from Firebase Cloud Messaging (FCM).
//
// Method initializeCloudMessaging:
//
// Initializes Firebase Cloud Messaging.
// Listens for incoming messages and navigates to appropriate screens based on the message content.
//
// Method readUserRideRequestInformation:
//
// Reads and processes information related to a user's ride request from Firebase Realtime Database.
// Plays a notification sound and displays a dialog box with ride request details.
// Handles scenarios where the ride request has been cancelled or the request ID does not exist.
//
// Method generateAndGetToken:
//
// Generates and retrieves the FCM registration token for the device.
// Sets the token for the current driver in the Firebase Realtime Database.
// Subscribes the device to topics for all drivers and all users to receive relevant notifications.