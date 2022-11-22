import 'package:flutter/material.dart';

const Color themeColour = Color(0xFFA02222);

const bg_colour = Color(0xFFF5F5F5);
const verticalBox = SizedBox(height: 10);
const headerStyle = TextStyle(fontSize: 20,fontWeight: FontWeight.bold);
const topicStyle = TextStyle(fontSize: 15,fontWeight: FontWeight.bold);
TextStyle textStyle() => TextStyle(color: Colors.red.shade900,fontSize: 20,fontWeight: FontWeight.bold);

// Build Divider
Padding buildDivider() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 5),
    child: Divider(color: themeColour,thickness: 2),
  );
}

// Build Divider
Padding buildDividerNoPaddingVertical() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 0),
    child: Divider(color: themeColour,thickness: 2),
  );
}

Padding buildDividerGrey(){
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: Divider(color: Colors.grey),
  );
}
