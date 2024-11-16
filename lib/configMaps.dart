import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import 'model/user_model.dart';

String mapKey ="AIzaSyBvTfvkkgBXf5YobG3dvbNsbbOA5perDTs";


User? firebaseUser;
User? userCurrentInfo;
User? currentFirebaseUser;
StreamSubscription<Position>? homeStreamSub;

