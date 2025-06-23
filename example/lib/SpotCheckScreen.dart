import 'package:example/main.dart';
import 'package:flutter/material.dart';

class SpotCheckScreen extends StatelessWidget {
  const SpotCheckScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(

        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(

                  icon: const Icon(Icons.arrow_back, color: Colors.black,),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text("Payment page", style: TextStyle(color: Colors.black, fontSize: 25),),

                IconButton(

                  icon: const Icon(Icons.arrow_back, color: Colors.white,),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,

                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12)

              ),

              child: TextButton(

                onPressed: () {
                  // spotCheck.trackEvent("SpotCheckScreen", {"MobileClick": {}});
                  spotCheck.trackScreen("SpotCheckScreen");
                },
                child: const Text("pay the Amount", style: TextStyle(color: Colors.black),),
              ),
            ),
          ),


        ],
      ),
    );
  }
}