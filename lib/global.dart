
import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:driver/model/driver_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:driver/model/direction_details_info.dart';
import 'package:driver/model/user_model.dart';
import 'package:geolocator/geolocator.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

User? currentUser;
DirectionDetailsInfo? tripDirectionDetailsInfo;
UserModel? userModelCurrentInfo;

Position? driverCurrentPosition;

DriverData onlineDriver = DriverData();

StreamSubscription<Position>? streamSubscriptionPosition;
StreamSubscription<Position>? streamSubscriptionDriverLivePosition;

AssetsAudioPlayer audioPlayer = AssetsAudioPlayer();






//
// firebaseAuth: Instance of FirebaseAuth for authentication operations.
//
// currentUser: Represents the currently authenticated user.
//
// tripDirectionDetailsInfo: Information about the directions for a trip, such as distance, duration, and route.
//
// userModelCurrentInfo: Information about the current user, typically retrieved from Firebase after authentication.
//
// driverCurrentPosition: Represents the current position of the driver.
//
// onlineDriver: Holds data about the driver who is currently online, including ID, car model, car number, car color, and car type.
//
// streamSubscriptionPosition: Subscription for receiving updates about the device's current position.
//
// streamSubscriptionDriverLivePosition: Subscription for receiving updates about the driver's live position.
//
// audio  Player: Instance of AssetsAudioPlayer for playing audio files.