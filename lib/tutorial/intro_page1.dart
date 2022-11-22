import 'package:flutter/material.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:lottie/lottie.dart';

class introPage1 extends StatefulWidget {
  const introPage1({Key? key}) : super(key: key);

  @override
  _introPage1State createState() => _introPage1State();
}

class _introPage1State extends State<introPage1> {
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
            Text('ยินดีต้องรับสู่ MultiPaws',style: TextStyle(color: themeColour,fontSize: 25,fontWeight: FontWeight.bold)),
            SizedBox(height: 60),
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Lottie.asset('assets/intro/welcome.json'),
            ),
            SizedBox(height: 20),
            Text('แอปหาคู่และตลาดซื้อขายสุนัข และแมว',
                maxLines: 2,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                )),
          ],
        )
      ),
    );
  }
}
