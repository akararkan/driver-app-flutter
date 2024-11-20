import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedBacksTab extends StatelessWidget {
  const FeedBacksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DatabaseReference ridesRef = FirebaseDatabase.instance.ref().child('All Rides Request');

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8B195), Color(0xFF355C7D)], // Gradient colors
        ),
      ),
      child: StreamBuilder<DatabaseEvent>(
        stream: ridesRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(color: Colors.red.shade800, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF355C7D)), // Using primary color for loading indicator
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(
              child: Text(
                'No feedback data available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          Map<dynamic, dynamic> ridesData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          List<MapEntry> ridesList = ridesData.entries.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: ridesList.length,
            itemBuilder: (context, index) {
              var feedbackInfo = ridesList[index].value['feedback_info'];

              if (feedbackInfo == null) return Container();

              return Card(
                elevation: 10,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Rounded corners for card
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF8B195), Color(0xFF6C5B7B)], // Secondary gradient colors
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, color: Color(0xFF355C7D), size: 28), // Main color for icons
                            const SizedBox(width: 12),
                            Text(
                              'Driver: ${feedbackInfo['driver_name']}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber.shade600, size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Rating: ${feedbackInfo['rating']}⭐',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.comment, color: Color(0xFF6C5B7B), size: 24), // Accent color for comments
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Feedback: ${feedbackInfo['feedback_text']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF355C7D), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Date: ${feedbackInfo['trip_date']}',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.money, color: Color(0x4649054B), size: 24),
                            const SizedBox(width: 12),
                            Text(
                              'Fare: IQD ${feedbackInfo['fare_amount']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
