import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../support/constants.dart';

class introPage2 extends StatefulWidget {
  @override
  _introPage2State createState() => _introPage2State();
}

class _introPage2State extends State<introPage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ต้องการหาคู่ให้น้อง ?',style: TextStyle(color: themeColour,fontSize: 25,fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Lottie.asset('assets/intro/love.json'),
              ),
            ],
          )
      ),
    );
  }
}