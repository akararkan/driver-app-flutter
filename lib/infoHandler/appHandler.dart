import 'package:flutter/cupertino.dart';
import 'package:driver/model/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation;
  Directions? userDropOffLocation;
  int countTotalTrip = 0;

// List<String> historyTripsList =[];
// List<TripHistoryModel> allTripHistory =[];

  void updatePickupLocationAddress(Directions userPickupAddress) {
    userPickUpLocation = userPickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions userDropOffAddress) {
    userDropOffLocation = userDropOffAddress;
    notifyListeners();
  }
}

// Class AppInfo:
//
// Manages the application state related to user pickup and drop-off locations, as well as total trip count.
// Extends ChangeNotifier, allowing it to notify listeners when the state changes.
//
// Method updatePickupLocationAddress:
//
// Updates the user's pickup location address in the application state.
// Accepts a Directions object representing the pickup location.
// Notifies listeners about the state change after updating the pickup location.
//
// Method updateDropOffLocationAddress:
//
// Updates the user's drop-off location address in the application state.
// Accepts a Directions object representing the drop-off location.
// Notifies listeners about the state change after updating the drop-off location.

