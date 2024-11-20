import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EarnTab extends StatefulWidget {
  const EarnTab({Key? key}) : super(key: key);

  @override
  _EarnTabState createState() => _EarnTabState();
}

class _EarnTabState extends State<EarnTab> {
  String? earnings;
  double exchangeRate = 0.0;
  String? earningsInUSD;
  double totalEarnings = 0.0;
  int totalTrips = 0;
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    getEarnings();
    fetchExchangeRate();
    countTripsForCurrentUser();
    calculateTripsAndRating();
  }

  Future<String?> getEarnings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return 'User not logged in';

    try {
      DatabaseReference driverRef =
      FirebaseDatabase.instance.ref().child("drivers").child(user.uid);
      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          earnings = data['earnings'].toString();
          totalEarnings = double.tryParse(earnings!) ?? 0.0;
        });
        return earnings;
      }
      return 'Driver details not found';
    } catch (e) {
      return 'Error retrieving earnings: $e';
    }
  }

  Future<void> countTripsForCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // First, get the driver's name from their profile
      DatabaseReference driverRef =
      FirebaseDatabase.instance.ref().child("drivers").child(user.uid);
      DataSnapshot driverSnapshot = await driverRef.get();

      if (!driverSnapshot.exists) {
        print('Driver profile not found');
        setState(() {
          totalTrips = 0;
        });
        return;
      }

      // Extract the driver's name from their profile
      String? driverName = (driverSnapshot.value as Map<dynamic, dynamic>)?['name'];

      if (driverName == null) {
        print('Driver name not found in profile');
        setState(() {
          totalTrips = 0;
        });
        return;
      }

      // Now query the rides with the driver's name
      DatabaseReference tripsRef =
      FirebaseDatabase.instance.ref().child("All Rides Request");

      // Get all rides
      DataSnapshot snapshot = await tripsRef.get();

      if (snapshot.exists) {
        int tripCount = 0;

        // Iterate through all rides and filter by the driver's name and completed status
        var data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // Check if the ride has driverName field and it matches current driver
          if (value['driverName'] == driverName &&
              value['status']?.toLowerCase() == "completed") {
            tripCount++;
          }
        });

        setState(() {
          totalTrips = tripCount;
        });

        print('Found $tripCount completed trips for driver: $driverName');
      } else {
        print('No rides found in database');
        setState(() {
          totalTrips = 0;
        });
      }
    } catch (e) {
      print('Error counting trips: $e');
      setState(() {
        totalTrips = 0;
      });
    }
  }
  Future<void> fetchExchangeRate() async {
    const String url = 'https://api.exchangerate-api.com/v4/latest/IQD';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRate = data['rates']['USD'] ?? 0.0;
          earningsInUSD = convertToUSD();
        });
      }
    } catch (e) {
      print("Error fetching exchange rate: $e");
    }
  }

  String? convertToUSD() {
    if (earnings != null && exchangeRate > 0) {
      double earningsValue = double.tryParse(earnings!) ?? 0.0;
      double convertedEarnings = earningsValue * exchangeRate;
      return '\$${convertedEarnings.toStringAsFixed(2)}';
    }
    return 'N/A';
  }
  Future<void> calculateTripsAndRating() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // First, get the driver's name from their profile
      DatabaseReference driverRef =
      FirebaseDatabase.instance.ref().child("drivers").child(user.uid);
      DataSnapshot driverSnapshot = await driverRef.get();

      if (!driverSnapshot.exists) {
        print('Driver profile not found');
        setState(() {
          totalTrips = 0;
          averageRating = 0.0;
        });
        return;
      }

      // Extract the driver's name from their profile
      String? driverName = (driverSnapshot.value as Map<dynamic, dynamic>)?['name'];
      print('Driver name from profile: $driverName'); // Debugging line to check driver name

      if (driverName == null) {
        print('Driver name not found in profile');
        setState(() {
          totalTrips = 0;
          averageRating = 0.0;
        });
        return;
      }

      // Query the rides with the driver's name
      DatabaseReference tripsRef =
      FirebaseDatabase.instance.ref().child("All Rides Request");

      // Get all rides
      DataSnapshot snapshot = await tripsRef.get();

      if (snapshot.exists) {
        int tripCount = 0;
        double totalRating = 0;
        int ratedTripsCount = 0;

        // Print the whole snapshot to verify the data structure
        print('Snapshot data: ${snapshot.value}'); // Debugging line to print snapshot data

        // Iterate through all rides and calculate statistics
        var data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          // Check if this ride belongs to the current driver
          if (value['feedback_info']?['driver_name'] == driverName) {
            tripCount++;

            // Print to see the data for each trip
            print('Processing trip: $key, feedback_info: ${value['feedback_info']}'); // Debugging line to check trip data

            // Check if the ride has a rating
            var rating = value['feedback_info']?['rating'];
            if (rating != null) {
              print('Found rating: $rating for trip $key'); // Debugging line to check rating
              double parsedRating = double.tryParse(rating.toString()) ?? 0.0;
              if (parsedRating > 0) {
                totalRating += parsedRating;
                ratedTripsCount++;
              }
            } else {
              print('No rating found for trip $key'); // Debugging line when rating is missing
            }
          }
        });

        // Calculate average rating
        double avgRating = ratedTripsCount > 0 ? totalRating / ratedTripsCount : 0.0;

        setState(() {
          totalTrips = tripCount;
          averageRating = double.parse(avgRating.toStringAsFixed(1)); // Round to 1 decimal place
        });

        print('Found $tripCount total trips for driver: $driverName');
        print('Average rating: $averageRating (from $ratedTripsCount rated trips)');
      } else {
        print('No rides found in database');
        setState(() {
          totalTrips = 0;
          averageRating = 0.0;
        });
      }
    } catch (e) {
      print('Error calculating trips and rating: $e');
      setState(() {
        totalTrips = 0;
        averageRating = 0.0;
      });
    }
  }

  Widget _buildEarningCard(String title, String value, IconData icon) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF6C5B7B),
              size: 28,
            ),
            const SizedBox(height: 12),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF355C7D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFF6C5B7B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Add your refresh logic here
          },
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Header Card
                    Card(
                      elevation: 8,
                      shadowColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5B7B), Color(0xFF355C7D)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Earnings',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'IQD ${earnings ?? "0"}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.currency_exchange,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'USD ${earningsInUSD ?? "Loading..."}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
              // Statistics Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildListDelegate([
                    _buildEarningCard(
                      'Total Earnings (USD)',
                      '${earningsInUSD ?? "Loading..."}',
                      Icons.attach_money,
                    ),
                    _buildEarningCard(
                      'Completed Trips',
                      '$totalTrips',
                      Icons.directions_car,
                    ),
                    _buildEarningCard(
                      'Rating',
                      averageRating > 0 ? averageRating.toString() : 'No ratings',
                      Icons.star,
                    ),
                  ]),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
            ],
          ),
        ),
      ),
    );
  }


}
