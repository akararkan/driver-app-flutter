import 'package:driver/TabPages/EarnTab.dart';
import 'package:driver/TabPages/HomeTab.dart';
import 'package:driver/TabPages/ProfileTab.dart';
import 'package:driver/TabPages/FeedBacksTab.dart';
import 'package:flutter/material.dart';


class MainScreen extends StatefulWidget {
  static const String main = "main";

  MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin{
  TabController? tabController;
  int selectedIndex = 0;

  void onItemClicked(int index){
    setState(() {
      selectedIndex = index;
      tabController?.index = selectedIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: tabController,
        children: [HomeTab(), EarnTab(), FeedBacksTab(), ProfileTab()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: "Earnings"),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: "FeedBacks"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Account"),
        ],
        unselectedItemColor: Colors.white,  // Make unselected items white for contrast
        selectedItemColor: Color(0xFFF8B195),  // Applying #F8B195 (Soft Peach)
        backgroundColor: Color(0xFF355C7D), // Applying #355C7D (Blueish)
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Increase label size for better visibility
        unselectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        showUnselectedLabels: true,
        currentIndex: selectedIndex,
        onTap: onItemClicked,
      ),
      appBar: AppBar(
        title: Text("Main Screen", style: TextStyle(color: Colors.white)), // White text for contrast
        backgroundColor: Color(0xFFC06C84), // Applying #C06C84 (Pinkish)
      ),
    );
  }
}
