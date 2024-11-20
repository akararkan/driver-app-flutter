import 'package:driver/AllScreen/LoginScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../global.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('drivers');
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() => isLoading = false);
        return;
      }

      final DatabaseEvent event = await _dbRef.child(currentUser.uid).once();

      if (event.snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(event.snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print('No data available for this user');
      }
    } catch (error) {
      setState(() => isLoading = false);
      print('Error fetching user data: $error');
    }
  }

  // Method to handle user logout
  Future<void> _logout() async {
    try {
      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // Navigate to the LoginScreen after logging out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  LoginScreen()),
      );
    } catch (e) {
      // Handle errors (for example, show a snackbar with an error message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error logging out")),
      );
    }
  }

  Widget buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF355C7D),
            const Color(0xFF355C7D).withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 65,
                    color: const Color(0xFF355C7D),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8B195),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userData?['name'] ?? 'Driver Name',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData?['email'] ?? 'email@example.com',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoSection(String title, List<MapEntry<String, String>> items) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF355C7D),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: items.map((item) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: item != items.last
                          ? BorderSide(color: Colors.grey.withOpacity(0.2))
                          : BorderSide.none,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.key,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        item.value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF355C7D),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Handle ride status update
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5B7B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.drive_eta),
                const SizedBox(width: 8),
                Text(
                  'Ride Status: ${userData?['newRideStatus'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _logout,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.logout, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            "No user data available",
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: _fetchUserData,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // SliverAppBar(
            //   expandedHeight: 0,
            //   floating: true,
            //   backgroundColor: const Color(0xFF355C7D),
            //   elevation: 0,
            //   title: const Text(
            //     'Profile',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            //   centerTitle: true,
            // ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  buildProfileHeader(),
                  const SizedBox(height: 20),
                  buildInfoSection(
                    'Personal Information',
                    [
                      MapEntry('Phone', userData!['phone'] ?? 'N/A'),
                      MapEntry('Email', userData!['email'] ?? 'N/A'),
                    ],
                  ),
                  buildInfoSection(
                    'Vehicle Information',
                    [
                      MapEntry('Car Model', userData!['car_details']['car_model'] ?? 'N/A'),
                      MapEntry('Car Number', userData!['car_details']['car_number'] ?? 'N/A'),
                      MapEntry('Car Color', userData!['car_details']['car_color'] ?? 'N/A'),
                      MapEntry('Car Type', userData!['car_details']['car_type'] ?? 'N/A'),
                    ],
                  ),
                  buildActionButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}