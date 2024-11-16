import 'package:driver/AllScreen/MainScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FareAmountCollectionDialog extends StatefulWidget {
  double? totalFareAmount;

  FareAmountCollectionDialog({this.totalFareAmount});

  @override
  State<FareAmountCollectionDialog> createState() => _FareAmountCollectionDialogState();
}

class _FareAmountCollectionDialogState extends State<FareAmountCollectionDialog> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(6),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF8B195), // Light pink color for the dialog background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              // Trip Amount
              "Trip Amount",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20
              ),
            ),
            Text(
              "IQD${widget.totalFareAmount}",
              style: TextStyle(
                  color: Color(0xFF355C7D), // Dark blue color for the amount
                  fontWeight: FontWeight.bold,
                  fontSize: 50
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "This is the total trip amount. Please collect it from the user.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white
                ),
                onPressed: () {
                  Future.delayed(
                      Duration(milliseconds: 2000),(){
                    Navigator.push(context, MaterialPageRoute(builder: (c)=> MainScreen()));
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Collect Cash",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF355C7D), // Dark blue for text
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      "IDQ${widget.totalFareAmount}",
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF355C7D), // Dark blue for amount
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

}
