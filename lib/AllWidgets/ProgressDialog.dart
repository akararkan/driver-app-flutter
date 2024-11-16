import 'package:flutter/material.dart';

class ProgressDialog extends StatelessWidget {
  final String message;
  ProgressDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background for dialog
      child: Container(
        padding: EdgeInsets.all(16.0),
        width: 250,  // Fixed width to keep the dialog compact
        height: 120, // Fixed height for a compact design
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8B195), Color(0xFFC06C84)], // Gradient background using #F8B195 and #C06C84
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.0), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 4), // Subtle shadow effect for depth
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular Progress Indicator with a smaller size
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5B7B)), // #6C5B7B for indicator color
                strokeWidth: 3, // Slightly thinner progress indicator
              ),
              SizedBox(width: 15),
              // Text with smaller size and better alignment
              Expanded(
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14, // Reduced font size for compact design
                    letterSpacing: 1.0, // Letter spacing for better readability
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}