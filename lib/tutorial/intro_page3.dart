import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../support/constants.dart';

class introPage3 extends StatefulWidget {
  const introPage3({Key? key}) : super(key: key);

  @override
  _introPage3State createState() => _introPage3State();
}

class _introPage3State extends State<introPage3> {
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
                  child: Text('แตะบวก(+) สร้างบัญชีหาคู่',
                      style: TextStyle(
                          color: themeColour,
                          fontSize: 25,
                          fontWeight: FontWeight.bold))),
              Container(
                alignment: Alignment(0,0.28),
                child: Padding(
                  padding: EdgeInsets.only(left: 20,right: 20,top: 20),
                  child: Container(
                    height: MediaQuery.of(context).size.height*0.6,
                      child: Image.asset('assets/intro/unknownphone.png')
                  ),
                ),
              ),
              Container(
                  alignment: Alignment(0.2,1.804),
                  height: MediaQuery.of(context).size.height*0.6,
                  child: Lottie.asset('assets/intro/tap.json')
              ),
            ],
          )
      ),
    );
  }
}
