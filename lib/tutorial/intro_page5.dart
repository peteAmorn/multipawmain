import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../support/constants.dart';

class introPage5 extends StatefulWidget {
  const introPage5({Key? key}) : super(key: key);

  @override
  _introPage5State createState() => _introPage5State();
}

class _introPage5State extends State<introPage5> {
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
                  child: Text('แตะ "ไปช้อปปิ้ง"',
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
                      child: Image.asset('assets/intro/goShopping.png')
                  ),
                ),
              ),
              Container(
                  alignment: Alignment(0.3,0.454),
                  height: MediaQuery.of(context).size.height*0.6,
                  child: Lottie.asset('assets/intro/tap.json')
              ),
            ],
          )
      ),
    );
  }
}
