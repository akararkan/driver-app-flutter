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
  double exchangeRate = 0.0; // Will be updated from the API
  String? earningsInUSD;
  double totalEarnings = 0.0;
  double averageEarnings = 0.0;

  @override
  void initState() {
    super.initState();
    getEarnings(); // Fetch earnings for the current user
    fetchExchangeRate(); // Fetch the IQD to USD exchange rate
  }

  // Fetch the earnings for the current user
  Future<String?> getEarnings() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return 'User not logged in';
    }

    try {
      DatabaseReference driverRef =
      FirebaseDatabase.instance.ref().child("drivers").child(user.uid);
      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists) {
        var data = snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          earnings = data['earnings'].toString();
          totalEarnings = double.tryParse(earnings!) ?? 0.0;
          averageEarnings = totalEarnings; // Default, can be improved with a history
        });
        return earnings;
      } else {
        return 'Driver details not found';
      }
    } catch (e) {
      return 'Error retrieving earnings: $e';
    }
  }

  // Fetch the IQD to USD exchange rate from an external API
  Future<void> fetchExchangeRate() async {
    const String url = 'https://api.exchangerate-api.com/v4/latest/IQD'; // Example API URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRate = data['rates']['USD'] ?? 0.0; // Get USD rate for IQD
          earningsInUSD = convertToUSD();
        });
      } else {
        throw Exception('Failed to fetch exchange rate');
      }
    } catch (e) {
      print("Error fetching exchange rate: $e");
    }
  }

  // Convert earnings from IQD to USD
  String? convertToUSD() {
    if (earnings != null && exchangeRate > 0) {
      double earningsValue = double.tryParse(earnings!) ?? 0.0;
      double convertedEarnings = earningsValue * exchangeRate;
      return '\$${convertedEarnings.toStringAsFixed(2)}';
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Earnings Summary
            Text(
              'Total Earnings: IQD${earnings ?? "Loading..."}',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF6C5B7B), // Purple color
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Earnings in USD: ${earningsInUSD ?? "Loading..."}',
              style: TextStyle(
                fontSize: 22,
                color: Color(0xFF355C7D), // Dark blue color
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 30),
            // Action Buttons (Convert to USD & More)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  earningsInUSD = convertToUSD();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF8B195), // Button color (Peach color)
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
              ),
              child: Text(
                'Convert to USD',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            // Display Converted Earnings
            if (earningsInUSD != null)
              Text(
                'Converted Earnings: $earningsInUSD',
                style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF6C5B7B), // Purple color
                  fontWeight: FontWeight.bold,
                ),
              ),
            SizedBox(height: 30),
            // Earnings Analysis (Total and Average Earnings)
            Text(
              'Total Earnings: IQD${totalEarnings.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF355C7D),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Average Earnings: IQD${averageEarnings.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF355C7D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
