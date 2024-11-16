import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
        setState(() {
          isLoading = false;
        });
        return;
      }

      final DatabaseReference _userRef = _dbRef.child(currentUser.uid);
      DatabaseEvent event = await _userRef.once();

      if (event.snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(event.snapshot.value as Map);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        print('No data available for this user');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $error');
    }
  }

  Widget buildProfilePicture() {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFFF8B195),
        child: const Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFFF8B195),
      elevation: 3,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF355C7D),
        ),
      ),
    );
  }

  Widget buildActionButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          // Handle the status update here
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6C5B7B),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'New Ride Status: ${userData!['newRideStatus']}',
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: const Color(0xFF355C7D),
      //   // title: const Text(
      //   //   'Profile',
      //   //   style: TextStyle(
      //   //     color: Colors.white,
      //   //     fontWeight: FontWeight.bold,
      //   //     fontSize: 24,
      //   //   ),
      //   // ),
      //   centerTitle: true,
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("No user data available"))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildProfilePicture(),
            const SizedBox(height: 20),
            buildSectionTitle('Personal Information'),
            buildInfoCard('Name', userData!['name'] ?? 'N/A'),
            buildInfoCard('Email', userData!['email'] ?? 'N/A'),
            buildInfoCard('Phone', userData!['phone'] ?? 'N/A'),
            const Divider(color: Color(0xFFC06C84), thickness: 1.5),
            buildSectionTitle('Car Details'),
            buildInfoCard('Car Model',
                userData!['car_details']['car_model'] ?? 'N/A'),
            buildInfoCard('Car Number',
                userData!['car_details']['car_number'] ?? 'N/A'),
            buildInfoCard('Car Color',
                userData!['car_details']['car_color'] ?? 'N/A'),
            buildInfoCard('Car Type',
                userData!['car_details']['car_type'] ?? 'N/A'),
            const Divider(color: Color(0xFFC06C84), thickness: 1.5),
            const SizedBox(height: 20),
            buildActionButton(),
          ],
        ),
      ),
    );
  }
}
