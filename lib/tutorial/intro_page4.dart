import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../support/constants.dart';

class introPage4 extends StatefulWidget {
  const introPage4({Key? key}) : super(key: key);

  @override
  _introPage4State createState() => _introPage4State();
}

class _introPage4State extends State<introPage4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: Stack(
            children: [
              Container(
                  alignment: Alignment(0,-0.484),
                  child: Text('ต้องการ "ซื้อขาย" หมา-แมว ?',
                      style: TextStyle(
                          color: themeColour,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
              Container(
                alignment: Alignment(0,0.28),
                child: Padding(
                  padding: EdgeInsets.only(left: 20,right: 20,bottom: 40),
                  child: Container(
                      height: MediaQuery.of(context).size.height*0.6,
                      child: Lottie.asset('assets/intro/shopping.json')
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
