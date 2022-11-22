import 'package:flutter/material.dart';
import 'package:multipawmain/authCheck.dart';
import 'package:multipawmain/pages/myPets/myPets.dart';
import 'package:multipawmain/support/constants.dart';
import 'package:multipawmain/tutorial/intro_page1.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'intro_page2.dart';
import 'intro_page3.dart';
import 'intro_page4.dart';
import 'intro_page5.dart';

class introScreen extends StatefulWidget {
  final String? currentUserId;
  introScreen({required this.currentUserId});

  @override
  _introScreenState createState() => _introScreenState();
}

class _introScreenState extends State<introScreen> {
  PageController _controller = PageController();
  bool onFirstPage = true;
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index){
              setState(() {
                onFirstPage = (index == 0);
                onLastPage = (index == 4);
              });
            },
            children: [
              introPage1(),
              introPage2(),
              introPage3(),
              introPage4(),
              introPage5(),
            ],
          ),
          Container(
            alignment: Alignment(0,0.75),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  onFirstPage == true
                      ?SizedBox():InkWell(
                    child: Text('ย้อนกลับ',style: TextStyle(fontSize: 18,color: themeColour,fontWeight: FontWeight.bold)),
                    onTap: (){
                      _controller.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    },
                  ),
                  SmoothPageIndicator(
                      controller: _controller,
                      count: 5,
                    effect: ExpandingDotsEffect(activeDotColor: themeColour)
                  ),
                  onLastPage == true?InkWell(
                    child: Text('เสร็จสิ้น',style: TextStyle(fontSize: 18,color: themeColour,fontWeight: FontWeight.bold)),
                    onTap: ()async{
                      await usersRef.doc(widget.currentUserId).update({
                        'firstLogin':false
                      });

                      Navigator.push(context, MaterialPageRoute(builder: (context)=>myPets(currentUserId: widget.currentUserId,toCheck: true)));
                    },
                  ) :InkWell(
                    child: Text('ต่อไป',style: TextStyle(fontSize: 18,color: themeColour,fontWeight: FontWeight.bold)),
                    onTap: (){
                      _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
                    },
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}
