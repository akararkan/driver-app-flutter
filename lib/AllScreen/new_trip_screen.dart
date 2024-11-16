import 'dart:async';

import 'package:driver/AllScreen/MainScreen.dart';
import 'package:driver/AllWidgets/ProgressDialog.dart';
import 'package:driver/AllWidgets/fare_amount_collection_dialog_box.dart';
import 'package:driver/assistants/assistants.dart';
import 'package:driver/global.dart';
import 'package:driver/model/user_ride_request_info.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NewTripScreen extends StatefulWidget {
  UserRideRequestInfo? userRideRequestInfo;

  NewTripScreen({this.userRideRequestInfo});

  @override
  State<NewTripScreen> createState() => _NewTripScreenState();
}

class _NewTripScreenState extends State<NewTripScreen> {
  final Completer<GoogleMapController> controllerGoogleMap =
      Completer<GoogleMapController>();
  static const CameraPosition kGooglePlex =
      CameraPosition(target: LatLng(35.566864, 45.416107), zoom: 14.4746);

  GoogleMapController? newTripGoogleMapController;

  Set<Marker> setOfMarkers = Set<Marker>();
  Set<Circle> setOfCircle = Set<Circle>();
  Set<Polyline> setOfPolyline = Set<Polyline>();
  List<LatLng> polylinePositionCoordinates =[];
  PolylinePoints polylinePoints = PolylinePoints();
  double mapPadding =0;
  BitmapDescriptor? iconAnimateMarker;
  var geoLocator = Geolocator();
  Position? onlineDriverCurrentPosition;
  String rideRequestStatus ="accepted";
  String durationFromOriginToDest ="";
  bool isRequestDirectionDetails = false;
  String? buttonTitle = "Arrived";
  Color? buttonColor = Colors.green;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveAssignedDriverDetailsInfo();
  }
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
    createDriverIconMarker();

    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPadding),
            initialCameraPosition: kGooglePlex,
            mapType: MapType.normal,
            myLocationEnabled: true,
            markers: setOfMarkers,
            circles: setOfCircle,
            polylines: setOfPolyline,
            onMapCreated: (GoogleMapController controller) {
              controllerGoogleMap.complete(controller);
              newTripGoogleMapController = controller;
              controller.setMapStyle(_darkMapStyle); // Apply dark theme here
              setState(() {
                mapPadding = 350;
              });
              var driverCurrentLatLng = LatLng(driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
              var userPickLocation = widget.userRideRequestInfo!.originLatLng;
              drawPolylineFromOriginToDest(driverCurrentLatLng , userPickLocation!);
              getDriverLocationAtRealTime();
            },
          ),
          // UI Container
          Positioned(
            bottom: 0,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.all(16), // Increased padding for better spacing
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF355C7D), // Light pink color
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        durationFromOriginToDest,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Lavender gray color
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        thickness: 1,
                        color: Color(0xFF355C7D), // Dark blue color
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.userRideRequestInfo!.userName!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white, // Dark blue color
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.phone,
                              color: Colors.white, // Dark blue color
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            "images/origin.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestInfo!.originAddress!,
                                style: TextStyle(fontSize: 16, color: Colors.white), // Lavender gray color
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Image.asset(
                            "images/destination.png",
                            width: 30,
                            height: 30,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.userRideRequestInfo!.destinationAddress!,
                                style: TextStyle(fontSize: 16, color: Colors.white), // Lavender gray color
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        thickness: 1,
                        color: Color(0xFF355C7D), // Dark blue color
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          if (rideRequestStatus == "accepted") {
                            rideRequestStatus = "arrived";
                            FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!).child("status").set(rideRequestStatus);
                            setState(() {
                              buttonTitle = "Let`s Go";
                              buttonColor = Color(0xFFC06C84); // Rose color
                            });

                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) => ProgressDialog(message: "Loading..."),
                            );

                            await drawPolylineFromOriginToDest(
                              widget.userRideRequestInfo!.originLatLng!,
                              widget.userRideRequestInfo!.destinationLatLng!,
                            );
                            Navigator.pop(context);
                          }
                          else if (rideRequestStatus == "arrived") {
                            rideRequestStatus = "ontrip";
                            FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!).child("status").set(rideRequestStatus);
                            setState(() {
                              buttonTitle = "End Trip";
                              buttonColor = Colors.redAccent;
                            });
                          } else if (rideRequestStatus == "ontrip") {
                            endTripNow();
                          }
                        },
                        icon: Icon(
                          Icons.directions_car,
                          color: Colors.white, // White icon color for contrast
                          size: 25,
                        ),
                        label: Text(
                          buttonTitle!,
                          style: TextStyle(
                            color: Colors.white, // White label text for contrast
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(buttonColor ?? Color(0xFFC06C84)), // Default to rose color
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 20)),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  //step 1 when driver accept user request
  // originLatLng = user current position
  //destLatLng  = user pickup location
  Future<void> drawPolylineFromOriginToDest(LatLng originLatLng , LatLng destLatLng) async{
    showDialog(context: context,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...")
    );
    var directionDetailsInfo =await AssistantsMethod.originToDestinationDetails(originLatLng, destLatLng);
    
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = pPoints.decodePolyline(directionDetailsInfo.e_points!);

    polylinePositionCoordinates.clear();

    if(decodedPolylinePointsResult.isNotEmpty){
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        polylinePositionCoordinates.add(LatLng(pointLatLng.latitude , pointLatLng.longitude));
      });
    }

    setOfPolyline.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.deepOrange,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: polylinePositionCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5
      );
      setOfPolyline.add(polyline);
    });


    LatLngBounds boundsLatLng;
    if (originLatLng.latitude> destLatLng.latitude && originLatLng.longitude> destLatLng.longitude){
      boundsLatLng= LatLngBounds(southwest: destLatLng, northeast: originLatLng);
    }else if(originLatLng.longitude > destLatLng.longitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(originLatLng.latitude , destLatLng.longitude),
          northeast: LatLng(destLatLng.latitude , originLatLng.longitude)
      );
    }else if(originLatLng.latitude > destLatLng.latitude){
      boundsLatLng = LatLngBounds(
          southwest: LatLng(destLatLng.latitude , originLatLng.longitude),
          northeast: LatLng(originLatLng.latitude , destLatLng.longitude)
      );
    }else{
      boundsLatLng = LatLngBounds(southwest: originLatLng, northeast: destLatLng);
    }
    newTripGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker originMarker = Marker (

    markerId: MarkerId("originID"),
    position: originLatLng,
    icon: BitmapDescriptor.defaultMarkerWithHue (BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker (
    markerId: MarkerId("destinationID"),
    position: destLatLng,
    icon: BitmapDescriptor.defaultMarkerWithHue (BitmapDescriptor.hueRed),
    );

    setState(() {
      setOfMarkers.add(originMarker);
      setOfMarkers.add(destinationMarker);
    });
    Circle originCircle = Circle(
        circleId: CircleId("originID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng
    );
    Circle destCircle = Circle(
        circleId: CircleId("destinationID"),
        fillColor: Colors.green,
        radius: 12,
        strokeWidth: 3,
        strokeColor: Colors.white,
        center: originLatLng
    );
    setState(() {
      setOfCircle.add(originCircle);
      setOfCircle.add(destCircle);
    });
  }

  createDriverIconMarker(){
    if(iconAnimateMarker == null){
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context , size:Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/tt.png").then((value) {
        iconAnimateMarker = value;
      });
    }
  }
  saveAssignedDriverDetailsInfo(){
    DatabaseReference  databaseReference = FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!);
    Map driverLocationDataMap = {
      "latitude":driverCurrentPosition!.latitude.toString(),
      "longitude":driverCurrentPosition!.longitude.toString()
    };
    if(databaseReference.child("driverId") != "waiting"){
      databaseReference.child("driverLocation").set(driverLocationDataMap);
      databaseReference.child("status").set("accepted");
      databaseReference.child("driverId").set(onlineDriver.id);
      databaseReference.child("driverName").set(onlineDriver.name);
      databaseReference.child("driverPhone").set(onlineDriver.phone);
      databaseReference.child("ratings").set(onlineDriver.ratings);
      databaseReference.child("car_details").set(onlineDriver.model.toString() +" "+ onlineDriver.number.toString() + "( "+ onlineDriver.color.toString()+" )");
      savaRideRequestIdToDriverHistory();
    }else{
      Fluttertoast.showToast(msg: "This ride is already accepted by another driver. \n Reloading the app");
      Navigator.push(context, MaterialPageRoute(builder: (c) =>MainScreen()));
    }

  }

   savaRideRequestIdToDriverHistory() {
    DatabaseReference tripHistoryRef =  FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("tripHistory");
    tripHistoryRef.child(widget.userRideRequestInfo!.rideRequestId!).set(true);
   }

   // to get driver position on the map at realtime, it updates the screen of the driver
   getDriverLocationAtRealTime() {
    LatLng oldLatLng = LatLng(0, 0);

     streamSubscriptionDriverLivePosition = Geolocator.getPositionStream().listen((Position position) {
       driverCurrentPosition = position;
       onlineDriverCurrentPosition = position;
       LatLng latLngLiveDriverPosition = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
       Marker animatedMarker = Marker(
         markerId: MarkerId("AnimatedMarker"),
         position: latLngLiveDriverPosition,
         icon: iconAnimateMarker!,
         infoWindow: InfoWindow(title: "This is your position")
       );
       setState(() {
         CameraPosition cameraPosition = CameraPosition(target: latLngLiveDriverPosition , zoom: 18);
         newTripGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

         setOfMarkers.removeWhere((element) => element.markerId.value == "AnimatedMarker");
         setOfMarkers.add(animatedMarker);
       });
       oldLatLng = latLngLiveDriverPosition;
       updateDurationTimeAtRealTime();

       // update driver location at real time in database
       Map driverLatLngDataMap = {
         "latitude":onlineDriverCurrentPosition!.latitude.toString(),
         "longitude":onlineDriverCurrentPosition!.longitude.toString(),
       };

       FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!).child("driverLocation").set(driverLatLngDataMap);


     });
   }

   // update time when ever used
   updateDurationTimeAtRealTime() async{
    if(isRequestDirectionDetails == false){
      isRequestDirectionDetails == true;

      if(onlineDriverCurrentPosition ==null){
        return;
      }
      var originLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
      var destinationLatLng;
      if(rideRequestStatus =="accepted"){
        destinationLatLng = widget.userRideRequestInfo!.originLatLng;
      }
      else{
        destinationLatLng =widget.userRideRequestInfo!.destinationLatLng;
      }
      var directionInformation = await AssistantsMethod.originToDestinationDetails(originLatLng, destinationLatLng);

      if(directionInformation != null){
        setState(() {
          durationFromOriginToDest = directionInformation.duration_text!;
        });
      }
      isRequestDirectionDetails = false;
    }
   }

  endTripNow() async{
    showDialog(context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProgressDialog(message: "Please wait...")
    );

    var currentDriverPositionLatLng = LatLng(onlineDriverCurrentPosition!.latitude, onlineDriverCurrentPosition!.longitude);
    var tripDirectionDetails = await AssistantsMethod.originToDestinationDetails(currentDriverPositionLatLng, widget.userRideRequestInfo!.destinationLatLng!);
    double totalAmount = AssistantsMethod.calculateFromOriginToDestination(tripDirectionDetails!);
    FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!).child("fareAmount").set(totalAmount.toString());
    FirebaseDatabase.instance.ref().child("All Rides Request").child(widget.userRideRequestInfo!.rideRequestId!).child("status").set("ended");
    Navigator.pop(context);

    //display fare amount dialog box
    showDialog(context: context,
        builder:(BuildContext context) => FareAmountCollectionDialog(
          totalFareAmount: totalAmount,
        )
    );
    //save fare amount to driver total earnings;

    saveFareAmountToDriverEarnings(totalAmount);



  }

   saveFareAmountToDriverEarnings(double totalAmount) {
     FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").once().then((snap){
      if(snap.snapshot.value !=null){
        double oldAmount = double.parse(snap.snapshot.value.toString());
        double driverTotalEarnings = totalAmount + oldAmount;
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(driverTotalEarnings.toString());
      }else{
        FirebaseDatabase.instance.ref().child("drivers").child(firebaseAuth.currentUser!.uid).child("earnings").set(totalAmount.toString());
      }
    });
  }

}
