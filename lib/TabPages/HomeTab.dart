import 'dart:async';

import 'package:driver/AllScreen/RegistrationScreen.dart';
import 'package:driver/configMaps.dart';
import 'package:driver/main.dart';
import 'package:driver/push_notification/push_notification_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../assistants/assistants.dart';
import '../global.dart';

class HomeTab extends StatefulWidget {
  HomeTab({Key? key}) : super(key: key);
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(35.566864, 45.416107),
    // set the latitude and longitude of Iraq
    zoom: 14.4746,
  );

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final Completer<GoogleMapController> controllerGoogleMap =
      Completer<GoogleMapController>();
  static const CameraPosition kGooglePlex =
      CameraPosition(target: LatLng(35.566864, 45.416107), zoom: 14.4746);

  GoogleMapController? newGoogleMapController;

  late Position currentPosition;
  LocationPermission? locationPermission;

  var geoLocator = Geolocator();

  String driverStatusText = "Offline Now - Go Online";

  Color driverStatusColor = Colors.black;

  bool isDriverAvailable = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfLocationPermissionAllowed();
    readCurrentOnlineDriver();

    // to get the notification from users
    PushNotificationSystem pushNotificationSystem = PushNotificationSystem();
    pushNotificationSystem.initializeCloudMessaging(context);
    pushNotificationSystem.generateAndGetToken();
    driverIsOnlineNow();
  }
  // Dark map style
  final String _darkMapStyle = '''
    [
      {
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "administrative.locality",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#424242"
          }
        ]
      },
      {
        "featureType": "poi",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#757575"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#616161"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "geometry.fill",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.icon",
        "stylers": [
          {
            "visibility": "off"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#9e9e9e"
          }
        ]
      },
      {
        "featureType": "road",
        "elementType": "labels.text.stroke",
        "stylers": [
          {
            "color": "#212121"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "geometry",
        "stylers": [
          {
            "color": "#000000"
          }
        ]
      },
      {
        "featureType": "water",
        "elementType": "labels.text.fill",
        "stylers": [
          {
            "color": "#3d3d3d"
          }
        ]
      }
    ]
  ''';

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          padding: EdgeInsets.only(top: 40),
          mapType: MapType.normal,
          initialCameraPosition: kGooglePlex,
          myLocationEnabled: true,
          zoomGesturesEnabled: true,
          zoomControlsEnabled: true,
          onMapCreated: (GoogleMapController control) {
            controllerGoogleMap.complete(control);
            newGoogleMapController = control;
            control.setMapStyle(_darkMapStyle); // Apply dark theme here
            locateDriverPosition();
          },
        ),
      ],
    );
  }
// check android permission to active google maps
  checkIfLocationPermissionAllowed() async {
    locationPermission = await Geolocator.requestPermission();

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
    }
  }

  // to put driver in the right position based on Lat Lng
  Future<void> locateDriverPosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      driverCurrentPosition = position;

      LatLng latLngPosition = LatLng(position.latitude, position.longitude);
      CameraPosition cameraPosition =
          CameraPosition(target: latLngPosition, zoom: 14.4746);

      // Assuming you have a way to access and update the GoogleMapController
      newGoogleMapController
          ?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      String? humanReadableAddress =
          await AssistantsMethod.searchAddrForGeoCoordinate(
              driverCurrentPosition!, context);
      print("this is our address: " +
          humanReadableAddress! +
          " /---/---/---/---/---/---/---/---/---/---/---/--/-/--/---///-/-/--/-/");
      //
      // userName = userModelCurrentInfo?.name;
      // userEmail = userModelCurrentInfo?.email;

      // iniGeoFireListener();
      // AssistantsMethod.readTripForOnlineUser(context);
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Geolocation Permission Denied');
      } else if (e.code == 'LOCATION_SERVICES_DISABLED') {
        print('Location Services Disabled');
      } else {
        print('Geolocation error: $e');
      }
    }
  }

  // get driver current information
  readCurrentOnlineDriver() async {
    currentUser = firebaseAuth.currentUser;
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        onlineDriver.id = (snap.snapshot.value as Map)["id"];
        onlineDriver.model =
            (snap.snapshot.value as Map)["car_details"]["car_model"];
        onlineDriver.number =
            (snap.snapshot.value as Map)["car_details"]["car_number"];
        onlineDriver.color =
            (snap.snapshot.value as Map)["car_details"]["car_color"];
        onlineDriver.car_type =
        (snap.snapshot.value as Map)["car_details"]["car_type"];
        onlineDriver.name =(snap.snapshot.value as Map)["name"];
        onlineDriver.phone =(snap.snapshot.value as Map)["phone"];
        // onlineDriver.name =(snap.snapshot.value as Map)["name"];
      }
    });
  }


  void driverIsOnlineNow() async {
    // Get the current position
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    driverCurrentPosition = pos;

    // Set driver's location using Geofire
    Geofire.initialize("activeDrivers");
    Geofire.setLocation(
      currentUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );

    // Set the driver's status to online (no time check)
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("newRideStatus");
    ref.set("idle"); // Or "online" if you prefer to use "online" as the status
  }


  updateDriverLocationAtRealTime() {
    streamSubscriptionPosition = Geolocator.getPositionStream().listen((event) {
      if (isDriverAvailable == true) {
        Geofire.setLocation(currentUser!.uid, driverCurrentPosition!.latitude,
            driverCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  Future<String> getOnlineTimeFromDatabase() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers").child(currentUser!.uid).child("car_details").child("onlineTime");

    try {
      // Await the Future<DatabaseEvent> returned by ref.once()
      DatabaseEvent event = await ref.once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        String onlineTime = snapshot.value as String;
        print("Online time from database: $onlineTime");
        return onlineTime;
      } else {
        print("Online time not found in the database.");
        return ""; // or throw an error if appropriate
      }
    } catch (error) {
      print("Error reading online time: $error");
      return ""; // or throw an error if appropriate
    }
  }




  driverOfflineNow() {
    Geofire.removeLocation(currentUser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(Duration(milliseconds: 2000), () {
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });
  }
}



// readCurrentOnlineDriver(): Reads information about the current online driver from the Firebase Realtime Database. Updates the onlineDriver object with the retrieved data.
//
// driverIsOnlineNow(): Sets the current driver's status to online by updating their location in the Geofire database. Checks the driver's onlineTime attribute to determine if they should be online based on the current time.
//
// updateDriverLocationAtRealTime(): Updates the driver's location in real-time using Geolocator's position stream. Animates the camera to the new driver's location on the Google Map.
//
// getOnlineTimeFromDatabase(): Retrieves the driver's onlineTime attribute from the Firebase Realtime Database. Returns the online time as a string.
//
// driverOfflineNow(): Sets the current driver's status to offline by removing their location from the Geofire database and deleting their newRideStatus attribute from the Firebase Realtime Database. Additionally, it closes the app after a delay of 2 seconds.
// checkIfLocationPermissionAllowed(): Requests permission for accessing the device's location. It checks if the permission is denied and requests it again if needed.
//
// locateDriverPosition(): Attempts to retrieve the current position of the driver using the Geolocator plugin. It then sets the driver's current position on the map and retrieves the human-readable address corresponding to the driver's location using AssistantsMethod.searchAddrForGeoCoordinate(). If successful, it prints the address to the console.