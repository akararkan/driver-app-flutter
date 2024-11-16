import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:driver/global.dart';
import 'package:driver/infoHandler/appHandler.dart';
import 'package:driver/map_key.dart';
import 'package:driver/model/directions.dart';
import 'package:driver/model/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:driver/model/direction_details_info.dart';
import 'package:driver/model/user_model.dart';

import '../global.dart';
import '../model/directions.dart';
class AssistantsMethod{


  static void redCurrentUserInfo() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref().child("drivers").child(currentUser!.uid);
    userRef.once().then((snap) => {
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.formSnapshot(snap.snapshot)
      }
    });
  }

  static Future<dynamic> receiveRequest(String url) async{
    http.Response httpResponse = await http.get(Uri.parse(url));

    try{
      if(httpResponse.statusCode == 200){
        String responseData = httpResponse.body;
        var decodeResponse = jsonDecode(responseData);

        return decodeResponse;
      }else{
        return "error occurred";
      }
    }catch(ex){
      return "error occurred";
    }

  }

  // static Future<String?> searchAddrForGeoCoordinate(Position position , context) async {
  //    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
  //
  //    try {
  //      var response = await get(Uri.parse(apiUrl)); // Assuming you have a function to make network requests
  //
  //      if (response.statusCode == 200) {
  //        var data = json.decode(response.body);
  //        if (data["status"] == "OK" && data["results"].isNotEmpty) {
  //          return data["results"][0]["formatted_address"];
  //        } else {
  //          print("Address retrieval failed: ${data["status"]}");
  //          return null;
  //        }
  //      } else {
  //        print("Network error: ${response.statusCode}");
  //        return null;
  //      }
  //    } catch (e) {
  //      print("Error retrieving address: $e");
  //      return null;
  //    }
  //  }
  static Future<String?> searchAddrForGeoCoordinate(Position position, context) async {
    String apiUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapkey";
    String humanReadableAddress = "";
    var requestResponse = await receiveRequest(apiUrl);

    if (requestResponse != null && requestResponse["status"] == "OK") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      Provider.of<AppInfo>(context, listen: false)
          .updatePickupLocationAddress(userPickUpAddress);

      return humanReadableAddress;
    } else {
      // Handle error or invalid response
      print("Error occurred or invalid response");
      return null;
    }
  }


  static Future<DirectionDetailsInfo> originToDestinationDetails(LatLng origin , LatLng destination) async{
    String apiUrl ="https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$mapkey";
    var responseDirectionApi = await receiveRequest(apiUrl);

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    directionDetailsInfo.e_points = responseDirectionApi["routes"][0]["overview_polyline"]["points"];

    directionDetailsInfo.distance_text = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];

    directionDetailsInfo.duration_text = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];


    return directionDetailsInfo;


  }

  static void pauseLiveLocationUpdate() {
    if (streamSubscriptionPosition != null) {
      streamSubscriptionPosition!.cancel();
      streamSubscriptionPosition = null; // Reset the subscription
      Geofire.removeLocation(firebaseAuth.currentUser!.uid);
    }
  }


  static double calculateFromOriginToDestination(DirectionDetailsInfo directionDetailsInfo){
    double timePerMinute = (directionDetailsInfo.durationValue!/60) * 0.1;
    double distancePerKilometer = (directionDetailsInfo.distanceValue! / 1000) * 500; // 750 Iraqi Dinars per kilometer
    double totalAmount = timePerMinute + distancePerKilometer;
    return double.parse(totalAmount.toStringAsFixed(1));
  }



}

// redCurrentUserInfo: Fetches current user information from Firebase Realtime Database and updates the global user model.
//
// receiveRequest: Sends a HTTP GET request to the provided URL and returns the decoded response if successful, otherwise returns an error message.
//
// searchAddrForGeoCoordinate: Retrieves the human-readable address corresponding to the provided geographical coordinates using the Google Maps Geocoding API. Updates the pickup location address in the app's state.
//
// originToDestinationDetails: Retrieves direction details (such as distance, duration, and route polyline) between two points using the Google Directions API and returns them as a DirectionDetailsInfo object.
//
// pauseLiveLocationUpdate: Pauses the live location update for the current user and removes their location from the Geofire database.
//
// calculateFromOriginToDestination: Calculates the estimated fare based on the provided direction details (distance and duration) between origin and destination points.